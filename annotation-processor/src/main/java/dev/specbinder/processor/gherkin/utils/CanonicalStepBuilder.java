package dev.specbinder.processor.gherkin.utils;

import dev.specbinder.processor.gherkin.hash.CanonicalStep;
import io.cucumber.messages.types.*;

import java.util.List;
import java.util.Optional;

/**
 * Converts a Cucumber Gherkin {@link Step} AST node to a {@link CanonicalStep} suitable for
 * scenario-hash computation.
 *
 * <p>The canonicalization rules are documented on {@link CanonicalStep} and pinned by the
 * golden-hash test in {@code ScenarioHasherTest}. Any change here must keep the worked-example
 * hash stable.
 */
public final class CanonicalStepBuilder {

    private CanonicalStepBuilder() {
    }

    /**
     * Converts a Gherkin {@link Step} AST node to its canonical representation.
     *
     * @param step the Gherkin step to canonicalize
     * @return canonical step suitable for hash computation
     */
    public static CanonicalStep canonicalize(Step step) {
        String stepText = normalizeInterWordWhitespace(step.getText());
        String canonicalDataTable = step.getDataTable()
                .map(CanonicalStepBuilder::canonicalizeDataTable)
                .orElse(null);
        String canonicalDocString = step.getDocString()
                .map(CanonicalStepBuilder::canonicalizeDocString)
                .orElse(null);
        return new CanonicalStep(stepText, canonicalDataTable, canonicalDocString);
    }

    /**
     * Normalizes whitespace between a step's words so that cosmetic spacing differences do not
     * affect the scenario hash: runs of whitespace are collapsed to a single space and
     * leading/trailing whitespace is stripped. Whitespace inside quoted parameter values is not
     * treated specially here — the collapse applies to the whole step text uniformly.
     *
     * @param text the raw step text after the keyword
     * @return the step text with inter-word whitespace normalized
     */
    private static String normalizeInterWordWhitespace(String text) {
        return text.strip().replaceAll("\\s+", " ");
    }

    private static String canonicalizeDataTable(DataTable dataTable) {
        List<TableRow> rows = dataTable.getRows();
        StringBuilder sb = new StringBuilder();
        for (int r = 0; r < rows.size(); r++) {
            if (r > 0) sb.append('\n');
            sb.append('|');
            List<TableCell> cells = rows.get(r).getCells();
            for (TableCell cell : cells) {
                sb.append(cell.getValue().strip()).append('|');
            }
        }
        return sb.toString();
    }

    private static String canonicalizeDocString(DocString docString) {
        String delimiter = "\"\"\"";
        Optional<String> mediaTypeOpt = docString.getMediaType()
                .map(String::strip)
                .filter(s -> !s.isEmpty());
        String content = docString.getContent() == null ? "" : docString.getContent();

        StringBuilder sb = new StringBuilder();
        sb.append(delimiter);
        mediaTypeOpt.ifPresent(sb::append);
        sb.append('\n');

        String[] lines = content.split("\n", -1);
        for (int i = 0; i < lines.length; i++) {
            String line = stripTrailingWhitespace(lines[i]);
            if (i == lines.length - 1 && line.isEmpty()) {
                continue;
            }
            sb.append(line).append('\n');
        }

        sb.append(delimiter);
        return sb.toString();
    }

    private static String stripTrailingWhitespace(String s) {
        int end = s.length();
        while (end > 0 && Character.isWhitespace(s.charAt(end - 1))) {
            end--;
        }
        return s.substring(0, end);
    }
}
