package dev.specbinder.reporter;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.time.Instant;
import java.util.Map;

/**
 * One entry published by user step code via
 * {@link org.junit.jupiter.api.TestReporter#publishEntry}. Captured by SpecBinder
 * through a JUnit Platform {@code TestExecutionListener} and attached to the owning
 * {@link StepReport} so report consumers (e.g. the IDE plugin) can display the entry
 * next to its gherkin step.
 * <p>
 * {@link #values} mirrors the {@code keyValuePairs} map of the JUnit
 * {@code ReportEntry} this was derived from. JUnit's single-string and key/value
 * overloads of {@code publishEntry} both produce single-entry maps (the single-string
 * form uses {@code "value"} as the key).
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({"publishedAt", "values"})
public class PublishedReporterEntry {

    private Instant publishedAt;
    private Map<String, String> values;

    public PublishedReporterEntry() {
    }

    public PublishedReporterEntry(Instant publishedAt, Map<String, String> values) {
        this.publishedAt = publishedAt;
        this.values = values;
    }

    public Instant getPublishedAt() {
        return publishedAt;
    }

    public void setPublishedAt(Instant publishedAt) {
        this.publishedAt = publishedAt;
    }

    public Map<String, String> getValues() {
        return values;
    }

    public void setValues(Map<String, String> values) {
        this.values = values;
    }
}
