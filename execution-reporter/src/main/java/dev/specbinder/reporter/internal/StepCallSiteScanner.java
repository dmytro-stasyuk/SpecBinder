package dev.specbinder.reporter.internal;

import dev.specbinder.annotations.output.SourceFilePath;
import net.bytebuddy.dynamic.ClassFileLocator;
import net.bytebuddy.jar.asm.*;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.*;

/**
 * Walks the bytecode of a generated SpecBinder test class to discover the ordered
 * sequence of step methods invoked by each {@code @Test} / {@code @ParameterizedTest}
 * method body and each {@code @BeforeEach} method body. SpecBinder's annotation
 * processor emits linear method bodies (no conditionals or loops), so bytecode
 * order equals execution order.
 * <p>
 * Per scan: produces a {@link Plan} with one ordered list per scenario method plus
 * a single ordered list of background calls. {@code @Nested} rule classes are scanned
 * separately by the caller (their plans extend the feature-root plan additively).
 * <p>
 * A composite step's call is passed a lambda that calls its sub-steps. The lambda's body
 * compiles to a synthetic method of the same class, so the scanner follows the lambda there
 * and records the calls it makes as the composite step call's {@link Call#subCalls()}.
 */
public final class StepCallSiteScanner {

    private static final int ASM_API = Opcodes.ASM9;
    private static final String LAMBDA_METAFACTORY = "java/lang/invoke/LambdaMetafactory";
    private static final String LAMBDA_METHOD_PREFIX = "lambda$";

    /** A single bytecode call site: invoked method name, plus the sub-step calls of a composite step. */
    public static final class Call {
        private final String methodName;
        private final List<Call> subCalls;

        public Call(String methodName) {
            this(methodName, null);
        }

        public Call(String methodName, List<Call> subCalls) {
            this.methodName = methodName;
            this.subCalls = subCalls;
        }

        public String methodName() {
            return methodName;
        }

        /**
         * The calls the lambda passed to this call makes — a composite step's sub-steps, in spec
         * order — or {@code null} for a call passed no lambda, such as a regular step's.
         */
        public List<Call> subCalls() {
            return subCalls;
        }
    }

    /** Result of scanning one class. */
    public static final class Plan {
        private final List<Call> backgroundCalls;
        private final Map<String, List<Call>> scenarioCallsByMethod;
        private final Set<String> stepMethodNames;

        public Plan(List<Call> backgroundCalls,
                    Map<String, List<Call>> scenarioCallsByMethod,
                    Set<String> stepMethodNames) {
            this.backgroundCalls = backgroundCalls;
            this.scenarioCallsByMethod = scenarioCallsByMethod;
            this.stepMethodNames = stepMethodNames;
        }

        /** Step calls inside the scanned class's {@code @BeforeEach} bodies. */
        public List<Call> backgroundCalls() {
            return backgroundCalls;
        }

        /** Ordered scenario step calls for the given test method, or empty if not scanned. */
        public List<Call> scenarioCallsFor(Method testMethod) {
            List<Call> calls = scenarioCallsByMethod.get(keyOf(testMethod));
            return calls == null ? Collections.emptyList() : calls;
        }

        /** Names of every method discovered as a step call site. */
        public Set<String> stepMethodNames() {
            return stepMethodNames;
        }

        static String keyOf(Method method) {
            return method.getName() + descriptorOf(method);
        }
    }

    private StepCallSiteScanner() {
    }

