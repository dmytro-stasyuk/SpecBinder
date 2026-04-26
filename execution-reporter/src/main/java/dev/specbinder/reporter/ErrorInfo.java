package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import org.opentest4j.AssertionFailedError;

import java.io.PrintWriter;
import java.io.StringWriter;

@JsonInclude(JsonInclude.Include.ALWAYS)
public class ErrorInfo {

    private String type;
    private String message;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String expected;

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String actual;

    private String stackTrace;

    public ErrorInfo() {
    }

    public static ErrorInfo from(Throwable throwable) {
        if (throwable == null) {
            return null;
        }
        ErrorInfo info = new ErrorInfo();
        info.type = throwable.getClass().getName();
        info.message = throwable.getMessage();
        if (throwable instanceof AssertionFailedError afe) {
            if (afe.isExpectedDefined()) {
                info.expected = afe.getExpected().getStringRepresentation();
            }
            if (afe.isActualDefined()) {
                info.actual = afe.getActual().getStringRepresentation();
            }
        }
        StringWriter sw = new StringWriter();
        throwable.printStackTrace(new PrintWriter(sw));
        info.stackTrace = sw.toString();
        return info;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getExpected() {
        return expected;
    }

    public void setExpected(String expected) {
        this.expected = expected;
    }

    public String getActual() {
        return actual;
    }

    public void setActual(String actual) {
        this.actual = actual;
    }

    public String getStackTrace() {
        return stackTrace;
    }

    public void setStackTrace(String stackTrace) {
        this.stackTrace = stackTrace;
    }
}
