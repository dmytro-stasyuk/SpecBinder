package dev.specbinder.feature2junit.gherkin.utils;

import dev.specbinder.feature2junit.utils.ConstructorMappingUtils;

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
}