    /**
     * Scan the bytecode of {@code testClass} and every scannable superclass up the
     * inheritance chain. Walking the chain matters in SpecBinder's abstract generation
     * mode: the {@code @Test} method bodies and {@code @BeforeEach} methods live on the
     * generated abstract intermediate class, and JUnit invokes them through the
     * user-written concrete subclass it actually runs.
     * <p>
     * Visiting top-down (most-distant scannable ancestor first, then each subclass in
     * turn) gives the desired semantics: {@code @BeforeEach} calls accumulate in
     * JUnit's invocation order (parent first, then child), and a child-class override
     * of a {@code @Test} method replaces any earlier entry recorded for the same
     * name + descriptor so the most-derived body is what ends up in the plan.
     * <p>
     * Class bytes are located via each class's own loader, which works for classes
     * loaded from regular JARs, exploded directories, and dynamically-compiled test
     * fixtures.
     */
    public static Plan scan(Class<?> testClass) {
        List<Call> backgroundCalls = new ArrayList<>();
        Map<String, List<Call>> scenarioCallsByMethod = new HashMap<>();
        Set<String> stepMethodNames = new LinkedHashSet<>();

        List<Class<?>> chainTopDown = new ArrayList<>();
        for (Class<?> c = testClass; c != null && !isInfrastructureClass(c); c = c.getSuperclass()) {
            chainTopDown.add(0, c);
        }

        for (Class<?> cls : chainTopDown) {
            ClassFileLocator locator = ClassFileLocator.ForClassLoader.of(cls.getClassLoader());
            byte[] bytes;
            try {
                bytes = locator.locate(cls.getName()).resolve();
            } catch (IOException e) {
                throw new IllegalStateException(
                        "SpecBinder reporter failed to read bytecode for " + cls.getName(), e);
            }
            boolean generated = isGeneratedTestClass(cls);
            new ClassReader(bytes).accept(
                    new ScanningClassVisitor(generated, internalNameOf(cls), selfAndEnclosingInternalNames(cls),
                            backgroundCalls, scenarioCallsByMethod, stepMethodNames),
                    ClassReader.SKIP_FRAMES);
        }

        return new Plan(backgroundCalls, scenarioCallsByMethod, stepMethodNames);
    }

    private static String internalNameOf(Class<?> cls) {
        return cls.getName().replace('.', '/');
    }

    /**
     * The classes a sub-step lambda in {@code cls} calls step methods on: {@code cls} itself, and
     * for a {@code @Nested} rule class the classes enclosing it, whose step methods it calls
     * through its outer instance. Calls on anything else — such as a data table row's accessor
     * passing a cell to a sub-step — are not steps.
     */
    private static Set<String> selfAndEnclosingInternalNames(Class<?> cls) {
        Set<String> names = new HashSet<>();
        for (Class<?> c = cls; c != null; c = c.getEnclosingClass()) {
            names.add(internalNameOf(c));
        }
        return names;
    }

    /**
     * A class contributes Gherkin <em>Background</em> steps only if it is a SpecBinder-generated
     * test class — i.e. it (or an enclosing class, for {@code @Nested} rule classes) carries the
     * generated {@link SourceFilePath} annotation. This excludes hand-written infrastructure
     * {@code @BeforeEach} lifecycle methods on base/marker classes (e.g. a {@code setUp()} that
     * builds a test fixture): those are not Gherkin Background, and treating them as such polluted
     * the report with spurious background steps and captured non-serializable setup arguments.
     */
    private static boolean isGeneratedTestClass(Class<?> cls) {
        for (Class<?> c = cls; c != null; c = c.getEnclosingClass()) {
            if (c.isAnnotationPresent(SourceFilePath.class)) {
                return true;
            }
        }
        return false;
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

    static String descriptorOf(Method method) {
        StringBuilder sb = new StringBuilder("(");
        for (Class<?> p : method.getParameterTypes()) {
            sb.append(typeDescriptor(p));
        }
        sb.append(')').append(typeDescriptor(method.getReturnType()));
        return sb.toString();
    }

    private static String typeDescriptor(Class<?> type) {
        if (type == void.class) return "V";
        if (type == boolean.class) return "Z";
        if (type == byte.class) return "B";
        if (type == short.class) return "S";
        if (type == char.class) return "C";
        if (type == int.class) return "I";
        if (type == long.class) return "J";
        if (type == float.class) return "F";
        if (type == double.class) return "D";
        if (type.isArray()) {
            return "[" + typeDescriptor(type.getComponentType());
        }
        return "L" + type.getName().replace('.', '/') + ";";
    }

    /**
     * Routes each method to a {@link MethodScanner} that records its body's call sites, and each
     * synthetic lambda method to a {@link LambdaBodyScanner}. The lambdas are compiled after the
     * methods creating them, so a composite step call's sub-step calls are filled in once the
     * whole class has been visited.
     */
    private static final class ScanningClassVisitor extends ClassVisitor {
        private final boolean classGenerated;
        private final String classInternalName;
        private final Set<String> subStepCallOwners;
        private final List<Call> backgroundCalls;
        private final Map<String, List<Call>> scenarioCallsByMethod;
        private final Set<String> stepMethodNames;
        private final Map<String, List<Call>> lambdaBodyCalls = new HashMap<>();
        private final List<CompositeCall> compositeCalls = new ArrayList<>();

        ScanningClassVisitor(boolean classGenerated,
                             String classInternalName,
                             Set<String> subStepCallOwners,
                             List<Call> backgroundCalls,
                             Map<String, List<Call>> scenarioCallsByMethod,
                             Set<String> stepMethodNames) {
            super(ASM_API);
            this.classGenerated = classGenerated;
            this.classInternalName = classInternalName;
            this.subStepCallOwners = subStepCallOwners;
            this.backgroundCalls = backgroundCalls;
            this.scenarioCallsByMethod = scenarioCallsByMethod;
            this.stepMethodNames = stepMethodNames;
        }

        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor,
                                         String signature, String[] exceptions) {
            if (name.startsWith(LAMBDA_METHOD_PREFIX)) {
                List<Call> calls = new ArrayList<>();
                lambdaBodyCalls.put(name + descriptor, calls);
                return new LambdaBodyScanner(subStepCallOwners, calls);
            }
            return new MethodScanner(classGenerated, classInternalName, name, descriptor,
                    backgroundCalls, scenarioCallsByMethod, stepMethodNames, compositeCalls);
        }

        @Override
        public void visitEnd() {
            for (CompositeCall compositeCall : compositeCalls) {
                for (String lambdaKey : compositeCall.lambdaKeys()) {
                    List<Call> subCalls = lambdaBodyCalls.getOrDefault(lambdaKey, List.of());
                    compositeCall.call().subCalls().addAll(subCalls);
                    for (Call subCall : subCalls) {
                        stepMethodNames.add(subCall.methodName());
                    }
                }
            }
        }
    }

