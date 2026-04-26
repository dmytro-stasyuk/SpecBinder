package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@JsonPropertyOrder({
        "displayName", "status", "sourceLine", "startedAt", "durationMs",
        "examplesRow", "rowHash", "backgroundSteps", "steps"
})
public class ExampleReport {

    private String displayName;
    private Status status;
    private Long sourceLine;
    private Instant startedAt;
    private long durationMs;
    private Map<String, String> examplesRow;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String rowHash;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<StepReport> backgroundSteps;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private List<StepReport> steps;

    public ExampleReport() {
        this.examplesRow = new LinkedHashMap<>();
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public Long getSourceLine() {
        return sourceLine;
    }

    public void setSourceLine(Long sourceLine) {
        this.sourceLine = sourceLine;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public void setStartedAt(Instant startedAt) {
        this.startedAt = startedAt;
    }

    public long getDurationMs() {
        return durationMs;
    }

    public void setDurationMs(long durationMs) {
        this.durationMs = durationMs;
    }

    public Map<String, String> getExamplesRow() {
        return examplesRow;
    }

    public void setExamplesRow(Map<String, String> examplesRow) {
        this.examplesRow = examplesRow;
    }

    public String getRowHash() {
        return rowHash;
    }

    public void setRowHash(String rowHash) {
        this.rowHash = rowHash;
    }

    public List<StepReport> getBackgroundSteps() {
        return backgroundSteps;
    }

    public void setBackgroundSteps(List<StepReport> backgroundSteps) {
        this.backgroundSteps = backgroundSteps;
    }

    public List<StepReport> getSteps() {
        return steps;
    }

    public void setSteps(List<StepReport> steps) {
        this.steps = steps;
    }
}
