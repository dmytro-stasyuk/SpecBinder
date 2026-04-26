package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.util.ArrayList;
import java.util.List;

@JsonPropertyOrder({"id", "displayName", "sourceLine", "scenarios"})
public class RuleReport {

    private String id;
    private String displayName;
    private Long sourceLine;
    private List<ScenarioNode> scenarios;

    public RuleReport() {
        this.scenarios = new ArrayList<>();
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

    public Long getSourceLine() {
        return sourceLine;
    }

    public void setSourceLine(Long sourceLine) {
        this.sourceLine = sourceLine;
    }

    public List<ScenarioNode> getScenarios() {
        return scenarios;
    }

    public void setScenarios(List<ScenarioNode> scenarios) {
        this.scenarios = scenarios;
    }
}
