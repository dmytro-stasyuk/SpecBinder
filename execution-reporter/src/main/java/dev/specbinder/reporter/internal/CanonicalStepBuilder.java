package dev.specbinder.reporter.internal;

import io.cucumber.messages.types.*;

import java.util.List;
import java.util.Optional;

/**
 * Reporter-side mirror of {@code dev.specbinder.processor.gherkin.utils.CanonicalStepBuilder}.
 * Converts a Cucumber Gherkin {@link Step} AST node to a {@link CanonicalStep} suitable for
 * scenario-hash computation. Canonicalization rules MUST stay in lockstep with the annotation
 * processor's implementation; parity is asserted by {@code ScenarioHasherParityTest}.
 */
public final class CanonicalStepBuilder {

    private CanonicalStepBuilder() {
    }

    public static CanonicalStep canonicalize(Step step) {
        String stepText = step.getText();
        String canonicalDataTable = step.getDataTable()
                .map(CanonicalStepBuilder::canonicalizeDataTable)
                .orElse(null);
        String canonicalDocString = step.getDocString()
                .map(CanonicalStepBuilder::canonicalizeDocString)
                .orElse(null);
        return new CanonicalStep(stepText, canonicalDataTable, canonicalDocString);
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
