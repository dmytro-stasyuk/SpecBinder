package dev.specbinder.annotations.output.composite;

/**
 * An operation that takes four arguments and returns no result: the four-argument counterpart of
 * {@link java.util.function.BiConsumer}.
 *
 * <p>Used by the SpecBinder annotation processor as the type of the sub-step lambdas passed to a generated composite
 * step method whose parent step has four values, so that generated code needs nothing beyond SpecBinder's
 * annotations and the JDK.
 *
 * @param <T> the type of the first argument
 * @param <U> the type of the second argument
 * @param <V> the type of the third argument
 * @param <W> the type of the fourth argument
 * @see dev.specbinder.annotations.Gherkin2JUnitOptions#enableCompositeSteps()
 */
@FunctionalInterface
public interface QuadConsumer<T, U, V, W> {

    /**
     * Performs this operation on the given arguments.
     *
     * @param t the first argument
     * @param u the second argument
     * @param v the third argument
     * @param w the fourth argument
     */
    void accept(T t, U u, V v, W w);
}
