package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@JsonPropertyOrder({
        "schemaVersion", "sourceFilePath", "displayName", "description", "testClass",
        "executedAt", "totalDurationMs", "summary", "scenarios", "rules"
})
public class FeatureReport {

    public static final int SCHEMA_VERSION = 8;

    private int schemaVersion = SCHEMA_VERSION;
    private String sourceFilePath;
    private String displayName;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String description;
    private String testClass;
    private Instant executedAt;
    private long totalDurationMs;
    private Summary summary;
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    private List<ScenarioNode> scenarios;
    @JsonInclude(JsonInclude.Include.NON_EMPTY)
    private List<RuleReport> rules;

    public FeatureReport() {
        this.summary = new Summary();
        this.scenarios = new ArrayList<>();
        this.rules = new ArrayList<>();
    }

    public int getSchemaVersion() {
        return schemaVersion;
    }

    public void setSchemaVersion(int schemaVersion) {
        this.schemaVersion = schemaVersion;
    }

    public String getSourceFilePath() {
        return sourceFilePath;
    }

    public void setSourceFilePath(String sourceFilePath) {
        this.sourceFilePath = sourceFilePath;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getTestClass() {
        return testClass;
    }

    public void setTestClass(String testClass) {
        this.testClass = testClass;
    }

    public Instant getExecutedAt() {
        return executedAt;
    }

    public void setExecutedAt(Instant executedAt) {
        this.executedAt = executedAt;
    }

    public long getTotalDurationMs() {
        return totalDurationMs;
    }

    public void setTotalDurationMs(long totalDurationMs) {
        this.totalDurationMs = totalDurationMs;
    }

    public Summary getSummary() {
        return summary;
    }

    public void setSummary(Summary summary) {
        this.summary = summary;
    }

    public List<ScenarioNode> getScenarios() {
        return scenarios;
    }

    public void setScenarios(List<ScenarioNode> scenarios) {
        this.scenarios = scenarios;
    }

    public List<RuleReport> getRules() {
        return rules;
    }

    public void setRules(List<RuleReport> rules) {
        this.rules = rules;
    }
}