    /** A call passed one or more lambdas, keyed by their synthetic methods' name and descriptor. */
    private record CompositeCall(Call call, List<String> lambdaKeys) {
    }

    /**
     * Records the sub-step calls in the body of a lambda passed to a composite step: the calls on
     * the scanned class, or on a class enclosing it. Calls producing a sub-step's values, such as
     * {@code String.replace} or a data table row's accessor, are left out.
     */
    private static final class LambdaBodyScanner extends MethodVisitor {
        private final Set<String> subStepCallOwners;
        private final List<Call> calls;

        LambdaBodyScanner(Set<String> subStepCallOwners, List<Call> calls) {
            super(ASM_API);
            this.subStepCallOwners = subStepCallOwners;
            this.calls = calls;
        }

        @Override
        public void visitMethodInsn(int opcode, String owner, String name,
                                    String descriptor, boolean isInterface) {
            if (opcode != Opcodes.INVOKEVIRTUAL && opcode != Opcodes.INVOKESPECIAL) {
                return;
            }
            if ("<init>".equals(name) || !subStepCallOwners.contains(owner)) {
                return;
            }
            calls.add(new Call(name));
        }
    }

    /**
     * Single-pass per-method visitor: records every candidate {@code this}-call into a
     * pending buffer, then in {@code visitEnd} flushes the buffer to either the
     * background sink or the scenario-method sink based on whether the method carries
     * {@code @BeforeEach} or {@code @Test} / {@code @ParameterizedTest}. Methods with
     * neither annotation are dropped. A lambda created between two calls is taken as passed
     * to the second — the generated code builds a composite step's sub-step lambda as the
     * last argument of its call.
     */
    private static final class MethodScanner extends MethodVisitor {
        private static final String DESC_TEST = "Lorg/junit/jupiter/api/Test;";
        private static final String DESC_PARAMETERIZED = "Lorg/junit/jupiter/params/ParameterizedTest;";
        private static final String DESC_BEFORE_EACH = "Lorg/junit/jupiter/api/BeforeEach;";

        private final boolean classGenerated;
        private final String classInternalName;
        private final String methodName;
        private final String methodDescriptor;
        private final List<Call> backgroundSink;
        private final Map<String, List<Call>> scenarioSinks;
        private final Set<String> stepMethodNames;
        private final List<CompositeCall> compositeCalls;
        private final List<PendingCall> pendingCalls = new ArrayList<>();
        private final List<String> pendingLambdaKeys = new ArrayList<>();
        private boolean isTest;
        private boolean isBeforeEach;

