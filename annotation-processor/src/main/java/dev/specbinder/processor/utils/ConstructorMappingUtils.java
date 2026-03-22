package dev.specbinder.processor.utils;

import java.util.*;

/**
 * Utility class for mapping data table columns to constructor parameters.
 */
public class ConstructorMappingUtils {

    private ConstructorMappingUtils() {
        /**
         * utility class
         */
    }


    /**
     * Result of a mapping attempt between data table columns and constructor parameters.
     */
    public static class MappingResult {
        private final boolean canMap;
        private final List<String> constructorParamNames;
        private final Map<Integer, String> paramIndexToColumnName;

        /**
         * Creates a new MappingResult.
         * @param canMap true if all columns can be mapped, false otherwise
         * @param constructorParamNames list of constructor parameter names in order
         * @param paramIndexToColumnName mapping from constructor parameter index to original column name
         */
        public MappingResult(
                boolean canMap,
                List<String> constructorParamNames,
                Map<Integer, String> paramIndexToColumnName) {
            this.canMap = canMap;
            this.constructorParamNames = constructorParamNames;
            this.paramIndexToColumnName = paramIndexToColumnName;
        }

        /**
         * Returns true if all data table columns can be mapped to constructor parameters.
         * @return true if mapping is possible, false otherwise
         */
        public boolean canMap() {
            return canMap;
        }

        /**
         * Returns the list of constructor parameter names in order.
         * @return list of constructor parameter names
         */
        public List<String> getConstructorParamNames() {
            return constructorParamNames;
        }

        /**
         * Returns the mapping from constructor parameter index to original column name.
         * @return map from constructor parameter index to original column name.
         *         If a parameter index is not in the map, that parameter should be passed as null.
         */
        public Map<Integer, String> getParamIndexToColumnName() {
            return paramIndexToColumnName;
        }
    }

    /**
     * Attempts to map data table columns to constructor parameters.
     * <p>
     * Algorithm:
     * 1. Normalize all column names using ParameterNamingUtils.toMethodParameterName()
     * 2. Build map: normalized field name → original column name
     * 3. For each constructor param (in order):
     *    - If param name in normalized map: record mapping
     *    - Else: record null (unmapped parameter)
     * 4. Check all columns were used (no leftover columns)
     * 5. Return MappingResult
     * <p>
     * Example:
     * Columns: ["first name", "age"]
     * Params: ["firstName", "age", "emailAddress"]
     * Result: canMap=true, mapping={0 → "first name", 1 → "age", 2 → null}
     *
     * @param columnNames raw column names from data table
     * @param constructorParamNames constructor parameters in order
     * @return MappingResult with mapping details
     */
    public static MappingResult tryMapColumnsToConstructor(
            List<String> columnNames, List<String> constructorParamNames) {

        // Step 1: Normalize column names and build lookup map
        Map<String, String> normalizedToOriginal = new HashMap<>();
        for (String column : columnNames) {
            String normalized = ParameterNamingUtils.toMethodParameterName(column);
            normalizedToOriginal.put(normalized, column);
        }

        // Step 2: Map constructor parameters to columns
        Map<Integer, String> paramIndexToColumn = new HashMap<>();
        Set<String> usedColumns = new HashSet<>();

        for (int i = 0; i < constructorParamNames.size(); i++) {
            String paramName = constructorParamNames.get(i);
            String columnName = normalizedToOriginal.get(paramName);

            if (columnName != null) {
                paramIndexToColumn.put(i, columnName);
                usedColumns.add(columnName);
            }
            // else: unmapped parameter, will use null
        }

        // Step 3: Verify all columns were used
        boolean allColumnsUsed = usedColumns.size() == columnNames.size();

        return new MappingResult(allColumnsUsed, constructorParamNames, paramIndexToColumn);
    }
}
