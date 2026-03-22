package dev.specbinder.processor.exception;

/**
 * More specific exception for processing errors.
 */
public class ProcessingException extends RuntimeException {

    /**
     * Creates a new ProcessingException with no detail message or cause.
     */
    public ProcessingException() {
        super();
    }

    /**
     * Creates a new ProcessingException with the specified detail message.
     *
     * @param message - the detail message
     */
    public ProcessingException(String message) {
        super(message);
    }

    /**
     * Creates a new ProcessingException with the specified detail message and cause.
     *
     * @param message - the detail message
     * @param cause   - the cause of the exception
     */
    public ProcessingException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Creates a new ProcessingException with the specified cause.
     *
     * @param cause - the cause of the exception
     */
    public ProcessingException(Throwable cause) {
        super(cause);
    }

    /**
     * Creates a new ProcessingException with the specified detail message, cause, suppression enabled or disabled,
     * and writable stack trace enabled or disabled.
     *
     * @param message - the detail message
     * @param cause - the cause of the exception
     * @param enableSuppression - whether suppression is enabled or disabled
     * @param writableStackTrace - whether the stack trace should be writable
     */
    protected ProcessingException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
        super(message, cause, enableSuppression, writableStackTrace);
    }

}
