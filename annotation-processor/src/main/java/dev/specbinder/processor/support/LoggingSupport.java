package dev.specbinder.processor.support;

import dev.specbinder.annotations.Gherkin2JUnitOptions.Verbosity;

import javax.annotation.processing.ProcessingEnvironment;
import javax.tools.Diagnostic;
import java.util.Map;

/**
 * Contains supporting methods for printing build log messages.
 */
public interface LoggingSupport {

    /**
     * Logs an error message to the build log.
     * @param message - the message to log
     */
    default void logError(String message) {

        logMessage(message, Diagnostic.Kind.ERROR);
    }

    /**
     * Logs an error message and stack trace passed as a multiline string to the build log.
     * @param message - the message to log
     * @param stackTrace - the stack trace to log
     */
    default void logError(String message, String stackTrace) {

        logMessage(message, Diagnostic.Kind.ERROR);

        String[] lines = stackTrace.split("\\n");
        for (String line : lines) {
            logMessage(line, Diagnostic.Kind.ERROR);
        }
    }

    /**
     * Logs a warning message to the build log.
     * @param message - the message to log
     */
    default void logWarning(String message) {

        logMessage(message, Diagnostic.Kind.WARNING);
    }

    /**
     * Logs an informational message to the build log unconditionally — i.e. at every verbosity
     * level except SILENT. Use for messages that are part of the normal build narrative
     * (startup banner, end-of-round summary).
     * @param message - the message to log
     */
    default void logInfo(String message) {

        logMessage(message, Diagnostic.Kind.NOTE);
    }

    /**
     * Logs a message only when the resolved verbosity is at least {@link Verbosity#VERBOSE}.
     * The emitted line is tagged with a {@code [verbose]} marker after the {@code [SpecBinder]}
     * prefix so that grep/filtering on log level is straightforward.
     * Use for per-class / per-spec-file diagnostic narration that's useful when a developer
     * is actively troubleshooting but is noise in routine builds.
     * @param message - the message to log
     */
    default void logVerbose(String message) {

        if (resolveProcessorVerbosity().ordinal() >= Verbosity.VERBOSE.ordinal()) {
            logMessage("[verbose] " + message, Diagnostic.Kind.NOTE);
        }
    }

    /**
     * Logs a message only when the resolved verbosity is {@link Verbosity#DEBUG}.
     * The emitted line is tagged with a {@code [debug]} marker after the {@code [SpecBinder]}
     * prefix; the marker is right-padded to match the width of {@code [verbose] } so message
     * columns line up across both tiers.
     * Use for internal-detail tracing that only the processor authors typically care about
     * (per-round trace lines, classpath-root resolution attempts, code-model dumps).
     * @param message - the message to log
     */
    default void logDebug(String message) {

        if (resolveProcessorVerbosity().ordinal() >= Verbosity.DEBUG.ordinal()) {
            logMessage("[debug]   " + message, Diagnostic.Kind.NOTE);
        }
    }

    /**
     * Logs a message of kind OTHER to the build log.
     * @param message - the message to log
     */
    default void logOther(String message) {

        logMessage(message, Diagnostic.Kind.OTHER);
    }

    private void logMessage(String message, Diagnostic.Kind kind) {

        getProcessingEnv().getMessager().printMessage(kind, "[SpecBinder] " + message);
    }

    /**
     * Resolves the effective verbosity for the currently-active annotated class.
     * <p>
     * Order of precedence:
     * <ol>
     *   <li>The per-class verbosity stashed by {@code AnnotationProcessor} via
     *       {@link VerbosityContext} — this carries the annotation-level
     *       {@code @Gherkin2JUnitOptions(verbosity = …)} value (or its processor-arg fallback)
     *       resolved for the class currently being processed.</li>
     *   <li>The {@code -Aspecbinder.verbosity=…} processor argument, used when no per-class
     *       context has been set (e.g. during very early processor-init log lines, or in
     *       test environments that bypass the per-class loop).</li>
     *   <li>{@link Verbosity#NORMAL}.</li>
     * </ol>
     */
    private Verbosity resolveProcessorVerbosity() {
        Verbosity perClass = VerbosityContext.current();
        if (perClass != null) {
            return perClass;
        }
        Map<String, String> options = getProcessingEnv().getOptions();
        if (options != null) {
            String value = options.get("specbinder.verbosity");
            if (value != null) {
                try {
                    return Verbosity.parse(value);
                } catch (IllegalArgumentException ignored) {
                    // Unknown values fall through to NORMAL.
                }
            }
        }
        return Verbosity.NORMAL;
    }

    /**
     * Override this method to provide an instance of the {@link ProcessingEnvironment} that is needed to log messages.
     * @return the processing environment
     */
    ProcessingEnvironment getProcessingEnv();
}
