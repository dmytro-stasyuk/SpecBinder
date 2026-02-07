package dev.specbinder.feature2junit.gherkin.utils;

import java.util.List;

/**
 * Utility class for inferring types from data table column values.
 * Follows the type precedence order: Boolean, Integer, Long, Double, Character, then String.
 */
public class TypeInferenceUtils {

    private TypeInferenceUtils() {
        // Private constructor to prevent instantiation
    }

    /**
     * Infers the most specific type that can accommodate all values in a column.
     * Type checking follows precedence order: Boolean, Integer, Long, Double, Character, then String.
     *
     * @param values the list of string values from a data table column
     * @return the Java type name (e.g., "Boolean", "Integer", "Long", "Double", "Character", "String")
     */
    public static String inferTypeForColumn(List<String> values) {
        if (values == null || values.isEmpty()) {
            return "String";
        }

        // Try each type in precedence order
        // All values must be convertible to the type for it to be selected

        if (allValuesAreType(values, TypeInferenceUtils::isBoolean)) {
            return "Boolean";
        }

        if (allValuesAreType(values, TypeInferenceUtils::isInteger)) {
            return "Integer";
        }

        if (allValuesAreType(values, TypeInferenceUtils::isLong)) {
            return "Long";
        }

        if (allValuesAreType(values, TypeInferenceUtils::isDouble)) {
            return "Double";
        }

        if (allValuesAreType(values, TypeInferenceUtils::isCharacter)) {
            return "Character";
        }

        // Default fallback
        return "String";
    }

    /**
     * Checks if all non-empty values in the list match the given type predicate.
     * Empty or null values are skipped during type checking, as they will be
     * converted to null in the generated code.
     *
     * @param values the list of values to check
     * @param typePredicate the predicate to test each value
     * @return true if all non-empty values match the predicate, false otherwise
     */
    private static boolean allValuesAreType(List<String> values, TypePredicate typePredicate) {
        boolean hasNonEmptyValue = false;
        for (String value : values) {
            // Skip empty values - they will become null in generated code
            if (value == null || value.isEmpty()) {
                continue;
            }
            hasNonEmptyValue = true;
            if (!typePredicate.test(value)) {
                return false;
            }
        }
        // If all values were empty, return false to fall back to String type
        return hasNonEmptyValue;
    }

    /**
     * Checks if a value can be parsed as a Boolean.
     *
     * @param value the value to check
     * @return true if the value is "true" or "false" (case-insensitive), false otherwise
     */
    private static boolean isBoolean(String value) {
        return "true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value);
    }

    /**
     * Checks if a value can be parsed as an Integer (32-bit signed integer).
     *
     * @param value the value to check
     * @return true if the value can be parsed by Integer.parseInt(), false otherwise
     */
    private static boolean isInteger(String value) {
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Checks if a value can be parsed as a Long (64-bit signed integer).
     *
     * @param value the value to check
     * @return true if the value can be parsed by Long.parseLong(), false otherwise
     */
    private static boolean isLong(String value) {
        try {
            Long.parseLong(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Checks if a value can be parsed as a Double (floating-point number).
     *
     * @param value the value to check
     * @return true if the value can be parsed by Double.parseDouble(), false otherwise
     */
    private static boolean isDouble(String value) {
        try {
            Double.parseDouble(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Checks if a value is exactly one character long.
     *
     * @param value the value to check
     * @return true if the value is exactly one character, false otherwise
     */
    private static boolean isCharacter(String value) {
        return value != null && value.length() == 1;
    }

    /**
     * Functional interface for type checking predicates.
     */
    @FunctionalInterface
    private interface TypePredicate {
        boolean test(String value);
    }
}
