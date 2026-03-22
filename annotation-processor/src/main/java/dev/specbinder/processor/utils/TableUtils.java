package dev.specbinder.processor.utils;

import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.ParameterizedTypeName;
import dev.specbinder.processor.gherkin.utils.RecordMetadata;
import io.cucumber.datatable.DataTable;
import io.cucumber.datatable.DataTable.TableConverter;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;
import org.apache.commons.lang3.StringUtils;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import java.util.*;

/**
 * Utility class for working with Cucumber DataTable objects.
 */
public class TableUtils {

    private TableUtils() {
        /**
         * utility class
         */
    }

    /**
     * Calculates the maximum length of each column in a DataTable.
     *
     * @param dataTableMsg the DataTable object to analyze
     * @return a list of integers representing the maximum length of each column
     */
    public static List<Integer> workOutMaxColumnLength(io.cucumber.messages.types.DataTable dataTableMsg) {

        List<TableRow> rows = dataTableMsg.getRows();
        List<Integer> maxColumnLength = new ArrayList<>();

        for (TableRow row : rows) {
            List<TableCell> cells = row.getCells();
            for (int i = 0; i < cells.size(); i++) {

                TableCell cellValue = cells.get(i);
                String cellText = cellValue.getValue();

                if (maxColumnLength.size() <= i) {
                    maxColumnLength.add(cellText.length());
                } else {
                    int currentMaxLength = maxColumnLength.get(i);
                    if (cellText.length() > currentMaxLength) {
                        maxColumnLength.set(i, cellText.length());
                    }
                }
            }
        }

        return maxColumnLength;
    }

    /**
     * Converts a DataTable object to a string representation, with each column padded to the maximum length.
     *
     * @param dataTableMsg    the DataTable object to convert
     * @param maxColumnLength a list of integers representing the maximum length of each column
     * @return a string representation of the DataTable, with columns padded
     */
    public static String convertDataTableToString(io.cucumber.messages.types.DataTable dataTableMsg, List<Integer> maxColumnLength) {

        StringBuilder sb = new StringBuilder();

        List<TableRow> rows = dataTableMsg.getRows();

        for (int i = 0; i < rows.size(); i++) {

            TableRow row = rows.get(i);
            List<TableCell> cells = row.getCells();

            sb.append("|");

            for (int columnIndex = 0; columnIndex < cells.size(); columnIndex++) {

                TableCell cellValue = cells.get(columnIndex);
                String value = cellValue.getValue();
                sb.append(" "); // Space after opening pipe
                sb.append(value);
                boolean needToPad = columnIndex < maxColumnLength.size()
                        && maxColumnLength.get(columnIndex) > value.length();
                if (needToPad) {
                    int paddingLength = maxColumnLength.get(columnIndex) - value.length();
                    String padding = StringUtils.repeat(" ", paddingLength);
                    sb.append(padding);
                }
                sb.append(" "); // Space before closing pipe
                sb.append("|");
            }

            if (i < rows.size() - 1) {
                sb.append("\n");
            }
        }

        return sb.toString();
    }

    /**
     * Creates an abstract method specification for getting a {@link TableConverter}.
     *
     * @param processingEnv the processing environment
     * @return a {@link MethodSpec} for the getTableConverter method
     */
    public static MethodSpec createGetTableConverterMethod(ProcessingEnvironment processingEnv) {

        MethodSpec methodSpec = MethodSpec.methodBuilder("getTableConverter")
                .addModifiers(
                        Modifier.PROTECTED,
                        Modifier.ABSTRACT
                )
                .returns(TableConverter.class)
                .build();

        return methodSpec;
    }

