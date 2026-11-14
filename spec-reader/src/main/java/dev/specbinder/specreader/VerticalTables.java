package dev.specbinder.specreader;

import io.cucumber.messages.types.DataTable;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;

import java.util.*;

/**
 * Data tables written vertically: the first row opens with {@code !} in place of the first {@code |}, the names run
 * down the first column, and each further column holds one record, e.g.
 * <pre>
 * Given the following customers:
 *   ! name  | Alice             | Bob             |
 *   | email | alice@example.com | bob@example.com |
 * </pre>
 * A line is the first row of a vertical table only when it starts with {@code !}, ends with {@code |} and comes right
 * after a step, with only blank and comment lines between them. Any other line starting with {@code !} is left as it
 * is, so it is read as it was before, and the parser reports it where it can't be. Examples tables are always written
 * normally: under an Examples line, a line starting with {@code !} is description.
 * <p>
 * {@link SpecParser} gives a vertical table turned to the normal layout, with the names as its first row and one row
 * per record, so it reads like the same data written normally. Each cell keeps its place in the spec, and each row is
 * placed at its column's cell in the first row as written, so the table's first row isn't placed where the table is,
 * which tells it apart from a table written normally.
 */
public final class VerticalTables {

    /**
     * What a vertical table's first row opens with in place of {@code |}.
     */
    public static final String FIRST_ROW_OPENER = "!";

    private VerticalTables() {
    }

    /**
     * Tells whether a table read by {@link SpecParser} was written vertically.
     *
     * @param table a table read by {@link SpecParser}
     * @return true if the table was written vertically and so was turned to the normal layout
     */
    public static boolean isWrittenVertically(DataTable table) {
        return !table.getRows().isEmpty() && !table.getRows().getFirst().getLocation().equals(table.getLocation());
    }

    /**
     * Returns a table written vertically in the layout it is written in: the names down the first column, and one
     * column per record. Each row is placed at its first cell, the first row where the table is.
     *
     * @param table a table read by {@link SpecParser} that was written vertically
     * @return the table as written
     */
    public static DataTable asWritten(DataTable table) {
        List<TableRow> writtenRows = transpose(table.getRows());
        TableRow firstRow = writtenRows.getFirst();
        writtenRows.set(0, new TableRow(table.getLocation(), firstRow.getCells(), firstRow.getId()));
        return new DataTable(table.getLocation(), writtenRows);
    }

    /**
     * Rewrites the first row of each vertical table so the parser reads the table as a normal one, with its rows as
     * written: the {@code !} becomes a {@code |}.
     */
    static Translation rewriteFirstRows(Translation translation, SpecKeywords keywords) {

        List<String> stepKeywords = keywords.stepKeywords();

        String[] originalLines = translation.originalLines();
        String[] translatedLines = translation.translatedLines().clone();
        Set<Integer> firstRowLines = new TreeSet<>();

        boolean afterStep = false;
        String openDocStringDelimiter = null;
        for (int i = 0; i < originalLines.length; i++) {
            String trimmed = originalLines[i].strip();

            if (openDocStringDelimiter != null) {
                if (trimmed.startsWith(openDocStringDelimiter)) {
                    openDocStringDelimiter = null;
                }
                continue;
            }
            // a table may be parted from its step by blank and comment lines
            if (trimmed.isEmpty() || trimmed.startsWith("#")) {
                continue;
            }
            if (trimmed.startsWith("\"\"\"") || trimmed.startsWith("```")) {
                openDocStringDelimiter = trimmed.substring(0, 3);
                afterStep = false;
                continue;
            }

            if (afterStep && trimmed.startsWith(FIRST_ROW_OPENER) && trimmed.endsWith("|")) {
                String line = translatedLines[i];
                int opener = line.indexOf(FIRST_ROW_OPENER);
                translatedLines[i] = line.substring(0, opener) + "|" + line.substring(opener + 1);
                firstRowLines.add(i);
                afterStep = false;
                continue;
            }
            afterStep = stepKeywords.stream().anyMatch(trimmed::startsWith);
        }

        if (firstRowLines.isEmpty()) {
            return translation;
        }
        return new Translation(originalLines, translatedLines, translation.originalKeywords(),
                translation.headerLanguage(), Collections.unmodifiableSet(firstRowLines));
    }

    /**
     * Turns a table parsed with its rows as written vertically to the normal layout.
     */
    static DataTable toNormalLayout(DataTable writtenTable) {
        List<TableRow> rows = transpose(writtenTable.getRows());
        if (rows.isEmpty()) {
            return writtenTable;
        }
        return new DataTable(writtenTable.getLocation(), rows);
    }

    /**
     * The columns of the rows as rows, each placed at its first cell.
     */
    private static List<TableRow> transpose(List<TableRow> rows) {
        int columnCount = rows.getFirst().getCells().size();
        List<TableRow> columns = new ArrayList<>(columnCount);
        for (int column = 0; column < columnCount; column++) {
            List<TableCell> cells = new ArrayList<>(rows.size());
            for (TableRow row : rows) {
                cells.add(row.getCells().get(column));
            }
            columns.add(new TableRow(cells.getFirst().getLocation(), cells, UUID.randomUUID().toString()));
        }
        return columns;
    }
}
