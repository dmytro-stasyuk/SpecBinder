package dev.specbinder.reporter;

import com.fasterxml.jackson.core.JsonProcessingException;
import dev.specbinder.annotations.output.Description;
import dev.specbinder.annotations.output.ScenarioHash;
import dev.specbinder.annotations.output.SourceFilePath;
import dev.specbinder.annotations.output.SourceLine;
import dev.specbinder.reporter.internal.InstrumentedClassFactory;
import dev.specbinder.reporter.internal.ScenarioHasher;
import dev.specbinder.reporter.internal.SourceFeatureReader;
import dev.specbinder.reporter.internal.SourceFeatureReader.ParsedFeature;
import dev.specbinder.reporter.internal.SourceFeatureReader.ParsedRule;
import dev.specbinder.reporter.internal.SourceFeatureReader.ParsedScenario;
import dev.specbinder.reporter.internal.SourceFeatureReader.StepBlockArgument;
import dev.specbinder.reporter.internal.StepCallSiteScanner;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.TestReporter;
import org.junit.jupiter.api.extension.*;

import java.io.IOException;
import java.lang.reflect.AnnotatedElement;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.nio.file.Path;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Consumer;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * JUnit 5 extension that captures hierarchical execution data for SpecBinder-generated
 * test classes — feature, rule, scenario, and per-step — and writes one JSON file per
 * feature under the project's build output directory.
 * <p>
 * Activate by placing {@code @ExtendWith(SpecBinderReporter.class)} on the marker
 * class consumed by {@code @Gherkin2JUnit}. Because {@code @ExtendWith} is meta-
 * annotated {@code @Inherited}, the extension fires automatically for every concrete
 * subclass JUnit discovers.
 * <p>
 * {@link TestReporter#publishEntry} calls made inside step bodies are routed into the
 * owning step's report through a dedicated {@code TestExecutionListener} auto-registered
 * via {@code ServiceLoader}; that listener forwards captured entries here via
 * {@link #recordPublishedEntry}, which is a no-op when no SpecBinder scenario is active
 * on the current thread.
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
    private static final String KEY_PARSED_INDEX = "parsedIndex";

    private static final ThreadLocal<ScenarioStepBuffer> CURRENT_BUFFER = new ThreadLocal<>();
    private static final ThreadLocal<Throwable> CURRENT_SCENARIO_ERROR = new ThreadLocal<>();

    private static final ReportWriter REPORT_WRITER = new ReportWriter();

    /**
     * Registered {@link ExecutionBoundaryListener}s, fanned out to at every feature/rule/
     * scenario/step boundary. Empty by default, so the reporter carries no observers unless
     * a consumer opts in. {@code CopyOnWriteArrayList} keeps iteration lock-free on the step
     * hot path and safe against concurrent (un)registration between test classes.
     */
    private static final List<ExecutionBoundaryListener> BOUNDARY_LISTENERS = new CopyOnWriteArrayList<>();

    // ---- boundary listener SPI (see ExecutionBoundaryListener) ----

    /**
     * Registers a listener to receive execution boundaries. Typically called from a test
     * project's own JUnit extension (which owns any per-run resource the listener needs, such
     * as a Playwright {@code BrowserContext}), and paired with
     * {@link #removeBoundaryListener(ExecutionBoundaryListener)} when that resource is torn
     * down. A {@code null} listener is ignored.
     */
    public static void addBoundaryListener(ExecutionBoundaryListener listener) {
        if (listener != null) {
            BOUNDARY_LISTENERS.add(listener);
        }
    }

    /** Unregisters a previously {@link #addBoundaryListener(ExecutionBoundaryListener) added} listener. */
    public static void removeBoundaryListener(ExecutionBoundaryListener listener) {
        BOUNDARY_LISTENERS.remove(listener);
    }

    /**
     * Dispatches {@code action} to every registered boundary listener, isolating each so a
     * misbehaving listener is logged and skipped rather than allowed to fail the test run or
     * corrupt the report. Returns immediately when no listeners are registered, so the common
     * (unobserved) case allocates nothing.
     */
    private static void fireBoundary(Consumer<ExecutionBoundaryListener> action) {
        if (BOUNDARY_LISTENERS.isEmpty()) {
            return;
        }
        for (ExecutionBoundaryListener listener : BOUNDARY_LISTENERS) {
            try {
                action.accept(listener);
            } catch (RuntimeException e) {
                LOGGER.log(Level.WARNING, "SpecBinder reporter: execution boundary listener threw; skipping it", e);
            }
        }
    }

    // ---- step interceptor entry points (called by ByteBuddy overrides) ----

    /** Invoked by an instrumented step override before delegating to {@code super}. */
    public static void stepStarting(String methodName, Object[] args) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        if (buffer != null) {
            buffer.started(methodName, args);
        }
        // Fast-path guard: the step hook fires for every SpecBinder run, so skip building the
        // boundary payload entirely when nobody is observing.
        if (!BOUNDARY_LISTENERS.isEmpty()) {
            String text = buffer != null ? buffer.currentText() : null;
            fireBoundary(l -> l.stepStarted(new ExecutionBoundaryListener.StepBoundary(methodName, text, null)));
        }
    }

    /** Invoked by an instrumented step override after the {@code super} call returns. */
    public static void stepPassed() {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        boolean observed = !BOUNDARY_LISTENERS.isEmpty();
        String methodName = (observed && buffer != null) ? buffer.currentMethodName() : null;
        String text = (observed && buffer != null) ? buffer.currentText() : null;
        if (buffer != null) {
            buffer.passed();
        }
        if (observed) {
            fireBoundary(l -> l.stepFinished(new ExecutionBoundaryListener.StepBoundary(methodName, text, Status.PASSED)));
        }
    }

    /** Invoked by an instrumented step override when the {@code super} call throws. */
    public static void stepFailed(Throwable throwable) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        boolean observed = !BOUNDARY_LISTENERS.isEmpty();
        String methodName = (observed && buffer != null) ? buffer.currentMethodName() : null;
        String text = (observed && buffer != null) ? buffer.currentText() : null;
        if (buffer != null) {
            buffer.failed(throwable);
        }
        if (observed) {
            Status status = "org.opentest4j.TestAbortedException".equals(throwable.getClass().getName())
                    ? Status.ABORTED : Status.FAILED;
            fireBoundary(l -> l.stepFinished(new ExecutionBoundaryListener.StepBoundary(methodName, text, status)));
        }
    }

    /**
     * Invoked by the SpecBinder Launcher listener whenever user step code calls
     * {@link TestReporter#publishEntry}. Attaches the entry to the currently running
     * step's {@link StepReport}. A no-op outside an active SpecBinder scenario, so the
     * listener can stay registered globally without affecting non-SpecBinder tests.
     */
    public static void recordPublishedEntry(Map<String, String> values, Instant publishedAt) {
        ScenarioStepBuffer buffer = CURRENT_BUFFER.get();
        if (buffer == null) {
            return;
        }
        buffer.appendEntryToCurrentStep(values, publishedAt);
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
            rule.setId(reportFqn(testClass, featureReport.getTestClass()));
            rule.setDisplayName(displayNameOf(testClass));
            rule.setDescription(readDescription(testClass));
            rule.setSourceLine(readSourceLine(testClass));
            featureReport.getRules().add(rule);
            store.put(KEY_RULE_REPORT, rule);

            StepCallSiteScanner.Plan plan = StepCallSiteScanner.scan(testClass);
            store.put(KEY_PLAN, plan);

            String ruleName = rule.getDisplayName();
            fireBoundary(l -> l.ruleStarted(new ExecutionBoundaryListener.RuleBoundary(ruleName)));
            return;
        }

        // Feature root.
        FeatureReport report = new FeatureReport();
        report.setSourceFilePath(sourceFilePath.get());
        report.setTestClass(testClass.getName());
        report.setDisplayName(featureDisplayNameOf(testClass));
        report.setDescription(readDescription(testClass));
        report.setExecutedAt(Instant.now());
        store.put(KEY_FEATURE_REPORT, report);
        store.put(KEY_SOURCE_FILE_PATH, sourceFilePath.get());
        store.put(KEY_FEATURE_START_NANOS, System.nanoTime());

        String featureName = report.getDisplayName();
        String featurePath = report.getSourceFilePath();
        fireBoundary(l -> l.featureStarted(new ExecutionBoundaryListener.FeatureBoundary(featureName, featurePath)));

        StepCallSiteScanner.Plan plan = StepCallSiteScanner.scan(testClass);
        store.put(KEY_PLAN, plan);

        // Build the instrumented subclass once, covering every step name discovered
        // on the feature root and on every @Nested rule member class — the same
        // outer instance is shared across direct tests and nested rule tests.
        Class<?> instrumented = buildInstrumentedClass(testClass);
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

    private static Class<?> lookupInstrumentedClass(ExtensionContext context, Class<?> testClass) {
        // Fast path: beforeAll already built and cached the instrumented subclass.
        ExtensionContext featureRoot = featureRootContextOf(context);
        if (featureRoot != null) {
            Class<?> stored = featureRoot.getStore(NAMESPACE).get(KEY_INSTRUMENTED_CLASS, Class.class);
            if (stored != null) {
                return stored;
            }
        }
        // Under @TestInstance(PER_CLASS) JUnit eagerly creates the test instance before
        // any BeforeAllCallback runs, so beforeAll has not yet stored the instrumented
        // class (and the feature report seeded there is likewise absent, so featureRoot
        // may be null). Build it on demand — InstrumentedClassFactory caches per concrete
        // class, so beforeAll's later build resolves to this same class. Only SpecBinder
        // feature classes are instrumented; anything else instantiates plainly, mirroring
        // the early return in beforeAll.
        if (findSourceFilePath(testClass).isEmpty()) {
            return testClass;
        }
        return buildInstrumentedClass(testClass);
    }

    /**
     * Builds (or returns the cached) ByteBuddy subclass of {@code testClass} that overrides
     * every step method discovered on the feature root and on every {@code @Nested} rule
     * member class — the same outer instance is shared across direct tests and nested rule
     * tests. Returns {@code testClass} unchanged when no step call sites are found.
     */
    private static Class<?> buildInstrumentedClass(Class<?> testClass) {
        Set<String> allStepNames = new LinkedHashSet<>(StepCallSiteScanner.scan(testClass).stepMethodNames());
        for (Class<?> nested : nestedTestClassesOf(testClass)) {
            allStepNames.addAll(StepCallSiteScanner.scan(nested).stepMethodNames());
        }
        return InstrumentedClassFactory.instrumentedSubclassOf(testClass, allStepNames);
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

        // Only observed runs need per-step Gherkin text at runtime; resolve it now (parsing the
        // spec once per feature, cached) so stepStarted can carry the real step line rather than
        // an approximation. Leaves text null when there is no @ScenarioHash to anchor the match.
        if (!BOUNDARY_LISTENERS.isEmpty()) {
            stampBufferStepText(featureRoot, context, testMethod, buffer);
        }

        ExecutionBoundaryListener.ScenarioBoundary scenarioBoundary = scenarioBoundaryOf(context);
        fireBoundary(l -> l.scenarioStarted(scenarioBoundary));
    }

    /**
     * Builds the {@link ExecutionBoundaryListener.ScenarioBoundary} for the current test method,
     * carrying its human display name plus the generated (rule-qualified, unique) test method name
     * and, for Scenario Outline invocations, the 1-based example-row index parsed from the JUnit
     * unique id.
     */
    private static ExecutionBoundaryListener.ScenarioBoundary scenarioBoundaryOf(ExtensionContext context) {
        String displayName = context.getDisplayName();
        String testMethodName = context.getTestMethod().map(Method::getName).orElse(null);
        return new ExecutionBoundaryListener.ScenarioBoundary(displayName, testMethodName, exampleRowIndexOf(context));
    }

    /**
     * The 1-based row number of a Scenario Outline invocation, parsed from the JUnit unique-id
     * segment {@code [test-template-invocation:#N]}, or {@code null} for a plain scenario.
     */
    private static Integer exampleRowIndexOf(ExtensionContext context) {
        String marker = "test-template-invocation:#";
        String uniqueId = context.getUniqueId();
        int at = uniqueId.lastIndexOf(marker);
        if (at < 0) {
            return null;
        }
        int start = at + marker.length();
        int end = start;
        while (end < uniqueId.length() && Character.isDigit(uniqueId.charAt(end))) {
            end++;
        }
        if (end == start) {
            return null;
        }
        try {
            return Integer.parseInt(uniqueId.substring(start, end));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Pre-populates the buffer's {@link StepReport}s with their verbatim Gherkin step lines so
     * the step boundary can report real text at runtime — the same spec-derived text the
     * {@code afterAll} stamping would later assign, resolved early via the same
     * {@code @ScenarioHash} integrity gate. A no-op (leaving text {@code null}) when the spec
     * can't be parsed, the scenario has no hash, or no parsed scenario matches it.
     */
    private static void stampBufferStepText(ExtensionContext featureRoot, ExtensionContext context,
                                            Method testMethod, ScenarioStepBuffer buffer) {
        ParsedIndex index = parsedIndex(featureRoot, context);
        if (index == null) {
            return;
        }
        String wantHash = readScenarioHash(testMethod);
        if (wantHash == null) {
            return;
        }
        ParsedScenario match = index.matchByHash(wantHash);
        if (match != null) {
            buffer.stampText(match.backgroundStepLines(), match.scenarioStepLines());
        }
    }

    /**
     * Returns the feature's parsed-scenario index (flattened scenarios + their canonical
     * hashes), parsing and caching it on the feature-root store on first use. Cached because
     * every scenario in the feature reuses it, and only built for observed runs (see the
     * caller's guard).
     */
    private static ParsedIndex parsedIndex(ExtensionContext featureRoot, ExtensionContext context) {
        if (featureRoot == null) {
            return null;
        }
        ExtensionContext.Store store = featureRoot.getStore(NAMESPACE);
        ParsedIndex existing = store.get(KEY_PARSED_INDEX, ParsedIndex.class);
        if (existing != null) {
            return existing;
        }
        String sourceFilePath = store.get(KEY_SOURCE_FILE_PATH, String.class);
        if (sourceFilePath == null) {
            return null;
        }
        ParsedFeature parsed = SourceFeatureReader.parse(
                sourceFilePath, context.getRequiredTestClass().getClassLoader());
        ParsedIndex index = ParsedIndex.of(parsed);
        store.put(KEY_PARSED_INDEX, index);
        return index;
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

        // Fire before the report-shaping early returns below so this always pairs with the
        // scenarioStarted emitted in beforeEach (both gated on the buffer being present),
        // keeping any listener's open-group stack balanced.
        ExecutionBoundaryListener.ScenarioBoundary scenarioBoundary = scenarioBoundaryOf(context);
        fireBoundary(l -> l.scenarioFinished(scenarioBoundary));

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
        node.setId(formatTestId(context.getRequiredTestClass(), testMethod, featureReport.getTestClass()));
        node.setDisplayName(context.getDisplayName());
        node.setDescription(readDescription(testMethod));
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
        node.setId(formatTestId(context.getRequiredTestClass(), testMethod, featureReport.getTestClass()));
        node.setDisplayName(context.getDisplayName());
        node.setDescription(readDescription(testMethod));
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
        // JUnit fires afterAll once for the outer test class and once for every @Nested
        // Rule class. Since Store#get walks parent stores, the FeatureReport seeded on
        // the outer context is visible from every @Nested context too — so a null-only
        // guard isn't enough. Skip @Nested contexts explicitly; only the outer afterAll
        // finalises, stamps, and writes the report. Without this guard, stamping runs
        // N times for a feature with N-1 @Nested Rules, and argument-envelope wrapping
        // accumulates (each pass wraps the previously wrapped entries again).
        if (context.getTestClass().filter(SpecBinderReporter::isNestedRule).isPresent()) {
            RuleReport rule = context.getStore(NAMESPACE).get(KEY_RULE_REPORT, RuleReport.class);
            if (rule != null) {
                String ruleName = rule.getDisplayName();
                fireBoundary(l -> l.ruleFinished(new ExecutionBoundaryListener.RuleBoundary(ruleName)));
            }
            return;
        }
        ExtensionContext.Store store = context.getStore(NAMESPACE);
        FeatureReport featureReport = store.get(KEY_FEATURE_REPORT, FeatureReport.class);
        if (featureReport == null) {
            return;
        }
        Long startNanos = store.get(KEY_FEATURE_START_NANOS, Long.class);
        if (startNanos != null) {
            featureReport.setTotalDurationMs(Duration.ofNanos(System.nanoTime() - startNanos).toMillis());
        }

        finalizeOutlineNodes(featureReport);
        sortByLine(featureReport);
        stampStepTexts(featureReport, context.getRequiredTestClass().getClassLoader());

        // Fire feature-finished before the disk-write early return so it always pairs with the
        // feature-started emitted in beforeAll, regardless of whether a report directory resolved.
        String featureName = featureReport.getDisplayName();
        String featurePath = featureReport.getSourceFilePath();
        fireBoundary(l -> l.featureFinished(new ExecutionBoundaryListener.FeatureBoundary(featureName, featurePath)));

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
        ExtensionContext featureRoot = featureRootContextOf(rowContext);
        FeatureReport featureReport = featureRoot.getStore(NAMESPACE).get(KEY_FEATURE_REPORT, FeatureReport.class);
        ScenarioNode outline = ScenarioNode.outline();
        outline.setId(formatTestId(rowContext.getRequiredTestClass(), testMethod, featureReport.getTestClass()));
        outline.setDisplayName(deriveOutlineDisplayName(methodCtx, testMethod));
        outline.setDescription(readDescription(testMethod));
        outline.setSourceLine(readSourceLine(testMethod));
        outline.setScenarioHash(readScenarioHash(testMethod));
        outline.setTags(tagsOf(methodCtx));
        methodStore.put(KEY_OUTLINE_NODE, outline);

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
        Status worst = null;
        if (outline.getExamples() != null) {
            for (ExampleReport row : outline.getExamples()) {
                total += row.getDurationMs();
                worst = worstOf(worst, row.getStatus());
            }
        }
        outline.setTotalDurationMs(total);
        outline.setStatus(worst);
    }

    /**
     * Rolls two example-row statuses up to the "worse" of the pair, worst-first:
     * failed &gt; aborted &gt; skipped &gt; passed. So an outline reports failed if any row
     * failed, else aborted if any row aborted, else skipped if any row was skipped,
     * else passed — an all-passing outline reads as passed rather than not-executed.
     */
    private static Status worstOf(Status current, Status candidate) {
        if (candidate == null) {
            return current;
        }
        if (current == null || severity(candidate) > severity(current)) {
            return candidate;
        }
        return current;
    }

    private static int severity(Status status) {
        return switch (status) {
            case FAILED -> 3;
            case ABORTED -> 2;
            case SKIPPED -> 1;
            case PASSED -> 0;
        };
    }

    /**
     * Stamps each step's original Gherkin {@code "<keyword> <text>"} line onto the
     * corresponding {@link StepReport}, gated by {@code @ScenarioHash} integrity.
     * <p>
     * Pairs runtime {@link ScenarioNode}s with parsed spec scenarios by position — both
     * lists are in source order (the report's by execution {@code @Order} or by
     * {@code @SourceLine} sort, the parser's by file order). Within each pair the recorded
     * {@code @ScenarioHash} is compared to the canonical hash recomputed from the parsed
     * spec; on match the spec's step lines are stamped onto the report. On mismatch the
     * code falls back to a linear scan for any parsed scenario whose hash matches —
     * recovering from inserts/deletes/reorders while still rejecting drifted scenarios.
     * Unmatched or unhashed scenarios stay null-{@code text} and are omitted via
     * {@code @JsonInclude(NON_NULL)}.
     */
    private static void stampStepTexts(FeatureReport report, ClassLoader classLoader) {
        ParsedFeature parsed = SourceFeatureReader.parse(report.getSourceFilePath(), classLoader);
        List<ParsedScenario> parsedFlat = new ArrayList<>(parsed.scenarios());
        for (ParsedRule rule : parsed.rules()) {
            parsedFlat.addAll(rule.scenarios());
        }
        if (parsedFlat.isEmpty()) {
            return;
        }

        // Precompute hashes once: avoids O(n²) recomputation when the linear-scan
        // fallback kicks in.
        List<String> parsedHashes = new ArrayList<>(parsedFlat.size());
        for (ParsedScenario p : parsedFlat) {
            parsedHashes.add(ScenarioHasher.hash(p.canonicalSteps()));
        }

        List<ScenarioNode> runtimeFlat = new ArrayList<>(report.getScenarios());
        for (RuleReport rule : report.getRules()) {
            runtimeFlat.addAll(rule.getScenarios());
        }

        for (int i = 0; i < runtimeFlat.size(); i++) {
            ScenarioNode node = runtimeFlat.get(i);
            String wantHash = node.getScenarioHash();
            if (wantHash == null) {
                continue;
            }
            ParsedScenario match = null;
            if (i < parsedFlat.size() && wantHash.equals(parsedHashes.get(i))) {
                match = parsedFlat.get(i);
            } else {
                for (int j = 0; j < parsedFlat.size(); j++) {
                    if (j != i && wantHash.equals(parsedHashes.get(j))) {
                        match = parsedFlat.get(j);
                        break;
                    }
                }
            }
            if (match != null) {
                stampMatchedScenario(node, match);
            } else {
                LOGGER.fine(() -> "SpecBinder reporter: no spec scenario matches @ScenarioHash for "
                        + node.getId() + "; step text omitted.");
            }
        }
    }

    private static void stampMatchedScenario(ScenarioNode node, ParsedScenario parsed) {
        if (node.getType() == ScenarioNode.Kind.SCENARIO_OUTLINE) {
            if (node.getExamples() != null) {
                for (ExampleReport row : node.getExamples()) {
                    stampSteps(row.getBackgroundSteps(), parsed.backgroundStepLines());
                    stampSteps(row.getSteps(), parsed.scenarioStepLines());
                    enrichArguments(row.getBackgroundSteps(), parsed.backgroundBlockArgs());
                    enrichArguments(row.getSteps(), parsed.scenarioBlockArgs());
                }
                stampOutlineTemplateSteps(node, parsed);
            }
        } else {
            stampSteps(node.getBackgroundSteps(), parsed.backgroundStepLines());
            stampSteps(node.getSteps(), parsed.scenarioStepLines());
            enrichArguments(node.getBackgroundSteps(), parsed.backgroundBlockArgs());
            enrichArguments(node.getSteps(), parsed.scenarioBlockArgs());
            synthesizeSkippedArguments(node.getBackgroundSteps(), parsed.backgroundBlockArgs());
            synthesizeSkippedArguments(node.getSteps(), parsed.scenarioBlockArgs());
        }
    }

    private static void stampSteps(List<StepReport> steps, List<String> stepLines) {
        if (steps == null || stepLines == null) {
            return;
        }
        int bound = Math.min(steps.size(), stepLines.size());
        for (int i = 0; i < bound; i++) {
            steps.get(i).setText(stepLines.get(i));
        }
    }

    /**
     * Populates an outline's {@code templateSteps} — a single de-duplicated view of the
     * Scenario Outline's own steps as they appear in the spec, with their {@code <>}
     * placeholders intact. The method names come from any example row (identical across
     * rows), the text from the parsed scenario step lines; background steps are excluded.
     * A step whose spec carries a trailing DocString or DataTable also gets that block as a
     * typed {@code arguments} entry in template form — placeholders intact, sourced from the
     * spec rather than a single row's substituted runtime value (see
     * {@link #buildTemplateBlockArgument(StepBlockArgument)}). Runs only when the
     * scenario-hash gate matched (same trust guarantee as step text).
     */
    private static void stampOutlineTemplateSteps(ScenarioNode node, ParsedScenario parsed) {
        List<ExampleReport> examples = node.getExamples();
        List<String> stepLines = parsed.scenarioStepLines();
        if (examples == null || examples.isEmpty() || stepLines == null) {
            return;
        }
        List<StepReport> rowSteps = examples.get(0).getSteps();
        if (rowSteps == null) {
            return;
        }
        List<StepBlockArgument> blockArgs = parsed.scenarioBlockArgs();
        int bound = Math.min(rowSteps.size(), stepLines.size());
        List<StepReport> templateSteps = new ArrayList<>(bound);
        for (int i = 0; i < bound; i++) {
            StepReport templateStep = StepReport.template(rowSteps.get(i).getMethodName(), stepLines.get(i));
            if (blockArgs != null && i < blockArgs.size()) {
                Object templateArg = buildTemplateBlockArgument(blockArgs.get(i));
                if (templateArg != null) {
                    templateStep.setArguments(new ArrayList<>(List.of(templateArg)));
                }
            }
            templateSteps.add(templateStep);
        }
        node.setTemplateSteps(templateSteps);
    }

    /**
     * Builds the single {@code arguments} entry for an outline {@code templateSteps} step from
     * the parsed spec block. The template describes the outline itself — no runtime object is
     * bound to it — so DocStrings and DataTables surface with their {@code <>} placeholders
     * intact, taken verbatim from the spec. DataTables reuse the spec-only shape
     * ({@link #buildDataTableArgFromSpec}): header strings as row keys and no {@code columns},
     * since there is no runtime POJO to pair header names against. Returns {@code null} for a
     * step with no trailing block argument.
     */
    private static Object buildTemplateBlockArgument(StepBlockArgument blockArg) {
        return switch (blockArg.kind()) {
            case DOC_STRING -> buildDocStringArg(blockArg.docStringValue(), blockArg.docStringMediaType());
            case DATA_TABLE -> buildDataTableArgFromSpec(blockArg.dataTableHeaders(), blockArg.dataTableBodyRows());
            case NONE -> null;
        };
    }

    /**
     * Wraps each captured runtime argument with a {@code {type, value, ...}} envelope so
     * downstream consumers can distinguish {@code simple} inline values from {@code docString}
     * payloads and {@code dataTable} rows without inspecting the spec themselves. Runs after
     * {@link #stampSteps(List, List)} when the scenario-hash matches the parsed spec (same
     * gate as text stamping). Positional rule: the last argument of a step is the block arg
     * (DocString or DataTable) when the spec carries one; earlier arguments are {@code simple}.
     * For DataTables built from row POJOs, the wrapper also surfaces a {@code columns} array
     * that pairs each spec-verbatim header with the POJO field name used as the row's JSON key.
     */
    private static void enrichArguments(List<StepReport> steps, List<StepBlockArgument> blockArgs) {
        if (steps == null || blockArgs == null) {
            return;
        }
        int bound = Math.min(steps.size(), blockArgs.size());
        for (int i = 0; i < bound; i++) {
            StepReport step = steps.get(i);
            List<Object> args = step.getArguments();
            if (args == null || args.isEmpty() || alreadyEnriched(args)) {
                continue;
            }
            StepBlockArgument blockArg = blockArgs.get(i);
            List<Object> wrapped = new ArrayList<>(args.size());
            int lastIndex = args.size() - 1;
            for (int j = 0; j < args.size(); j++) {
                Object value = args.get(j);
                boolean isLast = (j == lastIndex);
                if (isLast && blockArg.kind() == StepBlockArgument.BlockKind.DOC_STRING) {
                    wrapped.add(buildDocStringArg(value, blockArg.docStringMediaType()));
                } else if (isLast && blockArg.kind() == StepBlockArgument.BlockKind.DATA_TABLE) {
                    wrapped.add(buildDataTableArg(value, blockArg.dataTableHeaders()));
                } else {
                    wrapped.add(buildSimpleArg(value));
                }
            }
            step.setArguments(wrapped);
        }
    }

    /**
     * Populates {@link StepReport#getArguments()} for steps that {@link #enrichArguments}
     * left empty — these are the skipped steps that come after a failing step, so the
     * interceptor never fired to record actual runtime values. The synthesized entries are
     * built entirely from the parsed spec: inline quoted values are re-extracted from the
     * already-stamped step text using the same regex the annotation processor uses, and
     * any trailing DocString/DataTable comes from the parsed {@link StepBlockArgument}.
     * <p>
     * Outline rows are intentionally excluded by the caller — their spec text carries
     * {@code <placeholder>} tokens rather than the per-example values, so synthesis would
     * be misleading. Only invoked from the non-outline branch of {@link #stampMatchedScenario}.
     */
    private static void synthesizeSkippedArguments(List<StepReport> steps, List<StepBlockArgument> blockArgs) {
        if (steps == null || blockArgs == null) {
            return;
        }
        int bound = Math.min(steps.size(), blockArgs.size());
        for (int i = 0; i < bound; i++) {
            StepReport step = steps.get(i);
            List<Object> existing = step.getArguments();
            if (existing != null && !existing.isEmpty()) {
                continue;
            }
            List<Object> synthesized = new ArrayList<>();
            String text = step.getText();
            if (text != null) {
                Matcher m = INLINE_PARAM_PATTERN.matcher(text);
                while (m.find()) {
                    synthesized.add(buildSimpleArg(m.group("parameterValue")));
                }
            }
            StepBlockArgument block = blockArgs.get(i);
            if (block.kind() == StepBlockArgument.BlockKind.DOC_STRING) {
                synthesized.add(buildDocStringArg(block.docStringValue(), block.docStringMediaType()));
            } else if (block.kind() == StepBlockArgument.BlockKind.DATA_TABLE) {
                synthesized.add(buildDataTableArgFromSpec(
                        block.dataTableHeaders(), block.dataTableBodyRows()));
            }
            if (!synthesized.isEmpty()) {
                step.setArguments(synthesized);
            }
        }
    }

    /**
     * Inline simple-parameter regex; mirrors {@code CompositeStepProcessor.parameterPattern} on
     * the annotation-processor side. Matches a double-quoted run that may contain backslash
     * escapes — kept in lockstep with the processor so the two emit the same parameter list
     * for the same step text.
     */
    private static final Pattern INLINE_PARAM_PATTERN =
            Pattern.compile("(?<parameter>(\")(?<parameterValue>([^\"\\\\]|\\\\.)+?)(\"))");

    /**
     * DataTable {@code arguments[]} entry built from the spec alone. Uses each header as the
     * row's JSON key (the runtime path uses the POJO field name, which isn't available here
     * because no step body ever ran). Omits {@code columns} to keep the difference between
     * a synthesized and a runtime-captured table visible to consumers — runtime tables carry
     * {@code columns} only when a POJO row type was bound.
     */
    private static Map<String, Object> buildDataTableArgFromSpec(List<String> headers,
                                                                  List<List<String>> bodyRows) {
        LinkedHashMap<String, Object> entry = new LinkedHashMap<>();
        entry.put("type", "dataTable");
        List<Map<String, String>> value = new ArrayList<>();
        if (headers != null && !headers.isEmpty() && bodyRows != null) {
            for (List<String> row : bodyRows) {
                LinkedHashMap<String, String> rowMap = new LinkedHashMap<>();
                int n = Math.min(headers.size(), row.size());
                for (int i = 0; i < n; i++) {
                    rowMap.put(headers.get(i), row.get(i));
                }
                value.add(rowMap);
            }
        }
        entry.put("value", value);
        return entry;
    }

    private static final Set<String> ARG_TYPE_DISCRIMINATORS = Set.of("simple", "docString", "dataTable");

    /**
     * Defensive idempotency check: returns true if the first non-null entry is already a
     * {@code {type: <discriminator>, ...}} envelope, indicating this step's arguments have
     * already been wrapped. The {@code afterAll} guard alone should make this unreachable,
     * but keeping the check ensures that any future code path that drives stamping more
     * than once cannot produce nested-wrapper accumulation.
     */
    private static boolean alreadyEnriched(List<Object> args) {
        for (Object o : args) {
            if (o == null) continue;
            return o instanceof Map<?, ?> m
                    && m.get("type") instanceof String type
                    && ARG_TYPE_DISCRIMINATORS.contains(type);
        }
        return false;
    }

    private static Map<String, Object> buildSimpleArg(Object value) {
        LinkedHashMap<String, Object> m = new LinkedHashMap<>();
        m.put("type", "simple");
        m.put("value", value);
        return m;
    }

    private static Map<String, Object> buildDocStringArg(Object value, String mediaType) {
        LinkedHashMap<String, Object> m = new LinkedHashMap<>();
        m.put("type", "docString");
        if (mediaType != null && !mediaType.isBlank()) {
            m.put("mediaType", mediaType);
        }
        m.put("value", value);
        return m;
    }

    private static Map<String, Object> buildDataTableArg(Object value, List<String> headers) {
        LinkedHashMap<String, Object> m = new LinkedHashMap<>();
        m.put("type", "dataTable");
        List<Map<String, String>> columns = buildColumns(value, headers);
        if (columns != null && !columns.isEmpty()) {
            m.put("columns", columns);
        }
        m.put("value", value);
        return m;
    }

    /**
     * Pairs each source-order header with the matching field name on the runtime row POJOs.
     * Field name comes from {@link Class#getDeclaredFields()} in declaration order — SpecBinder's
     * generated POJO declares fields in source-column order so position-based pairing is faithful.
     * Returns {@code null} (omit {@code columns}) when there are no headers in the spec
     * (headerless table) or when the runtime value is empty or not a list of POJO rows.
     */
    private static List<Map<String, String>> buildColumns(Object value, List<String> headers) {
        if (headers == null || headers.isEmpty()) {
            return null;
        }
        if (!(value instanceof List<?> rows) || rows.isEmpty()) {
            return null;
        }
        Object firstRow = rows.get(0);
        if (firstRow == null) {
            return null;
        }
        List<String> fieldNames = new ArrayList<>();
        for (java.lang.reflect.Field f : firstRow.getClass().getDeclaredFields()) {
            if (java.lang.reflect.Modifier.isStatic(f.getModifiers())) continue;
            fieldNames.add(f.getName());
        }
        if (fieldNames.isEmpty()) {
            return null;
        }
        int n = Math.min(headers.size(), fieldNames.size());
        List<Map<String, String>> columns = new ArrayList<>(n);
        for (int i = 0; i < n; i++) {
            LinkedHashMap<String, String> col = new LinkedHashMap<>();
            col.put("header", headers.get(i));
            col.put("field", fieldNames.get(i));
            columns.add(col);
        }
        return columns;
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
        // Walk the superclass chain so that @Nested rule classes declared on a
        // SpecBinder abstract intermediate are picked up when the runtime test class
        // is the user-written concrete subclass. Stops at Object and JDK
        // infrastructure packages — those can't declare SpecBinder rule classes.
        List<Class<?>> nested = new ArrayList<>();
        Class<?> cls = outer;
        while (cls != null && !isInfrastructureClass(cls)) {
            for (Class<?> declared : cls.getDeclaredClasses()) {
                if (declared.isAnnotationPresent(Nested.class)) {
                    nested.add(declared);
                }
            }
            cls = cls.getSuperclass();
        }
        return nested;
    }

    private static boolean isInfrastructureClass(Class<?> cls) {
        if (cls == Object.class) {
            return true;
        }
        String name = cls.getName();
        return name.startsWith("java.")
                || name.startsWith("javax.")
                || name.startsWith("jdk.");
    }

    private static String displayNameOf(Class<?> clazz) {
        DisplayName ann = clazz.getAnnotation(DisplayName.class);
        return (ann != null && !ann.value().isEmpty()) ? ann.value() : clazz.getSimpleName();
    }

    /**
     * Resolves the Feature title for the report by walking the enclosing-class and
     * superclass chain of the JUnit test class, returning the {@link DisplayName}
     * value from the first class encountered that also carries
     * {@link SourceFilePath} — i.e. the SpecBinder-generated class. This makes the
     * report's top-level display name reflect the Gherkin Feature line regardless
     * of whether SpecBinder runs in concrete or abstract generation mode.
     */
    private static String featureDisplayNameOf(Class<?> start) {
        Class<?> cls = start;
        while (cls != null) {
            if (cls.getAnnotation(SourceFilePath.class) != null) {
                DisplayName ann = cls.getAnnotation(DisplayName.class);
                if (ann != null && !ann.value().isEmpty()) {
                    return ann.value();
                }
            }
            Class<?> next = cls.getEnclosingClass();
            if (next == null) {
                next = cls.getSuperclass();
            }
            cls = next;
        }
        return displayNameOf(start);
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

    private static String readDescription(AnnotatedElement element) {
        Description ann = element.getAnnotation(Description.class);
        return ann == null ? null : ann.value().strip();
    }

    /**
     * Stable Javadoc-style identifier — {@code fqcn#method}, where {@code fqcn} is
     * the JVM binary name of the runtime test class JUnit actually ran (so nested-rule
     * classes appear as {@code Outer$Rule_1}, and a user-written concrete subclass
     * that inherits an abstract-mode SpecBinder {@code @Test} method appears as the
     * concrete subclass, not the inherited declarer).
     * <p>
     * In SpecBinder's abstract generation mode the {@code @Nested} rule classes are
     * declared on the generated abstract intermediate (so {@code testClass.getName()}
     * reports {@code …Scenarios$Rule_1}). {@link #reportFqn} substitutes the outer
     * class with {@code featureRootFqn} — the concrete subclass JUnit actually ran —
     * so the emitted id anchors on the user-facing class hierarchy.
     * <p>
     * Outline templates and outline rows share the same id (the row distinction
     * lives in {@code examplesRow} and {@code rowHash}).
     */
    private static String formatTestId(Class<?> testClass, Method method, String featureRootFqn) {
        return reportFqn(testClass, featureRootFqn) + "#" + method.getName();
    }

    /**
     * Returns the FQN used to identify {@code testClass} in the emitted report, with
     * the outer class portion rewritten to {@code featureRootFqn} so that nested
     * classes declared on a SpecBinder abstract intermediate appear under the
     * concrete subclass JUnit ran (e.g. {@code Scenarios$Rule_1} → {@code Test$Rule_1}).
     * Returns {@code testClass.getName()} unchanged when there is no useful root to
     * substitute against.
     */
    static String reportFqn(Class<?> testClass, String featureRootFqn) {
        String declared = testClass.getName();
        if (featureRootFqn == null || declared.equals(featureRootFqn)) {
            return declared;
        }
        int dollar = declared.indexOf('$');
        if (dollar < 0) {
            // Top-level class on the inheritance chain of the feature root — treat
            // it as the root itself.
            return featureRootFqn;
        }
        return featureRootFqn + declared.substring(dollar);
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
     * {@code "Example: [header = value, header = value, ...]"}. Only the
     * bracketed segment is used, so the leading label is irrelevant.
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

    /**
     * A feature's parsed scenarios flattened to source order (feature-level first, then each
     * Rule's), paired with their precomputed canonical {@code @ScenarioHash}es. Lets
     * {@code beforeEach} resolve the running scenario's spec counterpart by hash so its step
     * lines can be stamped onto the buffer before any step fires. Built once per feature and
     * cached on the feature-root store.
     */
    private record ParsedIndex(List<ParsedScenario> scenarios, List<String> hashes) {

        static ParsedIndex of(ParsedFeature parsed) {
            List<ParsedScenario> flat = new ArrayList<>(parsed.scenarios());
            for (ParsedRule rule : parsed.rules()) {
                flat.addAll(rule.scenarios());
            }
            List<String> hashes = new ArrayList<>(flat.size());
            for (ParsedScenario scenario : flat) {
                hashes.add(ScenarioHasher.hash(scenario.canonicalSteps()));
            }
            return new ParsedIndex(flat, hashes);
        }

        /** First parsed scenario whose canonical hash equals {@code wantHash}, or {@code null}. */
        ParsedScenario matchByHash(String wantHash) {
            for (int i = 0; i < scenarios.size(); i++) {
                if (wantHash.equals(hashes.get(i))) {
                    return scenarios.get(i);
                }
            }
            return null;
        }
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
            List<Object> reportableArgs = filterOutResolvedFrameworkArgs(args);
            if (!reportableArgs.isEmpty()) {
                step.setArguments(reportableArgs);
            }
            step.setStartedAt(Instant.now());
            currentStepStartNanos = System.nanoTime();
        }

        /**
         * Drops JUnit-resolved framework arguments (currently {@link TestReporter}) so
         * Jackson never tries to serialize their internals — JUnit's
         * {@code DefaultTestReporter} carries an {@code Optional<ExtensionContext>} that
         * the default ObjectMapper cannot handle, and it would not be meaningful
         * diagnostic content anyway.
         */
        private static List<Object> filterOutResolvedFrameworkArgs(Object[] args) {
            if (args == null || args.length == 0) {
                return List.of();
            }
            List<Object> kept = new ArrayList<>(args.length);
            for (Object arg : args) {
                if (arg instanceof TestReporter) {
                    continue;
                }
                kept.add(arg);
            }
            return kept;
        }

        /**
         * The method name of the step currently in flight, or {@code null} when no step is
         * active (e.g. an unexpected call not in the pre-scanned plan). Read before
         * {@link #passed()} / {@link #failed(Throwable)} clears {@code current}.
         */
        String currentMethodName() {
            return current == null ? null : current.step().getMethodName();
        }

        /**
         * The verbatim Gherkin line of the step currently in flight, if it was stamped by
         * {@link #stampText(List, List)}; {@code null} otherwise. Read before
         * {@link #passed()} / {@link #failed(Throwable)} clears {@code current}.
         */
        String currentText() {
            return current == null ? null : current.step().getText();
        }

        /**
         * Assigns the spec's background and scenario step lines onto the pre-allocated
         * {@link StepReport}s positionally, so a boundary listener can read real step text as
         * each step fires. Idempotent with the later {@code afterAll} stamping (same source,
         * same values); a shorter list simply leaves the surplus reports' text {@code null}.
         */
        void stampText(List<String> backgroundLines, List<String> scenarioLines) {
            stampInto(backgroundSteps, backgroundLines);
            stampInto(scenarioSteps, scenarioLines);
        }

        private static void stampInto(List<StepReport> steps, List<String> lines) {
            if (steps == null || lines == null) {
                return;
            }
            int bound = Math.min(steps.size(), lines.size());
            for (int i = 0; i < bound; i++) {
                steps.get(i).setText(lines.get(i));
            }
        }

        void appendEntryToCurrentStep(Map<String, String> values, Instant publishedAt) {
            if (current == null) {
                return;
            }
            current.step().appendPublishedReporterEntry(
                    new PublishedReporterEntry(publishedAt, values));
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