        MethodScanner(boolean classGenerated,
                      String classInternalName,
                      String methodName,
                      String methodDescriptor,
                      List<Call> backgroundSink,
                      Map<String, List<Call>> scenarioSinks,
                      Set<String> stepMethodNames,
                      List<CompositeCall> compositeCalls) {
            super(ASM_API);
            this.classGenerated = classGenerated;
            this.classInternalName = classInternalName;
            this.methodName = methodName;
            this.methodDescriptor = methodDescriptor;
            this.backgroundSink = backgroundSink;
            this.scenarioSinks = scenarioSinks;
            this.stepMethodNames = stepMethodNames;
            this.compositeCalls = compositeCalls;
        }

        private record PendingCall(String methodName, List<String> lambdaKeys) {
        }

        @Override
        public AnnotationVisitor visitAnnotation(String desc, boolean visible) {
            if (DESC_TEST.equals(desc) || DESC_PARAMETERIZED.equals(desc)) {
                isTest = true;
            } else if (DESC_BEFORE_EACH.equals(desc)) {
                isBeforeEach = true;
            }
            return null;
        }

        @Override
        public void visitMethodInsn(int opcode, String owner, String name,
                                    String descriptor, boolean isInterface) {
            if (opcode != Opcodes.INVOKEVIRTUAL
                    && opcode != Opcodes.INVOKESPECIAL
                    && opcode != Opcodes.INVOKEINTERFACE) {
                return;
            }
            if ("<init>".equals(name) || "<clinit>".equals(name)) {
                return;
            }
            if (isInfrastructureOwner(owner)) {
                return;
            }
            pendingCalls.add(new PendingCall(name, List.copyOf(pendingLambdaKeys)));
            pendingLambdaKeys.clear();
        }

        @Override
        public void visitInvokeDynamicInsn(String name, String descriptor, Handle bootstrapMethodHandle,
                                           Object... bootstrapMethodArguments) {
            // LambdaMetafactory's second bootstrap argument is the method holding the lambda's body
            if (LAMBDA_METAFACTORY.equals(bootstrapMethodHandle.getOwner())
                    && bootstrapMethodArguments.length > 1
                    && bootstrapMethodArguments[1] instanceof Handle implementation
                    && classInternalName.equals(implementation.getOwner())) {
                pendingLambdaKeys.add(implementation.getName() + implementation.getDesc());
            }
        }

        @Override
        public void visitEnd() {
            if (!isTest && !isBeforeEach) {
                return;
            }
            List<Call> sink;
            if (isBeforeEach) {
                // Only SpecBinder-generated test classes contribute Gherkin Background steps.
                // A @BeforeEach on a hand-written base/marker class (e.g. an infrastructure
                // setUp() that builds a test fixture) is NOT a Gherkin Background and must not
                // pollute the report — nor have its (possibly non-serializable) call arguments
                // captured as step arguments.
                if (!classGenerated) {
                    return;
                }
                // Append: multiple @BeforeEach methods across the class hierarchy all
                // run, in chain-top-down (parent → child) order.
                sink = backgroundSink;
            } else {
                // Replace: when the same @Test method is overridden in a subclass, the
                // top-down scan visits the override last; that body is what JUnit
                // actually invokes, so it wins over any earlier ancestor entry.
                sink = new ArrayList<>();
                scenarioSinks.put(methodName + methodDescriptor, sink);
            }
            for (PendingCall pendingCall : pendingCalls) {
                Call call;
                if (pendingCall.lambdaKeys().isEmpty()) {
                    call = new Call(pendingCall.methodName());
                } else {
                    // sub-step calls are filled in once the lambda bodies have been visited
                    call = new Call(pendingCall.methodName(), new ArrayList<>());
                    compositeCalls.add(new CompositeCall(call, pendingCall.lambdaKeys()));
                }
                sink.add(call);
                stepMethodNames.add(pendingCall.methodName());
            }
        }

        private static boolean isInfrastructureOwner(String owner) {
            return owner.startsWith("java/")
                    || owner.startsWith("javax/")
                    || owner.startsWith("jdk/")
                    || owner.startsWith("kotlin/")
                    || owner.startsWith("org/junit/");
        }
    }
}
