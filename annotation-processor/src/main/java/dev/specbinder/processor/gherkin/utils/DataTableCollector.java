package dev.specbinder.processor.gherkin.utils;

import dev.specbinder.processor.exception.ProcessingException;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Collects metadata about data tables in a feature for LIST_OF_OBJECT_PARAMS generation.
 * This class is used during the first pass of processing to identify all record types
 * that need to be generated and merge their column definitions.
 */
public class DataTableCollector {

    private final Map<String, RecordMetadata> recordMetadataMap = new LinkedHashMap<>();

    /**
     * Constructs a new DataTableCollector.
     */
    public DataTableCollector() {
        /**
         * default constructor
         */
    }

    /**
     * Registers a data table usage with its step text and column headers.
     * If a record with the same name already exists, the columns are merged.
     *
     * @param stepText      the full step text including keyword (e.g., "Given the following users")
     * @param columnHeaders the list of column headers from the data table
     */
    public void registerDataTable(String stepText, List<String> columnHeaders) {
        String recordName = deriveRecordNameFromStepText(stepText);

        RecordMetadata metadata = recordMetadataMap.computeIfAbsent(
                recordName,
                k -> new RecordMetadata(recordName)
        );

        metadata.mergeColumns(columnHeaders);
    }

    /**
     * Derives a record name from step text by extracting the last word.
     * The last word is cleaned of punctuation, capitalized, and "Param" suffix is added.
     *
     * @param stepText the step text (e.g., "Given the following users:")
     * @return the derived record name (e.g., "UsersParam")
     * @throws ProcessingException if a valid record name cannot be derived
     */
    public String deriveRecordNameFromStepText(String stepText) {
        String lastWord = extractLastWord(stepText);

        // Capitalize first letter for record name (PascalCase) and add "Param" suffix
        return Character.toUpperCase(lastWord.charAt(0)) + lastWord.substring(1) + "Param";
    }

    /**
     * Derives a parameter name from step text by extracting the last word.
     * The last word is cleaned of punctuation and converted to camelCase (lowercase first letter).
     *
     * @param stepText the step text (e.g., "Given the following users:")
     * @return the derived parameter name (e.g., "users")
     * @throws ProcessingException if a valid parameter name cannot be derived
     */
    public String deriveParameterNameFromStepText(String stepText) {
        String lastWord = extractLastWord(stepText);

        // Lowercase first letter for parameter name (camelCase)
        return Character.toLowerCase(lastWord.charAt(0)) + lastWord.substring(1);
    }

    /**
     * Extracts and validates the last word from step text.
     * The last word is cleaned of punctuation and converted to proper camel case if necessary.
     *
     * @param stepText the step text (e.g., "Given the following users:")
     * @return the cleaned last word (e.g., "users")
     * @throws ProcessingException if a valid word cannot be extracted
     */
    private String extractLastWord(String stepText) {
        String[] words = stepText.trim().split("\\s+");

        if (words.length < 2) {
            throw new ProcessingException(
                    "Cannot derive record name from step: " + stepText +
                            ". Step must have at least two words.");
        }

        // Walk backwards to find the last word containing alphanumeric characters
        String lastWord = null;
        for (int i = words.length - 1; i >= 0; i--) {
            String candidate = words[i];
            if (candidate.contains("-")) {
                candidate = convertHyphenatedToCamelCase(candidate);
            }
            candidate = candidate.replaceAll("[^a-zA-Z0-9]", "");
            if (!candidate.isEmpty() && Character.isJavaIdentifierStart(candidate.charAt(0))) {
                lastWord = candidate;
                break;
            }
        }

        if (lastWord == null) {
            throw new ProcessingException(
                    "Cannot derive valid record name from step: " + stepText +
                            ". No word contains valid Java identifier characters.");
        }

        // Handle all-caps words (e.g., "API" -> "Api")
        lastWord = convertAllCapsToProperCase(lastWord);

        return lastWord;
    }

    /**
     * Converts a hyphenated word to camel case.
     * Example: "user-settings" -> "userSettings"
     *
     * @param word the hyphenated word
     * @return the camel case version
     */
    private String convertHyphenatedToCamelCase(String word) {
        String[] parts = word.split("-");
        StringBuilder result = new StringBuilder();

        for (int i = 0; i < parts.length; i++) {
            String part = parts[i].replaceAll("[^a-zA-Z0-9]", "");
            if (part.isEmpty()) {
                continue;
            }

            if (i == 0) {
                // First part: keep lowercase
                result.append(part.toLowerCase());
            } else {
                // Subsequent parts: capitalize first letter
                result.append(Character.toUpperCase(part.charAt(0)));
                if (part.length() > 1) {
                    result.append(part.substring(1).toLowerCase());
                }
            }
        }

        return result.toString();
    }