    /**
     * Creates a method specification for creating a {@link DataTable} from a string representation of table lines.
     *
     * @param processingEnv the processing environment
     * @return a {@link MethodSpec} for the createDataTable method
     */
    public static MethodSpec createDataTableMethod(ProcessingEnvironment processingEnv) {

        MethodSpec.Builder methodSpecBuilder = MethodSpec.methodBuilder("createDataTable")
                //                .addModifiers(Modifier.PROTECTED, Modifier.ABSTRACT)
                .addModifiers(Modifier.PROTECTED)
                .addParameter(String.class, "tableLines")
                .returns(DataTable.class);

        /**
         * Target method body:
         *
         * String[] tableRows = table.split("\n");
         * List<List<String>> rawDataTable = new ArrayList<>(tableRows.length);
         *
         * for (String tableRow : tableRows) {
         *     String trimmedLine = tableRow.trim();
         *     if (!trimmedLine.isEmpty()) {
         *         String[] columns = trimmedLine.split("\\|");
         *         List<String> rowColumns = new ArrayList<>(columns.length);
         *         for (int i = 1; i < columns.length; i++) {
         *             String column = columns[i].trim();
         *             rowColumns.add(column);
         *         }
         *         rawDataTable.add(rowColumns);
         *     }
         * }
         *
         * DataTable dataTable = DataTable.create(rawDataTable, getTableConverter());
         * return dataTable;
         */
        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.addStatement("String[] tableRows = tableLines.split(\"\\\\n\")")
                .addStatement("$T<$T<String>> rawDataTable = new $T<>(tableRows.length)",
                        List.class, List.class, ArrayList.class
                );

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.beginControlFlow("for (String tableRow : tableRows)");
        methodSpecBuilder.addStatement("String trimmedLine = tableRow.trim()");

        methodSpecBuilder.beginControlFlow("if (!trimmedLine.isEmpty())");
        methodSpecBuilder.addStatement("String[] columns = trimmedLine.split(\"\\\\|\")")
                .addStatement("List<String> rowColumns = new ArrayList<>(columns.length)");

        methodSpecBuilder.beginControlFlow("for (int i = 1; i < columns.length; i++)");
        methodSpecBuilder.addStatement("String column = columns[i].trim()")
                .addStatement("rowColumns.add(column)");
        methodSpecBuilder.endControlFlow(); // end for loop over columns

        methodSpecBuilder.addStatement("rawDataTable.add(rowColumns)");
        methodSpecBuilder.endControlFlow(); // end if trimmedLine is not empty

        methodSpecBuilder.endControlFlow(); // end for loop over tableLines

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.addStatement("DataTable dataTable = DataTable.create(rawDataTable, getTableConverter())")
                .addStatement("return dataTable");

        MethodSpec methodSpec = methodSpecBuilder.build();
        return methodSpec;
    }

    /**
     * Creates a method specification for creating a List&lt;Map&lt;String, String&gt;&gt; from a string representation of table lines.
     *
     * The generated method:
     * - Parses table lines split by newlines
     * - First row is treated as headers
     * - Subsequent rows are converted to maps with header keys
     * - Returns empty list if table has less than 2 rows (header only or empty)
     *
     * @param processingEnv the processing environment
     * @return a {@link MethodSpec} for the createListOfMaps method
     */
    public static MethodSpec createListOfMapsMethod(ProcessingEnvironment processingEnv) {

        // Build return type: List<Map<String, String>>
        ParameterizedTypeName mapType = ParameterizedTypeName.get(
                ClassName.get(Map.class),
                ClassName.get(String.class),
                ClassName.get(String.class)
        );
        ParameterizedTypeName returnType = ParameterizedTypeName.get(
                ClassName.get(List.class),
                mapType
        );

        MethodSpec.Builder methodSpecBuilder = MethodSpec.methodBuilder("createListOfMaps")
                .addModifiers(Modifier.PROTECTED)
                .addParameter(String.class, "tableLines")
                .returns(returnType);

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.addStatement("String[] tableRows = tableLines.split(\"\\\\n\")")
                .addStatement("$T<$T<String, String>> listOfMaps = new $T<>()",
                        List.class, Map.class, ArrayList.class
                );

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.beginControlFlow("if (tableRows.length < 2)")
                .addStatement("return listOfMaps")
                .endControlFlow();

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.addStatement("String[] headers = null");
        methodSpecBuilder.beginControlFlow("for (int i = 0; i < tableRows.length; i++)");
        methodSpecBuilder.addStatement("String trimmedLine = tableRows[i].trim()");

        methodSpecBuilder.beginControlFlow("if (!trimmedLine.isEmpty())");
        methodSpecBuilder.addStatement("String[] columns = trimmedLine.split(\"\\\\|\")")
                .addStatement("$T<String> rowColumns = new $T<>(columns.length)",
                        List.class, ArrayList.class);

        methodSpecBuilder.beginControlFlow("for (int j = 1; j < columns.length; j++)");
        methodSpecBuilder.addStatement("String column = columns[j].trim()")
                .addStatement("rowColumns.add(column)");
        methodSpecBuilder.endControlFlow(); // end for loop over columns

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.beginControlFlow("if (headers == null)")
                .addStatement("headers = rowColumns.toArray(new String[0])")
                .nextControlFlow("else");

        methodSpecBuilder.addStatement("$T<String, String> rowMap = new $T<>()",
                        Map.class, HashMap.class);
        methodSpecBuilder.beginControlFlow("for (int j = 0; j < $T.min(headers.length, rowColumns.size()); j++)",
                        Math.class);
        methodSpecBuilder.addStatement("rowMap.put(headers[j], rowColumns.get(j))");
        methodSpecBuilder.endControlFlow(); // end for loop creating map
        methodSpecBuilder.addStatement("listOfMaps.add(rowMap)");

        methodSpecBuilder.endControlFlow(); // end if/else headers
        methodSpecBuilder.endControlFlow(); // end if trimmedLine is not empty
        methodSpecBuilder.endControlFlow(); // end for loop over tableRows

        methodSpecBuilder.addCode("\n");
        methodSpecBuilder.addStatement("return listOfMaps");

        MethodSpec methodSpec = methodSpecBuilder.build();
        return methodSpec;
    }

