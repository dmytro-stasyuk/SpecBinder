package dev.specbinder.feature2junit.gherkin.utils;

import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.FieldSpec;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeName;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.feature2junit.utils.ParameterNamingUtils;

import javax.lang.model.element.Modifier;
import java.util.List;

/**
 * Generates JavaPoet TypeSpec for record-like class types based on RecordMetadata.
 * Since JavaPoet 1.13.0 doesn't support Java records directly, we generate
 * an immutable class that behaves like a record (public static class with
 * private final fields and public accessor methods).
 */
public class RecordGenerator {

    /**
     * Private constructor to prevent instantiation.
     */
    private RecordGenerator() {
        /**
         * utility class
         */
    }

    /**
     * Generates a record-style class TypeSpec from RecordMetadata.
     * The generated class will be public static, with private final fields
     * and public accessor methods for each column.
     * Field names are sanitized to valid Java identifiers using ParameterNamingUtils.
     * Field types are inferred from the column types in the metadata.
     *
     * @param metadata the record metadata containing name and column information
     * @return a TypeSpec representing the record-like class type
     */
    public static TypeSpec generateRecord(RecordMetadata metadata) {
        String recordName = metadata.getRecordName();
        List<String> columnNames = metadata.getColumnNames();
        List<String> columnTypes = metadata.getColumnTypes();

        // Create a public static class (record-like pattern)
        TypeSpec.Builder classBuilder = TypeSpec.classBuilder(recordName)
                .addModifiers(Modifier.PUBLIC, Modifier.STATIC);

        // Build constructor parameters and add fields
        MethodSpec.Builder constructorBuilder = MethodSpec.constructorBuilder()
                .addModifiers(Modifier.PUBLIC);

        for (int i = 0; i < columnNames.size(); i++) {
            String columnName = columnNames.get(i);
            String columnType = columnTypes.get(i);

            // Convert column name to valid Java field name (camelCase)
            String fieldName = ParameterNamingUtils.toMethodParameterName(columnName);

            // Get the TypeName for the inferred type
            TypeName fieldType = getTypeNameForColumnType(columnType);

            // Add private final field
            FieldSpec field = FieldSpec.builder(fieldType, fieldName)
                    .addModifiers(Modifier.PRIVATE, Modifier.FINAL)
                    .build();
            classBuilder.addField(field);

            // Add parameter to constructor
            constructorBuilder.addParameter(fieldType, fieldName);
            constructorBuilder.addStatement("this.$N = $N", fieldName, fieldName);

            // Add public accessor method (same name as field, record-style)
            MethodSpec accessor = MethodSpec.methodBuilder(fieldName)
                    .addModifiers(Modifier.PUBLIC)
                    .returns(fieldType)
                    .addStatement("return this.$N", fieldName)
                    .build();
            classBuilder.addMethod(accessor);
        }

        classBuilder.addMethod(constructorBuilder.build());

        return classBuilder.build();
    }

    /**
     * Converts a column type string to the corresponding JavaPoet TypeName.
     * Supports Java wrapper types and String.
     *
     * @param columnType the column type string (e.g., "Boolean", "Integer", "String")
     * @return the corresponding TypeName
     */
    private static TypeName getTypeNameForColumnType(String columnType) {
        return switch (columnType) {
            case "Boolean" -> ClassName.get(Boolean.class);
            case "Integer" -> ClassName.get(Integer.class);
            case "Long" -> ClassName.get(Long.class);
            case "Double" -> ClassName.get(Double.class);
            case "Character" -> ClassName.get(Character.class);
            default -> ClassName.get(String.class);
        };
    }
}