    /**
     * Converts an all-caps word to proper case (only first letter uppercase).
     * Example: "API" -> "Api"
     *
     * @param word the word to convert
     * @return the proper case version, or the original word if not all-caps
     */
    private String convertAllCapsToProperCase(String word) {
        if (word.length() <= 1) {
            return word;
        }

        // Check if the word is all uppercase
        boolean isAllCaps = true;
        for (char c : word.toCharArray()) {
            if (Character.isLetter(c) && !Character.isUpperCase(c)) {
                isAllCaps = false;
                break;
            }
        }

        if (isAllCaps) {
            // Convert to: first letter uppercase, rest lowercase
            return Character.toUpperCase(word.charAt(0)) + word.substring(1).toLowerCase();
        }

        return word;
    }

    /**
     * Gets the map of record metadata collected so far.
     *
     * @return the map of record name to RecordMetadata
     */
    public Map<String, RecordMetadata> getRecordMetadataMap() {
        return recordMetadataMap;
    }

    /**
     * Registers a data table usage with type inference based on column values.
     * Analyzes all data rows to infer the most specific type for each column.
     * If a record with the same name already exists, the columns and types are merged.
     *
     * @param stepText the full step text including keyword (e.g., "Given the following users")
     * @param dataTableRows the list of table rows from the data table (header + data rows)
     */
    public void registerDataTableWithTypeInference(String stepText, List<TableRow> dataTableRows) {
        if (dataTableRows == null || dataTableRows.isEmpty()) {
            throw new ProcessingException("Data table has no rows for step: " + stepText);
        }

        // First row is headers
        TableRow headerRow = dataTableRows.get(0);
        List<String> columnHeaders = new ArrayList<>();
        for (TableCell cell : headerRow.getCells()) {
            columnHeaders.add(cell.getValue().trim());
        }

        // Collect values for each column from all data rows
        int columnCount = columnHeaders.size();
        List<List<String>> columnValues = new ArrayList<>(columnCount);
        for (int i = 0; i < columnCount; i++) {
            columnValues.add(new ArrayList<>());
        }

        // Skip header row (index 0), process data rows starting from index 1
        for (int rowIndex = 1; rowIndex < dataTableRows.size(); rowIndex++) {
            TableRow dataRow = dataTableRows.get(rowIndex);
            List<TableCell> cells = dataRow.getCells();

            for (int colIndex = 0; colIndex < columnCount && colIndex < cells.size(); colIndex++) {
                String cellValue = cells.get(colIndex).getValue().trim();
                columnValues.get(colIndex).add(cellValue);
            }
        }

        // Infer type for each column
        List<String> inferredTypes = new ArrayList<>(columnCount);
        for (List<String> values : columnValues) {
            String inferredType = TypeInferenceUtils.inferTypeForColumn(values);
            inferredTypes.add(inferredType);
        }

        // Register the record with inferred types
        String recordName = deriveRecordNameFromStepText(stepText);

        RecordMetadata metadata = recordMetadataMap.computeIfAbsent(
                recordName,
                k -> new RecordMetadata(recordName)
        );

        metadata.mergeColumnsWithTypes(columnHeaders, inferredTypes);
    }

