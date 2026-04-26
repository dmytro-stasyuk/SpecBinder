package dev.specbinder.reporter.steps;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.TextNode;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.junit.jupiter.api.Assertions;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * JSON approval helpers. Normalises volatile fields (timestamps, durations,
 * embedded stack traces) to stable placeholders so a doc-string expectation in a
 * feature file can be compared deterministically against the actual report file
 * produced by the listener.
 */
final class JsonApprovals {

    private static final ObjectMapper MAPPER = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .enable(SerializationFeature.INDENT_OUTPUT)
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    /** Field names whose values are timestamps and should normalise to {@code "<ts>"}. */
    private static final Set<String> TIMESTAMP_FIELDS = Set.of("executedAt", "startedAt");

    /** Field names whose numeric values should normalise to 0. */
    private static final Set<String> DURATION_FIELDS = Set.of("durationMs", "totalDurationMs");

    /** Field names whose values are full stack traces — normalised to {@code "<stackTrace>"}. */
    private static final Set<String> STACK_TRACE_FIELDS = Set.of("stackTrace");

    private JsonApprovals() {
    }

    /**
     * Compare two JSON documents after normalising volatile fields. Uses JUnit's
     * {@link Assertions#assertEquals(Object, Object, String)} so the IDE renders a
     * clickable diff link in the test runner console when they differ.
     */
    static void assertMatches(String expectedJson, String actualJson) throws IOException {
        JsonNode actual = MAPPER.readTree(actualJson);
        normalize(actual);
        String actualRendered = MAPPER.writeValueAsString(actual);
        Assertions.assertEquals(expectedJson.strip(), actualRendered.strip(), "produced JSON report did not match expected");
    }

    /**
     * Walk {@code node} and replace volatile fields with placeholder values matching
     * those in feature-file doc strings ({@code "<ts>"}, {@code 0}, {@code "<stackTrace>"}, etc.).
     */
    private static void normalize(JsonNode node) {
        if (node == null || node.isNull()) {
            return;
        }
        if (node.isObject()) {
            ObjectNode obj = (ObjectNode) node;
            Iterator<Map.Entry<String, JsonNode>> fields = obj.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> entry = fields.next();
                String name = entry.getKey();
                JsonNode value = entry.getValue();
                if (TIMESTAMP_FIELDS.contains(name) && value.isTextual()) {
                    obj.set(name, TextNode.valueOf("<ts>"));
                } else if (DURATION_FIELDS.contains(name) && value.isNumber()) {
                    obj.put(name, 0);
                } else if (STACK_TRACE_FIELDS.contains(name) && value.isTextual()) {
                    obj.set(name, TextNode.valueOf("<stackTrace>"));
                } else {
                    normalize(value);
                }
            }
        } else if (node.isArray()) {
            for (JsonNode child : node) {
                normalize(child);
            }
        }
    }
}