    /**
     * Creates the base helper method that parses pipe-delimited tables into List&lt;List&lt;String&gt;&gt;.
     * This is the foundation method used by createListOf&lt;RecordName&gt;() methods.
     *
     * @param processingEnv the processing environment
     * @return MethodSpec for createListOfRows(String tableLines)
     */
    public static MethodSpec createListOfRowsMethod(ProcessingEnvironment processingEnv) {
        ParameterizedTypeName listOfListsType = ParameterizedTypeName.get(
                ClassName.get(List.class),
                ParameterizedTypeName.get(ClassName.get(List.class), ClassName.get(String.class))
        );

        MethodSpec.Builder methodBuilder = MethodSpec.methodBuilder("createListOfRows")
                .addModifiers(Modifier.PROTECTED)
                .addParameter(String.class, "tableLines")
                .returns(listOfListsType);

        methodBuilder.addCode("\n");
        methodBuilder.addStatement("String[] tableRows = tableLines.split(\"\\\\n\")");
        methodBuilder.addCode("\n");

        methodBuilder.beginControlFlow("if (tableRows.length < 2)");
        methodBuilder.addStatement("return $T.emptyList()", Collections.class);
        methodBuilder.endControlFlow();

        methodBuilder.addCode("\n");
        methodBuilder.addStatement("$T<$T<String>> listOfRows = new $T<>()",
                List.class, List.class, ArrayList.class);

        methodBuilder.addCode("\n");
        methodBuilder.beginControlFlow("for (int i = 1; i < tableRows.length; i++)");
        methodBuilder.addStatement("String trimmedLine = tableRows[i].trim()");

        methodBuilder.beginControlFlow("if (!trimmedLine.isEmpty())");
        methodBuilder.addStatement("String[] columns = trimmedLine.split(\"\\\\|\")")
                .addStatement("$T<String> rowColumns = new $T<>(columns.length)",
                        List.class, ArrayList.class);

        methodBuilder.beginControlFlow("for (int j = 1; j < columns.length; j++)");
        methodBuilder.addStatement("String column = columns[j].trim()")
                .addStatement("rowColumns.add(column)");
        methodBuilder.endControlFlow();

        methodBuilder.addCode("\n");
        methodBuilder.addStatement("listOfRows.add(rowColumns)");
        methodBuilder.endControlFlow();
        methodBuilder.endControlFlow();

        methodBuilder.addCode("\n");
        methodBuilder.addStatement("return listOfRows");

        return methodBuilder.build();
    }

    /**
     * Creates a helper method that converts pipe-delimited tables to List&lt;RecordType&gt;.
     *
     * @param processingEnv the processing environment
     * @param recordMetadata metadata about the record to generate mapper for
     * @return MethodSpec for createListOf&lt;RecordName&gt;(String tableLines) method
     */
    public static MethodSpec createListOfRecordMethod(
            ProcessingEnvironment processingEnv,
            RecordMetadata recordMetadata
    ) {
        String recordName = recordMetadata.getRecordName();
        String methodName = "createListOf" + recordName;

        // Return type: List<RecordType>
        ClassName recordType = ClassName.get("", recordName);
        ParameterizedTypeName returnType = ParameterizedTypeName.get(
                ClassName.get(List.class),
                recordType
        );

        MethodSpec.Builder methodBuilder = MethodSpec.methodBuilder(methodName)
                .addModifiers(Modifier.PROTECTED)
                .addParameter(String.class, "tableLines")
                .returns(returnType);

        methodBuilder.addCode("\n");

        // Build lambda: row -> new RecordName(row.get("columnName1"), row.get("columnName2"), ...)
        List<String> columnNames = recordMetadata.getColumnNames();
        StringBuilder lambdaBuilder = new StringBuilder();
        lambdaBuilder.append("row -> new ").append(recordName).append("(");

        for (int i = 0; i < columnNames.size(); i++) {
            if (i > 0) lambdaBuilder.append(", ");
            lambdaBuilder.append("row.get(\"").append(columnNames.get(i)).append("\")");
        }
        lambdaBuilder.append(")");

        // Build the complete return statement as a single code block to avoid premature semicolons
        methodBuilder.addStatement("return createListOfMaps(tableLines).stream()\n" +
                "        .map(" + lambdaBuilder + ")\n" +
                "        .toList()");

        return methodBuilder.build();
    }

}