    /**
     * Registers a data table usage with type inference from Examples table columns.
     * For Scenario Outlines, data table cells contain placeholders in angle brackets.
     * This method extracts placeholders from data table cells and infers types from
     * the corresponding Examples table columns.
     *
     * @param stepText the full step text including keyword (e.g., "Given the following users")
     * @param dataTableRows the list of table rows from the data table (header + data rows)
     * @param examples the list of Examples tables from the Scenario Outline
     */
    public void registerDataTableWithExamples(
            String stepText,
            List<TableRow> dataTableRows,
            List<io.cucumber.messages.types.Examples> examples) {

        if (dataTableRows == null || dataTableRows.isEmpty()) {
            throw new ProcessingException("Data table has no rows for step: " + stepText);
        }

        if (examples == null || examples.isEmpty()) {
            throw new ProcessingException("No Examples table found for Scenario Outline with step: " + stepText);
        }

        // Extract column headers from data table
        TableRow headerRow = dataTableRows.get(0);
        List<String> columnHeaders = new ArrayList<>();
        for (TableCell cell : headerRow.getCells()) {
            columnHeaders.add(cell.getValue().trim());
        }

        // Get the first Examples table (multiple Examples tables are merged into one in practice)
        io.cucumber.messages.types.Examples examplesTable = examples.get(0);
        TableRow examplesHeaderRow = examplesTable.getTableHeader().orElseThrow(
                () -> new ProcessingException("Examples table has no header for step: " + stepText)
        );

        // Build a map of Examples column name -> column values for type inference
        List<String> examplesColumnNames = new ArrayList<>();
        for (TableCell cell : examplesHeaderRow.getCells()) {
            examplesColumnNames.add(cell.getValue().trim());
        }

        // Collect values for each Examples column
        int examplesColumnCount = examplesColumnNames.size();
        List<List<String>> examplesColumnValues = new ArrayList<>(examplesColumnCount);
        for (int i = 0; i < examplesColumnCount; i++) {
            examplesColumnValues.add(new ArrayList<>());
        }

        for (TableRow exampleRow : examplesTable.getTableBody()) {
            List<TableCell> cells = exampleRow.getCells();
            for (int colIndex = 0; colIndex < examplesColumnCount && colIndex < cells.size(); colIndex++) {
                String cellValue = cells.get(colIndex).getValue().trim();
                examplesColumnValues.get(colIndex).add(cellValue);
            }
        }

        // For each data table column, determine its type by combining Examples values and literal values
        List<String> dataTableColumnTypes = new ArrayList<>(columnHeaders.size());

        for (int colIndex = 0; colIndex < columnHeaders.size(); colIndex++) {
            // Collect all cell values for this column across all data rows
            List<String> columnCellValues = new ArrayList<>();

            for (int rowIndex = 1; rowIndex < dataTableRows.size(); rowIndex++) {
                TableRow dataRow = dataTableRows.get(rowIndex);
                List<TableCell> cells = dataRow.getCells();

                if (colIndex < cells.size()) {
                    String cellValue = cells.get(colIndex).getValue().trim();
                    columnCellValues.add(cellValue);
                }
            }

            // Determine the type for this column
            String columnType = inferTypeForDataTableColumn(
                    columnCellValues,
                    examplesColumnNames,
                    examplesColumnValues
            );

            dataTableColumnTypes.add(columnType);
        }

        // Register the record with inferred types
        String recordName = deriveRecordNameFromStepText(stepText);

        RecordMetadata metadata = recordMetadataMap.computeIfAbsent(
                recordName,
                k -> new RecordMetadata(recordName)
        );

        metadata.mergeColumnsWithTypes(columnHeaders, dataTableColumnTypes);
    }

    /**
     * Infers the type for a data table column by analyzing cell values and placeholder mappings.
     * Combines Examples column values (for placeholder cells) with literal values from the data table,
     * then infers the type from the combined set of values.
     *
     * @param columnCellValues the list of cell values for this column from all data rows
     * @param examplesColumnNames the list of Examples column names
     * @param examplesColumnValues the list of value lists for each Examples column
     * @return the inferred type for the data table column
     */
    private String inferTypeForDataTableColumn(
            List<String> columnCellValues,
            List<String> examplesColumnNames,
            List<List<String>> examplesColumnValues) {

        // Collect all values that should be considered for type inference:
        // - For placeholder cells: add the corresponding Examples column values
        // - For literal cells: add the literal value itself
        List<String> allValuesForInference = new ArrayList<>();

        for (String cellValue : columnCellValues) {
            if (isExactPlaceholder(cellValue)) {
                // Extract placeholder name (e.g., "<qty>" -> "qty")
                String placeholderName = extractPlaceholderName(cellValue);

                // Find the corresponding Examples column and add its values
                int examplesIndex = examplesColumnNames.indexOf(placeholderName);
                if (examplesIndex >= 0) {
                    allValuesForInference.addAll(examplesColumnValues.get(examplesIndex));
                }
            } else {
                // This is a literal value or mixed content
                allValuesForInference.add(cellValue);
            }
        }

        // Infer type from the combined values
        if (!allValuesForInference.isEmpty()) {
            return TypeInferenceUtils.inferTypeForColumn(allValuesForInference);
        }

        // Default to String if unable to infer
        return "String";
    }

    /**
     * Checks if a cell value is an exact placeholder (e.g., "<qty>").
     *
     * @param cellValue the cell value to check
     * @return true if the cell value is an exact placeholder
     */
    private boolean isExactPlaceholder(String cellValue) {
        return cellValue.matches("^<[^>]+>$");
    }

    /**
     * Extracts the placeholder name from a placeholder string.
     * Example: "<qty>" -> "qty"
     *
     * @param placeholder the placeholder string (e.g., "<qty>")
     * @return the placeholder name (e.g., "qty")
     */
    private String extractPlaceholderName(String placeholder) {
        return placeholder.substring(1, placeholder.length() - 1);
    }

    /**
     * Checks if any data tables have been registered.
     *
     * @return true if at least one data table has been registered, false otherwise
     */
    public boolean hasDataTables() {
        return !recordMetadataMap.isEmpty();
    }
}
