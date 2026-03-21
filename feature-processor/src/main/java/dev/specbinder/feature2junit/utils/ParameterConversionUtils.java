package dev.specbinder.feature2junit.utils;

import com.squareup.javapoet.TypeName;
import io.cucumber.messages.types.Examples;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.*;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Utility class for converting string parameter values to typed literals.
 */
public class ParameterConversionUtils {

    private static EnumFactoryMethodResolver factoryMethodResolver;

    private ParameterConversionUtils() {
        // utility class
    }

    /**
     * Sets the factory method resolver for enum type conversion.
     * Should be called at the start of annotation processing.
     */
    public static void setFactoryMethodResolver(EnumFactoryMethodResolver resolver) {
        factoryMethodResolver = resolver;
    }

    /**
     * Gets the current factory method resolver, or null if not set.
     */
    public static EnumFactoryMethodResolver getFactoryMethodResolver() {
        return factoryMethodResolver;
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
        } else if (typeKind == TypeKind.FLOAT || "java.lang.Float".equals(typeName)) {
            return canParseFloat(value);
        } else if (typeKind == TypeKind.DOUBLE || "java.lang.Double".equals(typeName)) {
            return canParseDouble(value);
        } else if (typeKind == TypeKind.BYTE || "java.lang.Byte".equals(typeName)) {
            return canParseByte(value);
        } else if (typeKind == TypeKind.SHORT || "java.lang.Short".equals(typeName)) {
            return canParseShort(value);
        } else if (typeKind == TypeKind.BOOLEAN || "java.lang.Boolean".equals(typeName)) {
            return canParseBoolean(value);
        } else if (typeKind == TypeKind.CHAR || "java.lang.Character".equals(typeName)) {
            return value.length() == 1;
        } else if (typeKind == TypeKind.DECLARED && isEnumType(targetType)) {
            // Always consider enum types as convertible for method matching purposes.
            // If the value can't be resolved to a constant (via direct match or factory method),
            // the raw string literal will be placed at the call site, causing a compilation error.
            return true;
        } else if ("java.lang.String".equals(typeName)) {
            return true;
        } else if ("java.math.BigDecimal".equals(typeName)) {
            return canParseDouble(value);
        } else if ("java.math.BigInteger".equals(typeName)) {
            return canParseLong(value);
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
        } else if (typeKind == TypeKind.FLOAT || "java.lang.Float".equals(typeName)) {
            if (canParseFloat(value)) {
                return value + "F"; // Add F suffix for float
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
        } else if (typeKind == TypeKind.BYTE || "java.lang.Byte".equals(typeName)) {
            if (canParseByte(value)) {
                return "(byte) " + value; // Cast for byte
            }
        } else if (typeKind == TypeKind.SHORT || "java.lang.Short".equals(typeName)) {
            if (canParseShort(value)) {
                return "(short) " + value; // Cast for short
            }
        } else if (typeKind == TypeKind.BOOLEAN || "java.lang.Boolean".equals(typeName)) {
            if (canParseBoolean(value)) {
                return value.toLowerCase(); // "true" or "false"
            }
        } else if (typeKind == TypeKind.CHAR || "java.lang.Character".equals(typeName)) {
            if (value.length() == 1) {
                return "'" + value + "'"; // Return as character literal
            }
        } else if (typeKind == TypeKind.DECLARED && isEnumType(targetType)) {
            if (canParseEnum(value, targetType)) {
                return toEnumLiteral(value, targetType);
            }
        } else if ("java.math.BigDecimal".equals(typeName)) {
            if (canParseDouble(value)) {
                return "new BigDecimal(\"" + value + "\")";
            }
        } else if ("java.math.BigInteger".equals(typeName)) {
            if (canParseLong(value)) {
                return "new BigInteger(\"" + value + "\")";
            }
        }

        // Default: return as quoted string
        // Escape $ as $$ for JavaPoet's CodeBlock.of() which uses $ as format specifier
        return "\"" + value.replace("$", "$$") + "\"";
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

    private static boolean canParseFloat(String value) {
        try {
            Float.parseFloat(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean canParseByte(String value) {
        try {
            Byte.parseByte(value);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean canParseShort(String value) {
        try {
            Short.parseShort(value);
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
     * @param typeMirror the type mirror to check
     * @return true if the type is an enum, false otherwise
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
     * @param targetType the enum type mirror
     * @return the fully qualified name of the enum type
     */
    public static String getEnumQualifiedName(TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();
        return enumElement.getQualifiedName().toString();
    }

    /**
     * Checks if the given string value can be parsed as an enum constant of the target type.
     * First tries direct constant matching (case-sensitive), then falls back to a suitable
     * static factory method if one exists on the enum type.
     * @return true if the value matches an enum constant or can be resolved via factory method
     */
    private static boolean canParseEnum(String value, TypeMirror targetType) {
        return resolveEnumConstantName(value, targetType) != null;
    }

    /**
     * Resolves a string value to an enum constant name.
     * First tries direct constant matching (case-sensitive). If no match, falls back to
     * invoking a suitable static factory method on the enum type (if exactly one exists).
     * @param value the string value to resolve
     * @param targetType the enum type mirror
     * @return the enum constant name (e.g., "MONDAY"), or null if it cannot be resolved
     */
    public static String resolveEnumConstantName(String value, TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();

        // First, try direct constant match (case-sensitive)
        for (Element enclosed : enumElement.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.ENUM_CONSTANT) {
                if (enclosed.getSimpleName().toString().equals(value)) {
                    return value;
                }
            }
        }

        // Fallback: try factory method resolution
        ExecutableElement factoryMethod = findSuitableFactoryMethod(enumElement);
        if (factoryMethod != null) {
            return invokeFactoryMethod(value, targetType, factoryMethod.getSimpleName().toString());
        }

        return null;
    }

    /**
     * Finds exactly one suitable static factory method on the enum type.
     * A suitable factory method is: non-private, static, accepts a single String parameter,
     * and returns the enum type. If zero or more than one suitable method exists, returns null.
     */
    private static ExecutableElement findSuitableFactoryMethod(TypeElement enumElement) {
        ExecutableElement factoryMethod = null;
        int count = 0;

        for (Element enclosed : enumElement.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.METHOD) {
                ExecutableElement method = (ExecutableElement) enclosed;
                if (isSuitableFactoryMethod(method, enumElement)) {
                    count++;
                    factoryMethod = method;
                }
            }
        }

        return count == 1 ? factoryMethod : null;
    }

    /**
     * Checks if a method is a suitable factory method for the given enum type.
     * Must be: non-private, static, single String parameter, returns the enum type.
     * Excludes the compiler-generated valueOf(String) method since direct constant
     * matching is already performed before the factory method fallback.
     */
    private static boolean isSuitableFactoryMethod(ExecutableElement method, TypeElement enumElement) {
        // Exclude compiler-generated valueOf(String) - already handled by direct constant matching
        if ("valueOf".equals(method.getSimpleName().toString())) {
            return false;
        }
        // Must be static
        if (!method.getModifiers().contains(Modifier.STATIC)) {
            return false;
        }
        // Must not be private
        if (method.getModifiers().contains(Modifier.PRIVATE)) {
            return false;
        }
        // Must have exactly one parameter
        if (method.getParameters().size() != 1) {
            return false;
        }
        // Parameter must be String
        if (!"java.lang.String".equals(method.getParameters().get(0).asType().toString())) {
            return false;
        }
        // Return type must be the enum type
        TypeMirror returnType = method.getReturnType();
        if (returnType.getKind() != TypeKind.DECLARED) {
            return false;
        }
        DeclaredType returnDeclaredType = (DeclaredType) returnType;
        return returnDeclaredType.asElement().equals(enumElement);
    }

    /**
     * Invokes the factory method to resolve a string value to an enum constant name.
     * Delegates to the EnumFactoryMethodResolver which handles both pre-compiled classes
     * and classes being compiled in the same javac invocation.
     * @return the enum constant name (e.g., "MONDAY"), or null if resolution fails
     */
    private static String invokeFactoryMethod(String value, TypeMirror targetType, String factoryMethodName) {
        if (factoryMethodResolver != null) {
            return factoryMethodResolver.resolve(value, targetType, factoryMethodName);
        }
        return null;
    }

    /**
     * Converts a string value to an enum literal.
     * Resolves the value to the actual enum constant name (e.g., "monday" → "MONDAY")
     * using direct matching or factory method fallback.
     * @param value the string value to convert
     */
    private static String toEnumLiteral(String value, TypeMirror targetType) {
        String constantName = resolveEnumConstantName(value, targetType);
        return constantName != null ? constantName : value;
    }

    /**
     * Converts a string value to a qualified enum literal.
     * Returns the enum type simple name and resolved constant (e.g., "Status.AVAILABLE").
     * Resolves the value to the actual enum constant name using direct matching or factory method fallback.
     * @param value the string value to convert
     * @param targetType the target enum type
     * @return the qualified enum literal (e.g., "Status.AVAILABLE")
     */
    public static String toQualifiedEnumLiteral(String value, TypeMirror targetType) {
        String enumSimpleName = getEnumSimpleName(targetType);
        String constantName = resolveEnumConstantName(value, targetType);
        return enumSimpleName + "." + (constantName != null ? constantName : value);
    }

    /**
     * Gets the simple name of an enum type.
     * @param targetType the enum type mirror
     * @return the simple name of the enum type (e.g., "Status")
     */
    public static String getEnumSimpleName(TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();
        return enumElement.getSimpleName().toString();
    }

    /**
     * Gets the simple name of the enclosing class of an enum type.
     * For nested enums like ProductsFeature.Status, returns "ProductsFeature".
     * @param targetType the enum type mirror
     * @return the simple name of the enclosing class, or null if the enum is not nested
     */
    public static String getEnclosingClassName(TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();
        Element enclosingElement = enumElement.getEnclosingElement();
        if (enclosingElement != null && enclosingElement.getKind() == ElementKind.CLASS) {
            return ((TypeElement) enclosingElement).getSimpleName().toString();
        }
        return null;
    }

    /**
     * Result of inferring column types from Examples tables.
     */
    public static class InferredColumnTypes {
        /**
         * Type names for each column index.
         */
        public final Map<Integer, TypeName> typeNames;
        /**
         * Enum type mirrors for enum columns.
         */
        public final Map<Integer, TypeMirror> enumTypes;

        /**
         * Constructor.
         * @param typeNames type names for each column index
         * @param enumTypes enum type mirrors for enum columns
         */
        public InferredColumnTypes(Map<Integer, TypeName> typeNames, Map<Integer, TypeMirror> enumTypes) {
            this.typeNames = typeNames;
            this.enumTypes = enumTypes;
        }
    }

    /**
     * Infers parameter types for each column in the Examples tables.
     * Analyzes all values in each column across all Examples sections and determines
     * the most appropriate type using the following precedence:
     * Enum (if all values match enum constants) -> Boolean -> Integer -> Long -> Double -> Character -> String
     *
     * @param examples list of Examples tables from a Scenario Outline
     * @param baseType the base class TypeElement (used to find enum types)
     * @param processingEnv the processing environment
     * @return InferredColumnTypes containing TypeNames and TypeMirrors for enum columns
     */
    public static InferredColumnTypes inferColumnTypes(List<Examples> examples, TypeElement baseType, ProcessingEnvironment processingEnv) {
        return inferColumnTypes(examples, baseType, processingEnv, null);
    }

    /**
     * Infers parameter types for each column in the Examples tables.
     * Analyzes all values in each column across all Examples sections and determines
     * the most appropriate type using the following precedence:
     * Enum (if all values match enum constants) -> Boolean -> Integer -> Long -> Double -> Character -> String
     *
     * @param examples list of Examples tables from a Scenario Outline
     * @param baseType the base class TypeElement (used to find enum types)
     * @param processingEnv the processing environment
     * @param parameterClassFieldTypes optional map of column name to TypeMirror for parameter class fields
     * @return InferredColumnTypes containing TypeNames and TypeMirrors for enum columns
     */
    public static InferredColumnTypes inferColumnTypes(List<Examples> examples, TypeElement baseType, ProcessingEnvironment processingEnv, Map<String, TypeMirror> parameterClassFieldTypes) {
        if (examples == null || examples.isEmpty()) {
            return new InferredColumnTypes(Map.of(), Map.of());
        }

        // Get column names from the first Examples table header
        List<TableRow> tableHeader = examples.get(0).getTableHeader().stream().toList();
        if (tableHeader.isEmpty()) {
            return new InferredColumnTypes(Map.of(), Map.of());
        }

        List<String> columnNames = tableHeader.get(0).getCells().stream()
                .map(TableCell::getValue)
                .toList();

        int columnCount = columnNames.size();
        Map<Integer, TypeName> columnTypeNames = new HashMap<>();
        Map<Integer, TypeMirror> enumTypeMirrors = new HashMap<>();

        // For each column, analyze all values across all Examples sections
        for (int columnIndex = 0; columnIndex < columnCount; columnIndex++) {
            String columnName = columnNames.get(columnIndex);
            ColumnTypeInfo typeInfo = inferColumnType(examples, columnIndex, baseType, processingEnv, columnName, parameterClassFieldTypes);
            columnTypeNames.put(columnIndex, typeInfo.typeName);
            if (typeInfo.enumType != null) {
                enumTypeMirrors.put(columnIndex, typeInfo.enumType);
            }
        }

        return new InferredColumnTypes(columnTypeNames, enumTypeMirrors);
    }

    /**
     * Information about an inferred column type.
     */
    private static class ColumnTypeInfo {
        final TypeName typeName;
        final TypeMirror enumType; // null if not an enum

        ColumnTypeInfo(TypeName typeName, TypeMirror enumType) {
            this.typeName = typeName;
            this.enumType = enumType;
        }
    }

    /**
     * Infers the type for a single column by analyzing all values in that column
     * across all Examples sections.
     *
     * @param examples list of Examples tables
     * @param columnIndex the column index to analyze
     * @param baseType the base class TypeElement (used to find enum types)
     * @param processingEnv the processing environment
     * @param columnName the name of the column being analyzed
     * @param parameterClassFieldTypes optional map of column name to TypeMirror for parameter class fields
     * @return the inferred column type info
     */
    private static ColumnTypeInfo inferColumnType(List<Examples> examples, int columnIndex, TypeElement baseType, ProcessingEnvironment processingEnv, String columnName, Map<String, TypeMirror> parameterClassFieldTypes) {
        // Collect all values in this column across all Examples sections
        List<String> columnValues = new java.util.ArrayList<>();

        for (Examples examplesTable : examples) {
            List<TableRow> tableBody = examplesTable.getTableBody();

            for (TableRow row : tableBody) {
                List<TableCell> cells = row.getCells();
                if (columnIndex >= cells.size()) {
                    continue; // Skip if row doesn't have this column
                }
                columnValues.add(cells.get(columnIndex).getValue());
            }
        }

        // First, check if this column corresponds to a field in the parameter class
        // and if that field is an enum type
        if (parameterClassFieldTypes != null && columnName != null) {
            TypeMirror fieldType = parameterClassFieldTypes.get(columnName);
            if (fieldType != null && isEnumType(fieldType)) {
                // Verify all values match this enum's constants
                DeclaredType declaredType = (DeclaredType) fieldType;
                TypeElement enumElement = (TypeElement) declaredType.asElement();
                if (allValuesMatchEnumConstants(columnValues, enumElement)) {
                    return new ColumnTypeInfo(TypeName.get(fieldType), fieldType);
                }
            }
        }

        // If not found in parameter class, check if all values match enum constants from the base class
        TypeMirror matchingEnumType = findMatchingEnumType(columnValues, baseType, processingEnv);
        if (matchingEnumType != null) {
            return new ColumnTypeInfo(TypeName.get(matchingEnumType), matchingEnumType);
        }

        // If not enum, check primitive types
        boolean allBoolean = true;
        boolean allInteger = true;
        boolean allLong = true;
        boolean allDouble = true;
        boolean allCharacter = true;
        boolean hasNonEmptyValue = false;

        for (String value : columnValues) {
            // Skip empty values - they will be converted to null in generated code
            String trimmedValue = value.trim();
            if (trimmedValue.isEmpty()) {
                continue;
            }
            hasNonEmptyValue = true;

            // Check type compatibility following precedence order
            if (allBoolean && !canParseBoolean(trimmedValue)) {
                allBoolean = false;
            }
            if (allInteger && !canParseInt(trimmedValue)) {
                allInteger = false;
            }
            if (allLong && !canParseLong(trimmedValue)) {
                allLong = false;
            }
            if (allDouble && !canParseDouble(trimmedValue)) {
                allDouble = false;
            }
            if (allCharacter && trimmedValue.length() != 1) {
                allCharacter = false;
            }
        }

        // If all values were empty, fall back to String type
        if (!hasNonEmptyValue) {
            return new ColumnTypeInfo(TypeName.get(String.class), null);
        }

        // Return the most specific type that all non-empty values can convert to
        // Following precedence: Boolean -> Integer -> Long -> Double -> Character -> String
        if (allBoolean) {
            return new ColumnTypeInfo(TypeName.get(Boolean.class), null);
        }
        if (allInteger) {
            return new ColumnTypeInfo(TypeName.get(Integer.class), null);
        }
        if (allLong) {
            return new ColumnTypeInfo(TypeName.get(Long.class), null);
        }
        if (allDouble) {
            return new ColumnTypeInfo(TypeName.get(Double.class), null);
        }
        if (allCharacter) {
            return new ColumnTypeInfo(TypeName.get(Character.class), null);
        }

        // Default fallback
        return new ColumnTypeInfo(TypeName.get(String.class), null);
    }

    /**
     * Finds an enum type from the base class where all given values match enum constants.
     *
     * @param values the list of string values to check
     * @param baseType the base class TypeElement
     * @param processingEnv the processing environment
     * @return the matching enum TypeMirror, or null if no match found
     */
    private static TypeMirror findMatchingEnumType(List<String> values, TypeElement baseType, ProcessingEnvironment processingEnv) {
        if (baseType == null || values.isEmpty()) {
            return null;
        }

        // Get all enum types from the base class (including nested enums)
        List<TypeElement> enumTypes = new java.util.ArrayList<>();
        collectEnumTypes(baseType, enumTypes);

        // Check each enum type to see if all values match its constants
        for (TypeElement enumType : enumTypes) {
            if (allValuesMatchEnumConstants(values, enumType)) {
                return enumType.asType();
            }
        }

        return null;
    }

    /**
     * Collects all enum types from the given type element, including nested enums.
     *
     * @param typeElement the type element to search
     * @param enumTypes the list to collect enum types into
     */
    private static void collectEnumTypes(TypeElement typeElement, List<TypeElement> enumTypes) {
        for (Element enclosed : typeElement.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.ENUM) {
                enumTypes.add((TypeElement) enclosed);
            }
            // Recursively check nested classes for enums
            if (enclosed.getKind() == ElementKind.CLASS && enclosed instanceof TypeElement) {
                collectEnumTypes((TypeElement) enclosed, enumTypes);
            }
        }
    }

    /**
     * Checks if all non-empty values match enum constants of the given enum type.
     * Empty or null values are skipped during checking.
     * Matching is case-sensitive (value must match enum constant exactly).
     *
     * @param values the values to check
     * @param enumType the enum type
     * @return true if all non-empty values match enum constants, false otherwise
     */
    private static boolean allValuesMatchEnumConstants(List<String> values, TypeElement enumType) {
        // Get all enum constants
        java.util.Set<String> enumConstants = new java.util.HashSet<>();
        for (Element enclosed : enumType.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.ENUM_CONSTANT) {
                enumConstants.add(enclosed.getSimpleName().toString());
            }
        }

        boolean hasNonEmptyValue = false;
        // Check if all non-empty values match (case-sensitive) either directly or via factory method
        for (String value : values) {
            // Skip empty values - they will be converted to null in generated code
            String trimmedValue = value.trim();
            if (trimmedValue.isEmpty()) {
                continue;
            }
            hasNonEmptyValue = true;
            if (!enumConstants.contains(trimmedValue)) {
                // Try resolving via factory method fallback
                String resolved = resolveEnumConstantName(trimmedValue, enumType.asType());
                if (resolved == null) {
                    return false;
                }
            }
        }

        // If all values were empty, return false to fall back to another type
        return hasNonEmptyValue;
    }

    /**
     * Infers the most specific type that a string value can convert to.
     * Follows type precedence: Boolean → Integer → Long → Double → Character → String
     *
     * @param value the string value to analyze
     * @return the inferred type (Boolean.class, Integer.class, Long.class,
     *         Double.class, Character.class, or String.class)
     */
    public static Class<?> inferType(String value) {
        // Check type compatibility following precedence order
        if (canParseBoolean(value)) {
            return Boolean.class;
        }
        if (canParseInt(value)) {
            return Integer.class;
        }
        if (canParseLong(value)) {
            return Long.class;
        }
        if (canParseDouble(value)) {
            return Double.class;
        }
        if (value.length() == 1) {
            return Character.class;
        }

        // Default fallback
        return String.class;
    }

    /**
     * Extracts field types from a parameter class constructor.
     * Maps parameter names to their TypeMirrors.
     *
     * @param parameterClass the parameter class TypeElement
     * @param processingEnv the processing environment
     * @return a map of parameter name to TypeMirror, or null if constructor not found
     */
    public static Map<String, TypeMirror> extractParameterClassFieldTypes(TypeElement parameterClass, ProcessingEnvironment processingEnv) {
        if (parameterClass == null) {
            return null;
        }

        // Find the all-args constructor
        javax.lang.model.element.ExecutableElement constructor = findAllArgsConstructor(parameterClass);
        if (constructor == null) {
            return null;
        }

        // Extract parameter names and types
        Map<String, TypeMirror> fieldTypes = new HashMap<>();
        List<? extends javax.lang.model.element.VariableElement> parameters = constructor.getParameters();
        for (javax.lang.model.element.VariableElement param : parameters) {
            String paramName = param.getSimpleName().toString();
            TypeMirror paramType = param.asType();
            fieldTypes.put(paramName, paramType);
        }

        return fieldTypes;
    }

    /**
     * Finds the all-args constructor for a class.
     *
     * @param typeElement the class type
     * @return the constructor element, or null if not found
     */
    private static javax.lang.model.element.ExecutableElement findAllArgsConstructor(TypeElement typeElement) {
        // Find constructor with public or package-private visibility
        for (javax.lang.model.element.Element element : typeElement.getEnclosedElements()) {
            if (element.getKind() == javax.lang.model.element.ElementKind.CONSTRUCTOR) {
                javax.lang.model.element.ExecutableElement constructor = (javax.lang.model.element.ExecutableElement) element;

                // Skip private constructors
                if (constructor.getModifiers().contains(javax.lang.model.element.Modifier.PRIVATE)) {
                    continue;
                }

                // Return the first non-private constructor
                // (For parameter classes, there should typically be only one public constructor)
                return constructor;
            }
        }

        return null;
    }
}
