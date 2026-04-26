package dev.specbinder.reporter;

import com.fasterxml.jackson.core.JsonProcessingException;
import dev.specbinder.annotations.output.ScenarioHash;
import dev.specbinder.annotations.output.SourceFilePath;
import dev.specbinder.annotations.output.SourceLine;
import dev.specbinder.reporter.internal.InstrumentedClassFactory;
import dev.specbinder.reporter.internal.StepCallSiteScanner;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.extension.*;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * JUnit 5 extension that captures hierarchical execution data for SpecBinder-generated
 * test classes — feature, rule, scenario, and per-step — and writes one JSON file per
 * feature under the project's build output directory.
 * <p>
 * Activate by placing {@code @ExtendWith(SpecBinderReporter.class)} on the marker
 * class consumed by {@code @Gherkin2JUnit}. Because {@code @ExtendWith} is meta-
 * annotated {@code @Inherited}, the extension fires automatically for every concrete
 * subclass JUnit discovers.
 */
public class SpecBinderReporter implements
        BeforeAllCallback,
        AfterAllCallback,
        BeforeEachCallback,
        AfterEachCallback,
        TestInstanceFactory,
        TestExecutionExceptionHandler,
        LifecycleMethodExecutionExceptionHandler,
        TestWatcher {

    private static final Logger LOGGER = Logger.getLogger(SpecBinderReporter.class.getName());
    private static final ExtensionContext.Namespace NAMESPACE =
            ExtensionContext.Namespace.create(SpecBinderReporter.class);

    private static final String KEY_FEATURE_REPORT = "featureReport";
    private static final String KEY_PLAN = "plan";
    private static final String KEY_INSTRUMENTED_CLASS = "instrumentedClass";
    private static final String KEY_SOURCE_FILE_PATH = "sourceFilePath";
    private static final String KEY_FEATURE_START_NANOS = "featureStartNanos";
    private static final String KEY_REPORT_DIR = "reportDir";
    private static final String KEY_RULE_REPORT = "ruleReport";
    private static final String KEY_OUTLINE_NODE = "outlineNode";

    private static final ThreadLocal<ScenarioStepBuffer> CURRENT_BUFFER = new ThreadLocal<>();
    private static final ThreadLocal<Throwable> CURRENT_SCENARIO_ERROR = new ThreadLocal<>();

    private static final ReportWriter REPORT_WRITER = new ReportWriter();

    // ---- step interceptor entry points (called by ByteBuddy overrides) ----

    /** Invoked by an instrumented step override before delegating to {@code super}. */
    public static void stepStarting(String methodName, Object[] args) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        if (buffer != null) {
            buffer.started(methodName, args);
        }
    }

    /** Invoked by an instrumented step override after the {@code super} call returns. */
    public static void stepPassed() {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        if (buffer != null) {
            buffer.passed();
        }
    }

    /** Invoked by an instrumented step override when the {@code super} call throws. */
    public static void stepFailed(Throwable throwable) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        if (buffer != null) {
            buffer.failed(throwable);
        }
    }

    // ---- BeforeAll: build feature report or rule report ----

    @Override
    public void beforeAll(ExtensionContext context) {
        Class<?> testClass = context.getRequiredTestClass();
        Optional<String> sourceFilePath = findSourceFilePath(testClass);
        if (sourceFilePath.isEmpty()) {
            return;
        }

        ExtensionContext.Store store = context.getStore(NAMESPACE);

        if (isNestedRule(testClass)) {
            FeatureReport featureReport = findFeatureReport(context);
            if (featureReport == null) {
                return;
            }
            RuleReport rule = new RuleReport();
            rule.setId(testClass.getName());
            rule.setDisplayName(displayNameOf(testClass));
            rule.setSourceLine(readSourceLine(testClass));
            featureReport.getRules().add(rule);
            store.put(KEY_RULE_REPORT, rule);

            StepCallSiteScanner.Plan plan = StepCallSiteScanner.scan(testClass);
            store.put(KEY_PLAN, plan);
            return;
        }

        // Feature root.
        FeatureReport report = new FeatureReport();
        report.setSourceFilePath(sourceFilePath.get());
        report.setGeneratedClass(testClass.getName());
        report.setDisplayName(displayNameOf(testClass));
        report.setExecutedAt(Instant.now());
        store.put(KEY_FEATURE_REPORT, report);
        store.put(KEY_SOURCE_FILE_PATH, sourceFilePath.get());
        store.put(KEY_FEATURE_START_NANOS, System.nanoTime());

        StepCallSiteScanner.Plan plan = StepCallSiteScanner.scan(testClass);
        store.put(KEY_PLAN, plan);

        // Build the instrumented subclass once, covering every step name discovered
        // on the feature root and on every @Nested rule member class — the same
        // outer instance is shared across direct tests and nested rule tests.
        Set<String> allStepNames = new LinkedHashSet<>(plan.stepMethodNames());
        for (Class<?> nested : nestedTestClassesOf(testClass)) {
            StepCallSiteScanner.Plan nestedPlan = StepCallSiteScanner.scan(nested);
            allStepNames.addAll(nestedPlan.stepMethodNames());
        }
        Class<?> instrumented = InstrumentedClassFactory.instrumentedSubclassOf(testClass, allStepNames);
        store.put(KEY_INSTRUMENTED_CLASS, instrumented);

        Optional<Path> reportDir = ReportPaths.resolve();
        if (reportDir.isEmpty()) {
            LOGGER.warning("SpecBinder reporter: no Maven (pom.xml) or Gradle (build.gradle*) marker found "
                    + "walking up from " + System.getProperty("user.dir") + "; reports will not be written.");
        } else {
            store.put(KEY_REPORT_DIR, reportDir.get());
        }
    }

    // ---- TestInstanceFactory: return instrumented instance for the outer class ----

    @Override
    public Object createTestInstance(TestInstanceFactoryContext factoryContext, ExtensionContext extensionContext) {
        Class<?> testClass = factoryContext.getTestClass();
        Optional<Object> outerInstance = factoryContext.getOuterInstance();

        try {
            if (outerInstance.isEmpty()) {
                Class<?> instrumented = lookupInstrumentedClass(extensionContext, testClass);
                Constructor<?> ctor = instrumented.getDeclaredConstructor();
                ctor.setAccessible(true);
                return ctor.newInstance();
            }
            // @Nested class: instantiate normally with the (already instrumented) outer instance.
            Constructor<?> ctor = testClass.getDeclaredConstructors()[0];
            ctor.setAccessible(true);
            return ctor.newInstance(outerInstance.get());
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException("SpecBinder reporter failed to instantiate "
                    + testClass.getName(), e);
        }
    }

    private static Class<?> lookupInstrumentedClass(ExtensionContext context, Class<?> fallback) {
        ExtensionContext featureRoot = featureRootContextOf(context);
        if (featureRoot == null) {
            return fallback;
        }
        Class<?> instrumented = featureRoot.getStore(NAMESPACE).get(KEY_INSTRUMENTED_CLASS, Class.class);
        return instrumented == null ? fallback : instrumented;
    }

    // ---- BeforeEach: pre-populate the per-scenario step buffer ----

    @Override
    public void beforeEach(ExtensionContext context) {
        ExtensionContext featureRoot = featureRootContextOf(context);
        if (featureRoot == null || featureRoot.getStore(NAMESPACE).get(KEY_FEATURE_REPORT) == null) {
            return;
        }
        Method testMethod = context.getRequiredTestMethod();

        List<StepCallSiteScanner.Call> backgroundCalls = collectBackgroundCalls(context);
        StepCallSiteScanner.Plan ownPlan = context.getStore(NAMESPACE).get(KEY_PLAN, StepCallSiteScanner.Plan.class);
        // Walk up to the feature root collecting plans, but the test method itself is
        // declared on whichever class introduced it — find that plan.
        List<StepCallSiteScanner.Call> scenarioCalls = scenarioCallsForTestMethod(context, testMethod, ownPlan);

        ScenarioStepBuffer buffer = ScenarioStepBuffer.preallocated(backgroundCalls, scenarioCalls);
        CURRENT_BUFFER.set(buffer);
        CURRENT_SCENARIO_ERROR.remove();
    }

    // ---- AfterEach: drain step buffer onto a ScenarioNode / ExampleReport ----

    @Override
    public void afterEach(ExtensionContext context) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        CURRENT_BUFFER.remove();
        Throwable scenarioError = CURRENT_SCENARIO_ERROR.get();
        CURRENT_SCENARIO_ERROR.remove();
        if (buffer == null) {
            return;
        }

        ExtensionContext featureRoot = featureRootContextOf(context);
        if (featureRoot == null) {
            return;
        }
        FeatureReport featureReport = featureRoot.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
        if (featureReport == null) {
            return;
        }

        Method testMethod = context.getRequiredTestMethod();
        Status status = deriveScenarioStatus(buffer, scenarioError, context.getExecutionException().orElse(null));
        Instant startedAt = buffer.scenarioStartedAt();
        long durationMs = buffer.scenarioDurationMs();

        buffer.finalizeDuration();
        List<StepReport> backgroundSteps = buffer.backgroundSnapshot();
        List<StepReport> scenarioSteps = buffer.scenarioSnapshot();

        if (isParameterizedRow(context)) {
            ScenarioNode outline = obtainOutlineNode(context, testMethod);
            ExampleReport row = new ExampleReport();
            row.setDisplayName(context.getDisplayName());
            row.setStatus(status);
            row.setSourceLine(outline.getSourceLine());
            row.setStartedAt(startedAt);
            row.setDurationMs(durationMs);
            Map<String, String> examplesRow = parseExamplesRow(context.getDisplayName());
            row.setExamplesRow(examplesRow);
            if (outline.getScenarioHash() != null) {
                row.setRowHash(RowHasher.hash(examplesRow));
            }
            if (!backgroundSteps.isEmpty()) {
                row.setBackgroundSteps(backgroundSteps);
            }
            row.setSteps(scenarioSteps);
            outline.getExamples().add(row);
            featureReport.getSummary().increment(status);
            return;
        }

        ScenarioNode node = ScenarioNode.scenario();
        node.setId(formatTestId(testMethod));
        node.setDisplayName(context.getDisplayName());
        node.setStatus(status);
        node.setSourceLine(readSourceLine(testMethod));
        node.setScenarioHash(readScenarioHash(testMethod));
        node.setTags(tagsOf(context));
        node.setStartedAt(startedAt);
        node.setDurationMs(durationMs);
        if (!backgroundSteps.isEmpty()) {
            node.setBackgroundSteps(backgroundSteps);
        }
        node.setSteps(scenarioSteps);
        attachScenario(context, node, featureReport);
        featureReport.getSummary().increment(status);
    }

    // ---- Exception handlers: record scenario-level throwable, then rethrow ----

    @Override
    public void handleTestExecutionException(ExtensionContext context, Throwable throwable) throws Throwable {
        CURRENT_SCENARIO_ERROR.set(throwable);
        throw throwable;
    }

    @Override
    public void handleBeforeEachMethodExecutionException(ExtensionContext context, Throwable throwable) throws Throwable {
        CURRENT_SCENARIO_ERROR.set(throwable);
        throw throwable;
    }

    // ---- TestWatcher: record disabled scenarios ----

    @Override
    public void testDisabled(ExtensionContext context, Optional<String> reason) {
        ExtensionContext featureRoot = featureRootContextOf(context);
        if (featureRoot == null) {
            return;
        }
        FeatureReport featureReport = featureRoot.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
        if (featureReport == null || context.getTestMethod().isEmpty()) {
            return;
        }
        Method testMethod = context.getTestMethod().get();
        ScenarioNode node = ScenarioNode.scenario();
        node.setId(formatTestId(testMethod));
        node.setDisplayName(context.getDisplayName());
        node.setStatus(Status.SKIPPED);
        node.setSourceLine(readSourceLine(testMethod));
        node.setScenarioHash(readScenarioHash(testMethod));
        node.setTags(tagsOf(context));
        attachScenario(context, node, featureReport);
        featureReport.getSummary().increment(Status.SKIPPED);
    }

    // ---- AfterAll: roll up outline totals, sort, write JSON ----

    @Override
    public void afterAll(ExtensionContext context) {
        ExtensionContext.Store store = context.getStore(NAMESPACE);
        FeatureReport featureReport = store.get(KEY_FEATURE_REPORT, FeatureReport.class);
        if (featureReport == null) {
            // Could be a @Nested rule context; nothing to flush at this level.
            return;
        }
        Long startNanos = store.get(KEY_FEATURE_START_NANOS, Long.class);
        if (startNanos != null) {
            featureReport.setTotalDurationMs(Duration.ofNanos(System.nanoTime() - startNanos).toMillis());
        }

        finalizeOutlineNodes(featureReport);
        sortByLine(featureReport);

        Path reportDir = store.get(KEY_REPORT_DIR, Path.class);
        if (reportDir == null) {
            return;
        }
        Path target = ReportPaths.featureReportFile(reportDir, featureReport.getSourceFilePath());
        try {
            REPORT_WRITER.write(featureReport, target);
        } catch (JsonProcessingException e) {
            LOGGER.log(Level.WARNING, "SpecBinder reporter: failed to serialize report for "
                    + featureReport.getSourceFilePath(), e);
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "SpecBinder reporter: failed to write report file for "
                    + featureReport.getSourceFilePath(), e);
        }
    }

    // ---- helpers ----

    private static List<StepCallSiteScanner.Call> collectBackgroundCalls(ExtensionContext leafContext) {
        // Walk parents from the leaf context up to (and including) the feature root,
        // collecting background calls from each enclosing class so that Background
        // methods declared on outer + nested both contribute, in outer→inner order.
        List<StepCallSiteScanner.Plan> plansFromRootToLeaf = new ArrayList<>();
        ExtensionContext ctx = leafContext.getParent().orElse(null);
        while (ctx != null) {
            StepCallSiteScanner.Plan plan = ctx.getStore(NAMESPACE).get(KEY_PLAN, StepCallSiteScanner.Plan.class);
            if (plan != null) {
                plansFromRootToLeaf.add(0, plan);
            }
            ctx = ctx.getParent().orElse(null);
        }
        List<StepCallSiteScanner.Call> calls = new ArrayList<>();
        for (StepCallSiteScanner.Plan plan : plansFromRootToLeaf) {
            calls.addAll(plan.backgroundCalls());
        }
        return calls;
    }

    private static List<StepCallSiteScanner.Call> scenarioCallsForTestMethod(ExtensionContext context,
                                                                             Method testMethod,
                                                                             StepCallSiteScanner.Plan ownPlan) {
        // The test method is declared on context.getRequiredTestClass(); its class context's plan
        // already covers it. Walk up parents to find a plan that knows about this method.
        ExtensionContext ctx = context.getParent().orElse(null);
        while (ctx != null) {
            StepCallSiteScanner.Plan plan = ctx.getStore(NAMESPACE).get(KEY_PLAN, StepCallSiteScanner.Plan.class);
            if (plan != null) {
                List<StepCallSiteScanner.Call> calls = plan.scenarioCallsFor(testMethod);
                if (!calls.isEmpty()) {
                    return calls;
                }
            }
            ctx = ctx.getParent().orElse(null);
        }
        return ownPlan == null ? List.of() : ownPlan.scenarioCallsFor(testMethod);
    }

    private static Status deriveScenarioStatus(ScenarioStepBuffer buffer, Throwable scenarioError,
                                               Throwable executionException) {
        if (scenarioError != null || executionException != null) {
            Throwable t = scenarioError != null ? scenarioError : executionException;
            // org.opentest4j.TestAbortedException maps to ABORTED.
            String typeName = t.getClass().getName();
            if ("org.opentest4j.TestAbortedException".equals(typeName)) {
                return Status.ABORTED;
            }
            return Status.FAILED;
        }
        return Status.PASSED;
    }

    private static boolean isParameterizedRow(ExtensionContext context) {
        // A row of @ParameterizedTest has a parent context whose unique id ends with the
        // method id and whose own unique id ends with a "[N]" invocation segment.
        return context.getUniqueId().contains("[test-template-invocation");
    }

    private static ScenarioNode obtainOutlineNode(ExtensionContext rowContext, Method testMethod) {
        ExtensionContext methodCtx = rowContext.getParent().orElseThrow();
        ExtensionContext.Store methodStore = methodCtx.getStore(NAMESPACE);
        ScenarioNode existing = methodStore.get(KEY_OUTLINE_NODE, ScenarioNode.class);
        if (existing != null) {
            return existing;
        }
        ScenarioNode outline = ScenarioNode.outline();
        outline.setId(formatTestId(testMethod));
        outline.setDisplayName(deriveOutlineDisplayName(methodCtx, testMethod));
        outline.setSourceLine(readSourceLine(testMethod));
        outline.setScenarioHash(readScenarioHash(testMethod));
        outline.setTags(tagsOf(methodCtx));
        methodStore.put(KEY_OUTLINE_NODE, outline);

        ExtensionContext featureRoot = featureRootContextOf(rowContext);
        FeatureReport featureReport = featureRoot.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
        attachScenario(methodCtx, outline, featureReport);
        return outline;
    }

    private static String deriveOutlineDisplayName(ExtensionContext methodCtx, Method testMethod) {
        DisplayName ann = testMethod.getAnnotation(DisplayName.class);
        if (ann != null && !ann.value().isEmpty()) {
            return ann.value();
        }
        return methodCtx.getDisplayName();
    }

    private static void attachScenario(ExtensionContext context, ScenarioNode node, FeatureReport featureReport) {
        // Walk up parents looking for a RuleReport. If none, attach at feature root.
        ExtensionContext ctx = context.getParent().orElse(null);
        while (ctx != null) {
            RuleReport rule = ctx.getStore(NAMESPACE).get(KEY_RULE_REPORT, RuleReport.class);
            if (rule != null) {
                rule.getScenarios().add(node);
                return;
            }
            FeatureReport report = ctx.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
            if (report != null) {
                report.getScenarios().add(node);
                return;
            }
            ctx = ctx.getParent().orElse(null);
        }
        featureReport.getScenarios().add(node);
    }

    private static void finalizeOutlineNodes(FeatureReport report) {
        for (ScenarioNode node : report.getScenarios()) {
            if (node.getType() == ScenarioNode.Kind.SCENARIO_OUTLINE) {
                rollupOutline(node);
            }
        }
        for (RuleReport rule : report.getRules()) {
            for (ScenarioNode node : rule.getScenarios()) {
                if (node.getType() == ScenarioNode.Kind.SCENARIO_OUTLINE) {
                    rollupOutline(node);
                }
            }
        }
    }

    private static void rollupOutline(ScenarioNode outline) {
        long total = 0L;
        if (outline.getExamples() != null) {
            for (ExampleReport row : outline.getExamples()) {
                total += row.getDurationMs();
            }
        }
        outline.setTotalDurationMs(total);
    }

    private static void sortByLine(FeatureReport report) {
        Comparator<ScenarioNode> byLine = Comparator.comparing(
                ScenarioNode::getSourceLine, Comparator.nullsLast(Comparator.naturalOrder()));
        report.getScenarios().sort(byLine);
        report.getRules().sort(Comparator.comparing(
                RuleReport::getSourceLine, Comparator.nullsLast(Comparator.naturalOrder())));
        for (RuleReport rule : report.getRules()) {
            rule.getScenarios().sort(byLine);
        }
    }

    private static FeatureReport findFeatureReport(ExtensionContext context) {
        ExtensionContext root = featureRootContextOf(context);
        return root == null ? null : root.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
    }

    private static ExtensionContext featureRootContextOf(ExtensionContext context) {
        ExtensionContext ctx = context;
        ExtensionContext lastWithFeature = null;
        while (ctx != null) {
            if (ctx.getStore(NAMESPACE).get(KEY_FEATURE_REPORT) != null) {
                lastWithFeature = ctx;
                break;
            }
            ctx = ctx.getParent().orElse(null);
        }
        return lastWithFeature;
    }

    private static boolean isNestedRule(Class<?> testClass) {
        return testClass.isAnnotationPresent(Nested.class);
    }

    private static List<Class<?>> nestedTestClassesOf(Class<?> outer) {
        List<Class<?>> nested = new ArrayList<>();
        for (Class<?> declared : outer.getDeclaredClasses()) {
            if (declared.isAnnotationPresent(Nested.class)) {
                nested.add(declared);
            }
        }
        return nested;
    }

    private static String displayNameOf(Class<?> clazz) {
        DisplayName ann = clazz.getAnnotation(DisplayName.class);
        return (ann != null && !ann.value().isEmpty()) ? ann.value() : clazz.getSimpleName();
    }

    private static Long readSourceLine(Class<?> clazz) {
        SourceLine ann = clazz.getAnnotation(SourceLine.class);
        return ann == null ? null : ann.value();
    }

    private static Long readSourceLine(Method method) {
        SourceLine ann = method.getAnnotation(SourceLine.class);
        return ann == null ? null : ann.value();
    }

    private static String readScenarioHash(Method method) {
        ScenarioHash ann = method.getAnnotation(ScenarioHash.class);
        return ann == null ? null : ann.value();
    }

    /**
     * Stable Javadoc-style identifier — {@code fqcn#method}, where {@code fqcn} is
     * the JVM binary name (so nested-rule classes appear as {@code Outer$Rule_1}).
     * Outline templates and outline rows share the same id (the row distinction
     * lives in {@code examplesRow} and {@code rowHash}).
     */
    private static String formatTestId(Method method) {
        return method.getDeclaringClass().getName() + "#" + method.getName();
    }

    private static List<String> tagsOf(ExtensionContext context) {
        return new ArrayList<>(context.getTags());
    }

    /**
     * Walks the @Nested enclosing-class chain and the superclass chain looking for
     * {@link SourceFilePath}.
     */
    private static Optional<String> findSourceFilePath(Class<?> start) {
        Class<?> cls = start;
        while (cls != null) {
            SourceFilePath ann = cls.getAnnotation(SourceFilePath.class);
            if (ann != null) {
                return Optional.of(ann.value());
            }
            Class<?> next = cls.getEnclosingClass();
            if (next == null) {
                next = cls.getSuperclass();
            }
            cls = next;
        }
        return Optional.empty();
    }

    /**
     * Parse the leaf display name of a parameterized invocation produced by
     * {@code @CsvSource(useHeadersInDisplayName = true)} — format
     * {@code "Example {n}: [header = value, header = value, ...]"}.
     */
    static Map<String, String> parseExamplesRow(String displayName) {
        if (displayName == null) {
            return null;
        }
        int open = displayName.indexOf('[');
        int close = displayName.lastIndexOf(']');
        if (open < 0 || close <= open) {
            return null;
        }
        String inner = displayName.substring(open + 1, close);
        Map<String, String> row = new LinkedHashMap<>();
        for (String pair : inner.split(", ")) {
            int eq = pair.indexOf(" = ");
            if (eq < 0) {
                return null;
            }
            row.put(pair.substring(0, eq), pair.substring(eq + 3));
        }
        return row.isEmpty() ? null : row;
    }

    // ---- step buffer ----

    /**
     * Per-scenario in-flight step state: two pre-populated lists of expected
     * {@link StepReport}s — one for background steps, one for scenario steps —
     * plus a per-method-name queue of (list, index) cursors used to advance as
     * the instrumented overrides fire.
     */
    static final class ScenarioStepBuffer {
        private final List<StepReport> backgroundSteps;
        private final List<StepReport> scenarioSteps;
        private final Map<String, Deque<Cursor>> cursorsByMethod;
        private Cursor current;
        private long currentStepStartNanos;
        private final Instant scenarioStartedAt = Instant.now();
        private final long scenarioStartNanos = System.nanoTime();
        private long scenarioDurationMs = 0L;

        private ScenarioStepBuffer(List<StepReport> backgroundSteps,
                                   List<StepReport> scenarioSteps,
                                   Map<String, Deque<Cursor>> cursorsByMethod) {
            this.backgroundSteps = backgroundSteps;
            this.scenarioSteps = scenarioSteps;
            this.cursorsByMethod = cursorsByMethod;
        }

        static ScenarioStepBuffer preallocated(List<StepCallSiteScanner.Call> backgroundCalls,
                                               List<StepCallSiteScanner.Call> scenarioCalls) {
            List<StepReport> bg = new ArrayList<>(backgroundCalls.size());
            List<StepReport> sc = new ArrayList<>(scenarioCalls.size());
            Map<String, Deque<Cursor>> cursors = new HashMap<>();
            int i = 0;
            for (StepCallSiteScanner.Call call : backgroundCalls) {
                bg.add(StepReport.pending(call.methodName()));
                cursors.computeIfAbsent(call.methodName(), k -> new ArrayDeque<>())
                        .addLast(new Cursor(bg, i++));
            }
            i = 0;
            for (StepCallSiteScanner.Call call : scenarioCalls) {
                sc.add(StepReport.pending(call.methodName()));
                cursors.computeIfAbsent(call.methodName(), k -> new ArrayDeque<>())
                        .addLast(new Cursor(sc, i++));
            }
            return new ScenarioStepBuffer(bg, sc, cursors);
        }

        void started(String methodName, Object[] args) {
            Deque<Cursor> queue = cursorsByMethod.get(methodName);
            if (queue == null || queue.isEmpty()) {
                LOGGER.fine(() -> "SpecBinder reporter: unexpected step call to '" + methodName
                        + "' (not in pre-scanned plan); skipping.");
                current = null;
                return;
            }
            current = queue.pollFirst();
            StepReport step = current.step();
            if (args != null && args.length > 0) {
                step.setArguments(List.of(args));
            }
            step.setStartedAt(Instant.now());
            currentStepStartNanos = System.nanoTime();
        }

        void passed() {
            if (current == null) {
                return;
            }
            StepReport step = current.step();
            step.setStatus(Status.PASSED);
            step.setDurationMs(Duration.ofNanos(System.nanoTime() - currentStepStartNanos).toMillis());
            current = null;
        }

        void failed(Throwable throwable) {
            if (current == null) {
                return;
            }
            StepReport step = current.step();
            step.setStatus(statusFor(throwable));
            step.setDurationMs(Duration.ofNanos(System.nanoTime() - currentStepStartNanos).toMillis());
            step.setError(ErrorInfo.from(throwable));
            current = null;
        }

        private static Status statusFor(Throwable throwable) {
            return "org.opentest4j.TestAbortedException".equals(throwable.getClass().getName())
                    ? Status.ABORTED : Status.FAILED;
        }

        void finalizeDuration() {
            scenarioDurationMs = Duration.ofNanos(System.nanoTime() - scenarioStartNanos).toMillis();
        }

        List<StepReport> backgroundSnapshot() {
            return backgroundSteps;
        }

        List<StepReport> scenarioSnapshot() {
            return scenarioSteps;
        }

        Instant scenarioStartedAt() {
            return scenarioStartedAt;
        }

        long scenarioDurationMs() {
            return scenarioDurationMs;
        }

        private record Cursor(List<StepReport> list, int index) {
            StepReport step() {
                return list.get(index);
            }
        }
    }
}
