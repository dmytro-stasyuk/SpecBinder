package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.time.Instant;
import java.util.List;

/**
 * Per-step record inside a {@link ScenarioNode} or {@link ExampleReport}.
 * <p>
 * Carries only what is observable at runtime: the Java method name the generated
 * test body called, a terminal {@link Status}, and timing. Steps that never started
 * (because an earlier step failed) carry {@link Status#SKIPPED} with no timing
 * fields. Background steps and scenario steps live in separate arrays on the
 * enclosing scenario, so the per-step record carries no kind discriminator.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({"methodName", "arguments", "status", "startedAt", "durationMs", "error"})
public class StepReport {

    private String methodName;
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    private List<Object> arguments;
    private Status status;
    private Instant startedAt;
    private Long durationMs;
    private ErrorInfo error;

    public StepReport() {
    }

    public static StepReport pending(String methodName) {
        StepReport step = new StepReport();
        step.methodName = methodName;
        step.status = Status.SKIPPED;
        return step;
    }

    public String getMethodName() {
        return methodName;
    }

    public void setMethodName(String methodName) {
        this.methodName = methodName;
    }

    public List<Object> getArguments() {
        return arguments;
    }

    public void setArguments(List<Object> arguments) {
        this.arguments = arguments;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(Instant startedAt) {
        this.startedAt = startedAt;
    }

    public Long getDurationMs() {
        return durationMs;
    }

    public void setDurationMs(Long durationMs) {
        this.durationMs = durationMs;
    }

    public ErrorInfo getError() {
        return error;
    }

    public void setError(ErrorInfo error) {
        this.error = error;
    }
}
