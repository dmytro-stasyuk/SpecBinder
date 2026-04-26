package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.annotation.JsonValue;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Union type for the children of a feature or rule. Discriminated by {@link #type}.
 * Scenario-only fields ({@code id}, {@code startedAt}, {@code durationMs}) and
 * outline-only fields ({@code totalDurationMs}, {@code examples}) are nullable;
 * Jackson omits nulls so each kind serializes to its own fields.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
        "type", "id", "displayName", "status", "sourceLine", "scenarioHash", "tags",
        "startedAt", "durationMs", "backgroundSteps", "steps", "totalDurationMs", "examples"
})
public class ScenarioNode {

    public enum Kind {
        SCENARIO("scenario"),
        SCENARIO_OUTLINE("scenarioOutline");

        private final String wireValue;

        Kind(String wireValue) {
            this.wireValue = wireValue;
        }

        @JsonValue
        public String wireValue() {
            return wireValue;
        }
    }

    private Kind type;
    private String id;
    private String displayName;
    private Status status;
    private Long sourceLine;
    private String scenarioHash;
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    private List<String> tags;
    // scenario-only
    private Instant startedAt;
    private Long durationMs;
    private List<StepReport> backgroundSteps;
    private List<StepReport> steps;
    // outline-only
    private Long totalDurationMs;
    private List<ExampleReport> examples;

    public ScenarioNode() {
    }

    public static ScenarioNode scenario() {
        ScenarioNode node = new ScenarioNode();
        node.type = Kind.SCENARIO;
        node.tags = new ArrayList<>();
        return node;
    }

    public static ScenarioNode outline() {
        ScenarioNode node = new ScenarioNode();
        node.type = Kind.SCENARIO_OUTLINE;
        node.tags = new ArrayList<>();
        node.examples = new ArrayList<>();
        return node;
    }

    public Kind getType() {
        return type;
    }

    public void setType(Kind type) {
        this.type = type;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
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

    public String getScenarioHash() {
        return scenarioHash;
    }

    public void setScenarioHash(String scenarioHash) {
        this.scenarioHash = scenarioHash;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
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

    public Long getTotalDurationMs() {
        return totalDurationMs;
    }

    public void setTotalDurationMs(Long totalDurationMs) {
        this.totalDurationMs = totalDurationMs;
    }

    public List<ExampleReport> getExamples() {
        return examples;
    }

    public void setExamples(List<ExampleReport> examples) {
        this.examples = examples;
    }
}
