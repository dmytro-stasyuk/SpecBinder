package dev.specbinder.reporter.internal;

import dev.specbinder.reporter.SpecBinderReporter;
import net.bytebuddy.ByteBuddy;
import net.bytebuddy.dynamic.DynamicType;
import net.bytebuddy.dynamic.loading.ClassLoadingStrategy;
import net.bytebuddy.implementation.MethodDelegation;
import net.bytebuddy.implementation.bind.annotation.AllArguments;
import net.bytebuddy.implementation.bind.annotation.Origin;
import net.bytebuddy.implementation.bind.annotation.RuntimeType;
import net.bytebuddy.implementation.bind.annotation.SuperCall;
import net.bytebuddy.matcher.ElementMatchers;

import java.lang.reflect.Method;
import java.util.Set;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Builds — and caches — a ByteBuddy subclass of the user's concrete test class that
 * overrides every method discovered by {@link StepCallSiteScanner} as a step call site.
 * Each override fires {@link SpecBinderReporter#stepStarting} before invoking
 * {@code super}, then {@link SpecBinderReporter#stepPassed} or
 * {@link SpecBinderReporter#stepFailed} based on the outcome.
 */
public final class InstrumentedClassFactory {

    private static final ConcurrentHashMap<Class<?>, Class<?>> CACHE = new ConcurrentHashMap<>();

    private InstrumentedClassFactory() {
    }

    /**
     * Returns a subclass of {@code concreteTestClass} with overrides for every method
     * named in {@code stepMethodNames}. The result is cached per concrete class —
     * subsequent calls return the same generated class.
     */
    public static Class<?> instrumentedSubclassOf(Class<?> concreteTestClass, Set<String> stepMethodNames) {
        return CACHE.computeIfAbsent(concreteTestClass, key -> build(key, stepMethodNames));
    }

    private static Class<?> build(Class<?> concreteTestClass, Set<String> stepMethodNames) {
        if (stepMethodNames.isEmpty()) {
            return concreteTestClass;
        }
        DynamicType.Unloaded<?> unloaded = new ByteBuddy()
                .subclass(concreteTestClass)
                .name(concreteTestClass.getName() + "$SpecBinderInstrumented")
                .method(ElementMatchers.namedOneOf(stepMethodNames.toArray(new String[0]))
                        .and(ElementMatchers.not(ElementMatchers.isStatic()))
                        .and(ElementMatchers.not(ElementMatchers.isFinal())))
                .intercept(MethodDelegation.to(StepInterceptor.class))
                .make();
        return unloaded
                .load(concreteTestClass.getClassLoader(), ClassLoadingStrategy.Default.WRAPPER)
                .getLoaded();
    }

    /**
     * ByteBuddy delegation target. ByteBuddy generates an override on each step
     * method whose body forwards to {@link #intercept}, passing the original method
     * (via {@code @Origin}), the actual arguments, and a callable wrapping the
     * {@code super} invocation.
     */
    public static final class StepInterceptor {

        private StepInterceptor() {
        }

        @RuntimeType
        public static Object intercept(@Origin Method origin,
                                       @AllArguments Object[] args,
                                       @SuperCall Callable<?> superCall) throws Throwable {
            SpecBinderReporter.stepStarting(origin.getName(), args);
            try {
                Object result = superCall.call();
                SpecBinderReporter.stepPassed();
                return result;
            } catch (Throwable t) {
                SpecBinderReporter.stepFailed(t);
                throw t;
            }
        }
    }
}
