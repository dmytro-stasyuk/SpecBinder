package dev.specbinder.processor.support;

import dev.specbinder.annotations.Gherkin2JUnitOptions.Verbosity;

/**
 * Carries the effective {@link Verbosity} for the annotated class currently being processed,
 * so that helper classes (which don't have a {@code GeneratorOptions} in scope) can gate their
 * {@code logVerbose}/{@code logDebug} calls on the same level the orchestrating
 * {@code AnnotationProcessor} resolved for that class.
 * <p>
 * The {@code AnnotationProcessor} is expected to {@link #set(Verbosity) set} the value at the
 * start of every per-class iteration and {@link #clear() clear} it in a {@code finally} block
 * once the iteration completes.
 */
public final class VerbosityContext {

    private static final ThreadLocal<Verbosity> CURRENT = new ThreadLocal<>();

    private VerbosityContext() {
    }

    /**
     * Sets the active verbosity for the current thread.
     *
     * @param verbosity the verbosity level to activate
     */
    public static void set(Verbosity verbosity) {
        CURRENT.set(verbosity);
    }

    /**
     * Clears the active verbosity for the current thread.
     */
    public static void clear() {
        CURRENT.remove();
    }

    /**
     * Returns the currently-active per-class verbosity, or {@code null} if none has been set.
     *
     * @return the current verbosity, or {@code null}
     */
    public static Verbosity current() {
        return CURRENT.get();
    }
}
