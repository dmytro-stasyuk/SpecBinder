package dev.specbinder.reporter.internal;

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
 */
public final class StepCallSiteScanner {

    private static final int ASM_API = Opcodes.ASM9;

    /** A single bytecode call site: invoked method name. */
    public static final class Call {
        private final String methodName;

        public Call(String methodName) {
            this.methodName = methodName;
        }

        public String methodName() {
            return methodName;
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
            new ClassReader(bytes).accept(
                    new ScanningClassVisitor(backgroundCalls, scenarioCallsByMethod, stepMethodNames),
                    ClassReader.SKIP_FRAMES);
        }

        return new Plan(backgroundCalls, scenarioCallsByMethod, stepMethodNames);
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

    /** Routes each method to a {@link MethodScanner} that records its body's call sites. */
    private static final class ScanningClassVisitor extends ClassVisitor {
        private final List<Call> backgroundCalls;
        private final Map<String, List<Call>> scenarioCallsByMethod;
        private final Set<String> stepMethodNames;

        ScanningClassVisitor(List<Call> backgroundCalls,
                             Map<String, List<Call>> scenarioCallsByMethod,
                             Set<String> stepMethodNames) {
            super(ASM_API);
            this.backgroundCalls = backgroundCalls;
            this.scenarioCallsByMethod = scenarioCallsByMethod;
            this.stepMethodNames = stepMethodNames;
        }

        @Override
        public MethodVisitor visitMethod(int access, String name, String descriptor,
                                         String signature, String[] exceptions) {
            return new MethodScanner(name, descriptor,
                    backgroundCalls, scenarioCallsByMethod, stepMethodNames);
        }
    }

    /**
     * Single-pass per-method visitor: records every candidate {@code this}-call into a
     * pending buffer, then in {@code visitEnd} flushes the buffer to either the
     * background sink or the scenario-method sink based on whether the method carries
     * {@code @BeforeEach} or {@code @Test} / {@code @ParameterizedTest}. Methods with
     * neither annotation are dropped.
     */
    private static final class MethodScanner extends MethodVisitor {
        private static final String DESC_TEST = "Lorg/junit/jupiter/api/Test;";
        private static final String DESC_PARAMETERIZED = "Lorg/junit/jupiter/params/ParameterizedTest;";
        private static final String DESC_BEFORE_EACH = "Lorg/junit/jupiter/api/BeforeEach;";

        private final String methodName;
        private final String methodDescriptor;
        private final List<Call> backgroundSink;
        private final Map<String, List<Call>> scenarioSinks;
        private final Set<String> stepMethodNames;
        private final List<String> pendingCallNames = new ArrayList<>();
        private boolean isTest;
        private boolean isBeforeEach;

        MethodScanner(String methodName,
                      String methodDescriptor,
                      List<Call> backgroundSink,
                      Map<String, List<Call>> scenarioSinks,
                      Set<String> stepMethodNames) {
            super(ASM_API);
            this.methodName = methodName;
            this.methodDescriptor = methodDescriptor;
            this.backgroundSink = backgroundSink;
            this.scenarioSinks = scenarioSinks;
            this.stepMethodNames = stepMethodNames;
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
            pendingCallNames.add(name);
        }

        @Override
        public void visitEnd() {
            if (!isTest && !isBeforeEach) {
                return;
            }
            List<Call> sink;
            if (isBeforeEach) {
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
            for (String callName : pendingCallNames) {
                sink.add(new Call(callName));
                stepMethodNames.add(callName);
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
