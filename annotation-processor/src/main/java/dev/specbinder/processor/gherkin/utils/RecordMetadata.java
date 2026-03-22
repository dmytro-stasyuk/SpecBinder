package dev.specbinder.processor.gherkin.utils;

import dev.specbinder.processor.utils.ConstructorMappingUtils;

import javax.lang.model.element.TypeElement;
import java.util.ArrayList;
import java.util.List;

/**
 * Metadata about a generated record type for LIST_OF_OBJECT_PARAMS data table handling.
 * This class stores information about the record name and its fields (columns),
 * and supports merging columns from multiple data table usages.
 */
public class RecordMetadata {

    private final String recordName;
    private final List<String> columnNames;
    private final List<String> columnTypes;

    // Fields for tracking existing type from base class hierarchy
    private TypeElement existingType;
    private ConstructorMappingUtils.MappingResult constructorMapping;

    // Flag indicating that we need to generate an overloaded method
    // This happens when an inherited method exists but its List parameter type
    // doesn't have a constructor that can accept all data table columns
    private boolean needsOverloadedMethod;

    /**
     * Creates a new RecordMetadata with the specified record name.
     *
     * @param recordName the name of the record type (e.g., "Users")
     */
    public RecordMetadata(String recordName) {
        this.recordName = recordName;
        this.columnNames = new ArrayList<>();
        this.columnTypes = new ArrayList<>();
    }

    /**
     * Merges columns from a data table into this record.
     * Maintains insertion order and deduplicates column names.
     * All columns are currently treated as String type.
     *
     * @param newColumns the list of column names to merge
     */
    public void mergeColumns(List<String> newColumns) {
        for (String column : newColumns) {
            if (!columnNames.contains(column)) {
                columnNames.add(column);
                columnTypes.add("String");
            }
        }
    }

    /**
     * Merges columns with their inferred types from a data table into this record.
     * Maintains insertion order and deduplicates column names.
     * If a column already exists with a different type, the type is updated to String
     * to ensure compatibility with all usages.
     *
     * @param newColumns the list of column names to merge
     * @param newTypes the list of inferred types corresponding to the column names
     */
    public void mergeColumnsWithTypes(List<String> newColumns, List<String> newTypes) {
        if (newColumns.size() != newTypes.size()) {
            throw new IllegalArgumentException(
                    "Column names and types must have the same size. Got " +
                    newColumns.size() + " columns and " + newTypes.size() + " types."
            );
        }

        for (int i = 0; i < newColumns.size(); i++) {
            String column = newColumns.get(i);
            String type = newTypes.get(i);

            int existingIndex = columnNames.indexOf(column);
            if (existingIndex >= 0) {
                // Column already exists - check if types match
                String existingType = columnTypes.get(existingIndex);
                if (!existingType.equals(type)) {
                    // Type conflict - fall back to String
                    columnTypes.set(existingIndex, "String");
                }
            } else {
                // New column - add it with its type
                columnNames.add(column);
                columnTypes.add(type);
            }
        }
    }

    /**
     * Gets the record name.
     *
     * @return the record name (e.g., "Users")
     */
    public String getRecordName() {
        return recordName;
    }

    /**
     * Gets the ordered list of column names for this record.
     *
     * @return the list of column names
     */
    public List<String> getColumnNames() {
        return columnNames;
    }

    /**
     * Gets the ordered list of column types for this record.
     * Currently all types are "String".
     *
     * @return the list of column types
     */
    public List<String> getColumnTypes() {
        return columnTypes;
    }

    /**
     * Sets the existing type from the base class hierarchy and its constructor mapping.
     *
     * @param existingType the TypeElement representing the existing inner type
     * @param mapping the mapping result showing how data table columns map to constructor parameters
     */
    public void setExistingType(TypeElement existingType, ConstructorMappingUtils.MappingResult mapping) {
        this.existingType = existingType;
        this.constructorMapping = mapping;
    }

    /**
     * Checks if this record metadata has an existing type from the base class hierarchy.
     *
     * @return true if an existing type is being reused, false otherwise
     */
    public boolean hasExistingType() {
        return existingType != null;
    }

    /**
     * Gets the existing type from the base class hierarchy, if any.
     *
     * @return the TypeElement representing the existing inner type, or null if none
     */
    public TypeElement getExistingType() {
        return existingType;
    }

    /**
     * Gets the constructor mapping result for the existing type.
     *
     * @return the MappingResult showing how columns map to constructor parameters, or null if no existing type
     */
    public ConstructorMappingUtils.MappingResult getConstructorMapping() {
        return constructorMapping;
    }

    /**
     * Sets the flag indicating that an overloaded method needs to be generated.
     * This is set when an inherited method exists but its List parameter type
     * doesn't have a constructor that can accept all data table columns.
     *
     * @param needsOverloadedMethod true if an overloaded method should be generated
     */
    public void setNeedsOverloadedMethod(boolean needsOverloadedMethod) {
        this.needsOverloadedMethod = needsOverloadedMethod;
    }

    /**
     * Checks if an overloaded method needs to be generated for this record type.
     *
     * @return true if an overloaded method should be generated, false otherwise
     */
    public boolean needsOverloadedMethod() {
        return needsOverloadedMethod;
    }
}
