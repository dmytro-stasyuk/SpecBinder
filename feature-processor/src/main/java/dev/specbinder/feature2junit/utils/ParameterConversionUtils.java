package dev.specbinder.feature2junit.utils;

import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;

/**
 * Utility class for converting string parameter values to typed literals.
 */
public class ParameterConversionUtils {

    private ParameterConversionUtils() {
        // utility class
    }

    /**
     * Checks if a string value can be converted to the target type.
     *
     * @param value the string value to convert
     * @param targetType the target type mirror
     * @return true if the value can be converted, false otherwise
     */
    public static boolean canConvert(String value, TypeMirror targetType) {
        TypeKind typeKind = targetType.getKind();
        String typeName = targetType.toString();

        // Handle primitive types
        if (typeKind == TypeKind.INT || "java.lang.Integer".equals(typeName)) {
            return canParseInt(value);
        } else if (typeKind == TypeKind.LONG || "java.lang.Long".equals(typeName)) {
            return canParseLong(value);
        } else if (typeKind == TypeKind.DOUBLE || "java.lang.Double".equals(typeName)) {
            return canParseDouble(value);
        } else if (typeKind == TypeKind.BOOLEAN || "java.lang.Boolean".equals(typeName)) {
            return canParseBoolean(value);
        } else if (typeKind == TypeKind.DECLARED && isEnumType(targetType)) {
            return canParseEnum(value, targetType);
        } else if ("java.lang.String".equals(typeName)) {
            // String values can always be converted to String type
            return true;
        }

        // Any other type (Object, custom types like Person, Account, etc.) cannot be auto-converted
        return false;
    }

    /**
     * Converts a string value to a Java literal suitable for the target type.
     *
     * @param value the string value to convert
     * @param targetType the target type mirror
     * @return the Java literal as a string (e.g., "42", "42L", "19.99", "true")
     */
    public static String toLiteral(String value, TypeMirror targetType) {
        TypeKind typeKind = targetType.getKind();
        String typeName = targetType.toString();

        // Handle primitive types
        if (typeKind == TypeKind.INT || "java.lang.Integer".equals(typeName)) {
            if (canParseInt(value)) {
                return value; // No suffix needed for int
            }
        } else if (typeKind == TypeKind.LONG || "java.lang.Long".equals(typeName)) {
            if (canParseLong(value)) {
                return value + "L"; // Add L suffix for long
            }
        } else if (typeKind == TypeKind.DOUBLE || "java.lang.Double".equals(typeName)) {
            if (canParseDouble(value)) {
                // Check if the value already has a decimal point
                if (value.contains(".")) {
                    return value; // No suffix needed for double with decimal
                } else {
                    return value + ".0"; // Add .0 for whole numbers
                }
            }
        } else if (typeKind == TypeKind.BOOLEAN || "java.lang.Boolean".equals(typeName)) {
            if (canParseBoolean(value)) {
                return value.toLowerCase(); // "true" or "false"
            }
        } else if (typeKind == TypeKind.DECLARED && isEnumType(targetType)) {
            if (canParseEnum(value, targetType)) {
                return toEnumLiteral(value, targetType);
            }
        }

        // Default: return as quoted string
        return "\"" + value + "\"";
    }

    private static boolean canParseInt(String value) {
        try {
            Integer.parseInt(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean canParseLong(String value) {
        try {
            Long.parseLong(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean canParseDouble(String value) {
        try {
            Double.parseDouble(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean canParseBoolean(String value) {
        return "true".equalsIgnoreCase(value) || "false".equalsIgnoreCase(value);
    }

    /**
     * Checks if the given TypeMirror represents an enum type.
     */
    public static boolean isEnumType(TypeMirror typeMirror) {
        if (typeMirror.getKind() != TypeKind.DECLARED) {
            return false;
        }
        DeclaredType declaredType = (DeclaredType) typeMirror;
        Element element = declaredType.asElement();
        return element.getKind() == ElementKind.ENUM;
    }

    /**
     * Gets the fully qualified name of an enum type for use in static imports.
     * Example: "features.MyFeature.DayOfWeek"
     */
    public static String getEnumQualifiedName(TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();
        return enumElement.getQualifiedName().toString();
    }

    /**
     * Checks if the given string value can be parsed as an enum constant of the target type.
     * Enum constant matching is case-sensitive.
     */
    private static boolean canParseEnum(String value, TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();

        // Get all enum constants and check if value matches one
        for (Element enclosed : enumElement.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.ENUM_CONSTANT) {
                if (enclosed.getSimpleName().toString().equals(value)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Converts a string value to an enum literal.
     * Returns just the constant name (e.g., "MONDAY") for use with static imports.
     */
    private static String toEnumLiteral(String value, TypeMirror targetType) {
        // Return just the constant name - static imports will be added separately
        return value;
    }
}
