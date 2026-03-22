package dev.specbinder.processor.support;

import javax.annotation.processing.ProcessingEnvironment;
import javax.tools.Diagnostic;

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
     * Logs an informational message to the build log.
     * @param message - the message to log
     */
    default void logInfo(String message) {

        logMessage(message, Diagnostic.Kind.NOTE);
    }

    /**
     * Logs a message of kind OTHER to the build log.
     * @param message - the message to log
     */
    default void logOther(String message) {

        logMessage(message, Diagnostic.Kind.OTHER);
    }

    private void logMessage(String message, Diagnostic.Kind kind) {

        String prefix = "[" + this.getClass().getSimpleName() + "] ";
        getProcessingEnv().getMessager().printMessage(kind, prefix + message);
    }

    /**
     * Override this method to provide an instance of the {@link ProcessingEnvironment} that is needed to log messages.
     * @return the processing environment
     */
    ProcessingEnvironment getProcessingEnv();
}
