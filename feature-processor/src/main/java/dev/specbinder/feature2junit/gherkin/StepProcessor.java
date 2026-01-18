package dev.specbinder.feature2junit.gherkin;

import com.squareup.javapoet.*;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import dev.specbinder.feature2junit.support.LoggingSupport;
import dev.specbinder.feature2junit.support.OptionsSupport;
import dev.specbinder.feature2junit.exception.ProcessingException;
import dev.specbinder.feature2junit.gherkin.utils.DataTableCollector;
import dev.specbinder.feature2junit.gherkin.utils.EnumImportCollector;
import dev.specbinder.feature2junit.gherkin.utils.RecordMetadata;
import dev.specbinder.feature2junit.utils.ConstructorMappingUtils;
import dev.specbinder.feature2junit.utils.ElementMethodUtils;
import dev.specbinder.feature2junit.utils.InnerTypeUtils;
import dev.specbinder.feature2junit.utils.MethodNamingUtils;
import dev.specbinder.feature2junit.utils.ParameterConversionUtils;
import dev.specbinder.feature2junit.utils.ParameterNamingUtils;
import dev.specbinder.feature2junit.utils.TableUtils;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.cucumber.messages.types.DocString;
import io.cucumber.messages.types.Location;
import io.cucumber.messages.types.Step;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.Assertions;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeMirror;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

class StepProcessor implements LoggingSupport, OptionsSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;
    private final TypeElement baseType;
    private final Map<String, List<ElementMethodUtils.MethodSignature>> baseClassMethodSignatures;

    private static final Pattern parameterPattern = Pattern.compile("(?<parameter>(\")(?<parameterValue>[^\"]+?)(\"))");

    public StepProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options,
                         DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector,
                         TypeElement baseType) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;
        this.baseType = baseType;
        this.baseClassMethodSignatures = baseType != null
                ? ElementMethodUtils.getAllInheritedMethodSignatures(processingEnv, baseType)
                : Map.of();
    }

    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    public GeneratorOptions getOptions() {
        return options;
    }

    private record MethodSignatureAttributes(
            String stepPattern,
            String methodName,
            List<String> parameterValues
    ) {

    }

    MethodSpec processStep(
            Step step, MethodSpec.Builder scenarioMethodBuilder,
            List<MethodSpec> scenarioStepsMethodSpecs) {

        return processStep(step, scenarioMethodBuilder, scenarioStepsMethodSpecs, null, null);
    }

    public MethodSpec processStep(
            Step step,
            MethodSpec.Builder scenarioMethodBuilder,
            List<MethodSpec> scenarioStepsMethodSpecs,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames
    ) {

        long stepLine = step.getLocation().getLine();

        /**
         * use only the first line of the step text for creating a method name
         */
        String stepText = step.getKeyword() + " " + step.getText();
        String[] lines = stepText.trim().split("\\n");
        String stepFirstLine = lines[0].trim();

        /**
         * create a potential new method to add to the test class
         * it won't be actually added if a method with exactly the same signature already exists
         */
        MethodSignatureAttributes stepMethodSignatureAttributes = extractMethodSignature(
                stepFirstLine, scenarioParameterNames, scenarioStepsMethodSpecs, stepLine
        );
        String stepMethodName = stepMethodSignatureAttributes.methodName;
        MethodSpec.Builder stepMethodBuilder = MethodSpec
                .methodBuilder(stepMethodName)
                .addModifiers(Modifier.PUBLIC);

        if (options.isShouldBeAbstract()) {
            stepMethodBuilder.addModifiers(Modifier.ABSTRACT);
        } else {
            stepMethodBuilder.addStatement("$T.fail(\"Step is not yet implemented\")", Assertions.class);
        }

        if (options.isAddCucumberStepAnnotations()) {
            AnnotationSpec annotationSpec = buildGWTAnnotation(scenarioStepsMethodSpecs,
                    step.getKeyword().trim(), stepMethodName,
                    stepLine, stepMethodSignatureAttributes
            );
            stepMethodBuilder.addAnnotation(annotationSpec);
        }

        /**
         * construct our method parameter
         */
        List<String> parameterValues = stepMethodSignatureAttributes.parameterValues;
        for (int j = 0; j < parameterValues.size(); j++) {
            String parameterName = "p" + (j + 1);
            ParameterSpec parameterSpec = ParameterSpec
                    .builder(String.class, parameterName)
                    .build();
            stepMethodBuilder.addParameter(parameterSpec);
        }
        /**
         * check if step has a data table
         */
        if (step.getDataTable().isPresent()) {

            ParameterSpec dataTableParameterSpec;
            String dataTableType = options.getDataTableParameterType();

            if (LIST_OF_MAPS.name().equals(dataTableType)) {
                // Generate List<Map<String, String>> data parameter
                ParameterizedTypeName mapType = ParameterizedTypeName.get(
                        ClassName.get(Map.class),
                        ClassName.get(String.class),
                        ClassName.get(String.class)
                );
                ParameterizedTypeName listOfMapsType = ParameterizedTypeName.get(
                        ClassName.get(List.class),
                        mapType
                );
                dataTableParameterSpec = ParameterSpec
                        .builder(listOfMapsType, "data")
                        .build();
            } else if ("LIST_OF_OBJECT_PARAMS".equals(dataTableType)) {
                // Generate List<RecordType> parameter with name derived from step text
                String recordName = dataTableCollector.deriveRecordNameFromStepText(stepText);
                String parameterName = dataTableCollector.deriveParameterNameFromStepText(stepText);

                ClassName recordType = ClassName.get("", recordName);
                ParameterizedTypeName listOfRecordsType = ParameterizedTypeName.get(
                        ClassName.get(List.class),
                        recordType
                );
                dataTableParameterSpec = ParameterSpec
                        .builder(listOfRecordsType, parameterName)
                        .build();
            } else {
                // Default: use Cucumber DataTable
                dataTableParameterSpec = ParameterSpec
                        .builder(DataTable.class, "dataTable")
                        .build();
            }

            stepMethodBuilder.addParameter(dataTableParameterSpec);
        }
        /**
         * check if step has doc string
         */
        else if (step.getDocString().isPresent()) {
            ParameterSpec docStringSpec = ParameterSpec
                    .builder(String.class, "docString")
                    .build();
            stepMethodBuilder.addParameter(docStringSpec);
        }

        // add a call to the step method in the scenario method (skip if null - for composite sub-steps)
        if (scenarioMethodBuilder != null) {
            addACallToTheStepMethod(scenarioMethodBuilder,
                    stepMethodName,
                    parameterValues,
                    step,
                    scenarioParameterNames,
                    testMethodParameterNames);
        }

        MethodSpec stepMethodSpec = stepMethodBuilder.build();
        return stepMethodSpec;
    }

    /**
     * Checks if a base class has a compatible method for the given step.
     * A method is compatible if it has the same name and all parameter values can be converted to the method's parameter types.
     *
     * @param step                     the Gherkin step
     * @param scenarioParameterNames   scenario parameter names (for Scenario Outlines)
     * @param scenarioStepsMethodSpecs previously processed steps (needed for resolving And/But keywords)
     * @return true if a compatible base method exists, false otherwise
     */
    public boolean hasCompatibleBaseMethod(Step step, List<String> scenarioParameterNames, List<MethodSpec> scenarioStepsMethodSpecs) {
        String stepText = step.getKeyword() + " " + step.getText();
        String[] lines = stepText.trim().split("\\n");
        String stepFirstLine = lines[0].trim();

        List<String> parameterValues = new ArrayList<>();
        String stepPattern = processWithParameterPattern(stepFirstLine, parameterPattern, parameterValues);

        if (scenarioParameterNames != null && !scenarioParameterNames.isEmpty()) {
            String paramsPatternPart = StringUtils.join(scenarioParameterNames, "|");
            Pattern scenarioParametersPattern = Pattern.compile(
                    "(?<parameter>(?<parameterValue>(<)(" + paramsPatternPart + ")(>)))"
            );
            stepPattern = processWithParameterPattern(stepPattern, scenarioParametersPattern, parameterValues);
        }

        String stepMethodName = MethodNamingUtils.getStepMethodName(stepPattern, scenarioStepsMethodSpecs, step.getLocation().getLine());

        // Determine if step has a DataTable or DocString parameter
        boolean hasDataTableOrDocString = step.getDataTable().isPresent() || step.getDocString().isPresent();

        return findMatchingBaseMethod(stepMethodName, parameterValues, hasDataTableOrDocString) != null;
    }

    /**
     * Finds a matching base class method signature for the given method name and parameter count.
     * Returns the first matching signature where all parameters can be converted.
     *
     * @param stepMethodName  the step method name
     * @param parameterValues the parameter values from the step
     * @return the matching method signature, or null if no match found
     */
    private ElementMethodUtils.MethodSignature findMatchingBaseMethod(
            String stepMethodName, List<String> parameterValues) {
        return findMatchingBaseMethod(stepMethodName, parameterValues, false);
    }

    /**
     * Finds a matching base class method signature for the given method name and parameter count.
     * Returns the first matching signature where all parameters can be converted.
     *
     * @param stepMethodName          the step method name
     * @param parameterValues         the parameter values from the step text (quoted strings and scenario parameters)
     * @param hasDataTableOrDocString true if the step has a DataTable or DocString parameter
     * @return the matching method signature, or null if no match found
     */
    private ElementMethodUtils.MethodSignature findMatchingBaseMethod(
            String stepMethodName, List<String> parameterValues, boolean hasDataTableOrDocString) {

        if (baseClassMethodSignatures == null || !baseClassMethodSignatures.containsKey(stepMethodName)) {
            return null;
        }

        // Expected parameter count: text parameters + 1 if there's a DataTable/DocString
        int expectedParamCount = parameterValues.size() + (hasDataTableOrDocString ? 1 : 0);

        List<ElementMethodUtils.MethodSignature> signatures = baseClassMethodSignatures.get(stepMethodName);
        for (ElementMethodUtils.MethodSignature signature : signatures) {
            // Check if parameter count matches (including DataTable or DocString parameters)
            if (signature.getParameterCount() != expectedParamCount) {
                continue;
            }

            // Check if all text parameters can be converted
            boolean allMatch = true;
            for (int i = 0; i < parameterValues.size(); i++) {
                String paramValue = parameterValues.get(i);
                TypeMirror paramType = signature.getParameterType(i);

                if (!ParameterConversionUtils.canConvert(paramValue, paramType)) {
                    allMatch = false;
                    break;
                }
            }

            if (allMatch) {
                return signature;
            }
        }

        return null;
    }

    private void addACallToTheStepMethod(
            MethodSpec.Builder scenarioMethodBuilder,
            String stepMethodName,
            List<String> parameterValues, Step step,
            List<String> scenarioParameterNames, List<String> testMethodParameterNames
    ) {

        /**
         * add block comment for the step as it appears in the feature file
         */
        String stepFirstLine = step.getKeyword() + step.getText();
        //        scenarioMethodBuilder.addCode("/*\n * $L\n */\n", stepFirstLine);
        scenarioMethodBuilder.addCode("/*");
        scenarioMethodBuilder.addCode("\n * $L", stepFirstLine);
        if (options.isAddSourceLineBeforeStepCalls()) {
            Location stepLocation = step.getLocation();
            scenarioMethodBuilder.addCode("\n * (source line - $L", stepLocation.getLine() + ")");
        }
        // Include DataTable in the comment for LIST_OF_OBJECT_PARAMS mode
        if (step.getDataTable().isPresent() && "LIST_OF_OBJECT_PARAMS".equals(options.getDataTableParameterType())) {
            io.cucumber.messages.types.DataTable dataTableMsg = step.getDataTable().get();
            List<Integer> maxColumnLength = TableUtils.workOutMaxColumnLength(dataTableMsg);
            String dataTableAsString = TableUtils.convertDataTableToString(dataTableMsg, maxColumnLength);
            String[] tableLines = dataTableAsString.split("\n");
            for (String tableLine : tableLines) {
                scenarioMethodBuilder.addCode("\n *   $L", tableLine);
            }
        }
        scenarioMethodBuilder.addCode("\n */\n");

        /**
         * replace all occurrences of '$' with a '$L' placeholders and replace back with '$'
         */
        StringBuilder methodNameWithPlaceholdersSB = new StringBuilder();
        int searchingFrom = 0;
        int totalDollarSigns = 0;
        int indexOfDollarSign = stepMethodName.indexOf('$', searchingFrom);
        while (indexOfDollarSign > -1) {

            String beforeDollarSign = stepMethodName.substring(searchingFrom, indexOfDollarSign);
            methodNameWithPlaceholdersSB.append(beforeDollarSign);

            methodNameWithPlaceholdersSB.append("$L"); // placeholder for parameter
            totalDollarSigns++;

            searchingFrom = indexOfDollarSign + 1;
            indexOfDollarSign = stepMethodName.indexOf('$', searchingFrom);
        }
        if (searchingFrom < stepMethodName.length()) {
            String afterDollarSign = stepMethodName.substring(searchingFrom);
            methodNameWithPlaceholdersSB.append(afterDollarSign);
        }
        String methodNameWithPlaceholders = methodNameWithPlaceholdersSB.toString();
        // Track format arguments - will include dollar signs and potentially List.class for $T placeholder
        List<Object> formatArgsList = new ArrayList<>();
        for (int i = 0; i < totalDollarSigns; i++) {
            formatArgsList.add("$");
        }

        /**
         * construct parameter values
         */
        // Check if there's a matching base class method with specific parameter types
        ElementMethodUtils.MethodSignature matchingBaseMethod = findMatchingBaseMethod(stepMethodName, parameterValues);

        StringBuilder parameterValuesSB = new StringBuilder();
        for (int j = 0; j < parameterValues.size(); j++) {
            if (j > 0) {
                parameterValuesSB.append(", ");
            }
            String parameterValue = parameterValues.get(j);
            /**
             * in case of scenario with Examples section we check if parameter value is actually a reference
             * to a scenario parameter - if so, we replace it with the reference to the Scenario's test method parameter
             */
            String scenarioParameter = getScenarioParameter(parameterValue, scenarioParameterNames, testMethodParameterNames);
            if (scenarioParameter != null) {
                /**
                 * no quote marks in this case as we are passing a reference to a Scenario test method parameter
                 */
                parameterValuesSB.append(scenarioParameter);
            } else if (matchingBaseMethod != null) {
                /**
                 * Base class has a method with compatible parameter types
                 * Convert the string value to the appropriate type literal
                 */
                TypeMirror targetType = matchingBaseMethod.getParameterType(j);
                String literal = ParameterConversionUtils.toLiteral(parameterValue, targetType);
                parameterValuesSB.append(literal);

                // Register enum constants for static import
                if (enumImportCollector != null && ParameterConversionUtils.isEnumType(targetType)) {
                    String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(targetType);
                    enumImportCollector.registerEnumConstant(enumQualifiedName, parameterValue);
                }
            } else {
                /**
                 * No matching base method, use quoted string
                 */
                parameterValuesSB.append("\"");
                parameterValuesSB.append(parameterValue);
                parameterValuesSB.append("\"");
            }
        }

        if (step.getDataTable().isPresent()) {

            io.cucumber.messages.types.DataTable dataTableMsg = step.getDataTable().get();
            List<Integer> maxColumnLength = TableUtils.workOutMaxColumnLength(dataTableMsg);
            String dataTableAsString = TableUtils.convertDataTableToString(dataTableMsg, maxColumnLength);

            // Choose method name based on data table parameter type
            String helperMethodName;
            String dataTableType = options.getDataTableParameterType();

            if (!parameterValues.isEmpty()) {
                // For LIST_OF_OBJECT_PARAMS, List.of( starts on new line, so no trailing space needed
                if ("LIST_OF_OBJECT_PARAMS".equals(dataTableType)) {
                    parameterValuesSB.append(",");
                } else {
                    parameterValuesSB.append(", ");
                }
            }
            String recordName = null;

            if ("LIST_OF_MAPS".equals(dataTableType)) {
                helperMethodName = "createListOfMaps";
            } else if ("LIST_OF_OBJECT_PARAMS".equals(dataTableType)) {
                String stepTextForRecord = step.getKeyword() + step.getText();
                recordName = dataTableCollector.deriveRecordNameFromStepText(stepTextForRecord);
                helperMethodName = null; // Not used for LIST_OF_OBJECT_PARAMS
            } else {
                helperMethodName = "createDataTable";
            }

            // For LIST_OF_OBJECT_PARAMS, generate List.of() with inline constructor calls
            if ("LIST_OF_OBJECT_PARAMS".equals(dataTableType) && recordName != null) {
                RecordMetadata recordMetadata = dataTableCollector.getRecordMetadataMap().get(recordName);
                if (recordMetadata != null) {
                    List<TableRow> rows = dataTableMsg.getRows();

                    // First row is headers, remaining rows are data
                    if (rows.size() > 1) {
                        // Get column names from header row
                        List<String> columnNames = new ArrayList<>();
                        TableRow headerRow = rows.get(0);
                        for (TableCell cell : headerRow.getCells()) {
                            columnNames.add(cell.getValue().trim());
                        }

                        // Check for inherited List<T> parameter type from base class method
                        InheritedListTypeInfo inheritedTypeInfo =
                                findInheritedListParameterType(stepMethodName, parameterValues, columnNames);

                        // Determine the type name and constructor mapping to use
                        String typeNameToUse;
                        ConstructorMappingUtils.MappingResult mappingToUse = null;
                        boolean useExistingTypeOrder = false;

                        if (inheritedTypeInfo != null && inheritedTypeInfo.isCompatible()) {
                            // Use the inherited type from the base method's List parameter
                            typeNameToUse = inheritedTypeInfo.typeElement().getSimpleName().toString();
                            mappingToUse = inheritedTypeInfo.constructorMapping();
                            useExistingTypeOrder = true;
                            // Mark the metadata so we don't generate a new inner class
                            if (!recordMetadata.hasExistingType()) {
                                recordMetadata.setExistingType(inheritedTypeInfo.typeElement(), mappingToUse);
                            }
                        } else if (recordMetadata.hasExistingType()) {
                            // Use existing type from hierarchy (name-based lookup)
                            typeNameToUse = recordMetadata.getExistingType().getSimpleName().toString();
                            mappingToUse = recordMetadata.getConstructorMapping();
                            useExistingTypeOrder = true;
                        } else {
                            // Use derived record name (will generate new inner class)
                            typeNameToUse = recordName;
                            useExistingTypeOrder = false;
                            // If inherited type exists but is not compatible, we need an overloaded method
                            // Note: This generates code that won't compile due to Java type erasure,
                            // but documents the expected behavior for this edge case
                            if (inheritedTypeInfo != null && !inheritedTypeInfo.isCompatible()) {
                                recordMetadata.setNeedsOverloadedMethod(true);
                            }
                        }

                        // Use $T placeholder for List to ensure import is added
                        parameterValuesSB.append("\n$T.of(");
                        formatArgsList.add(List.class);

                        // Process each data row (skip header at index 0)
                        for (int rowIndex = 1; rowIndex < rows.size(); rowIndex++) {
                            TableRow dataRow = rows.get(rowIndex);
                            List<TableCell> cells = dataRow.getCells();

                            if (rowIndex > 1) {
                                parameterValuesSB.append(",");
                            }
                            parameterValuesSB.append("\n        new ");
                            parameterValuesSB.append(typeNameToUse);
                            parameterValuesSB.append("(");

                            // Generate constructor arguments based on record metadata
                            if (useExistingTypeOrder && mappingToUse != null) {
                                // Use existing type: args in constructor parameter order
                                Map<Integer, String> paramIndexToColumnName = mappingToUse.getParamIndexToColumnName();
                                List<String> constructorParams = mappingToUse.getConstructorParamNames();

                                for (int i = 0; i < constructorParams.size(); i++) {
                                    if (i > 0) {
                                        parameterValuesSB.append(", ");
                                    }

                                    String mappedColumnName = paramIndexToColumnName.get(i);
                                    if (mappedColumnName != null) {
                                        // Find the column index for this column name
                                        int columnIndex = columnNames.indexOf(mappedColumnName);
                                        if (columnIndex >= 0 && columnIndex < cells.size()) {
                                            String cellValue = cells.get(columnIndex).getValue().trim();
                                            String transformedValue = transformCellValueWithPlaceholders(
                                                    cellValue, scenarioParameterNames, testMethodParameterNames);
                                            parameterValuesSB.append(transformedValue);
                                        } else {
                                            parameterValuesSB.append("null");
                                        }
                                    } else {
                                        parameterValuesSB.append("null");
                                    }
                                }
                            } else {
                                // Generate new type: use data table column order
                                List<String> recordColumnNames = recordMetadata.getColumnNames();
                                for (int i = 0; i < recordColumnNames.size(); i++) {
                                    if (i > 0) {
                                        parameterValuesSB.append(", ");
                                    }

                                    // Find column index in the current data table
                                    int columnIndex = columnNames.indexOf(recordColumnNames.get(i));
                                    if (columnIndex >= 0 && columnIndex < cells.size()) {
                                        String cellValue = cells.get(columnIndex).getValue().trim();
                                        String transformedValue = transformCellValueWithPlaceholders(
                                                cellValue, scenarioParameterNames, testMethodParameterNames);
                                        parameterValuesSB.append(transformedValue);
                                    } else {
                                        // Column not present in this data table, use empty string
                                        parameterValuesSB.append("\"\"");
                                    }
                                }
                            }

                            parameterValuesSB.append(")");
                        }

                        parameterValuesSB.append("\n)");
                    }
                }
            } else {
                // For other data table types, use helper methods
                parameterValuesSB.append(helperMethodName);
                parameterValuesSB.append("(");
                parameterValuesSB.append("\"\"\"\n");
                parameterValuesSB.append(dataTableAsString);
                parameterValuesSB.append("\n\"\"\"");

                /**
                 * in case we are processing a scenario with examples table i.e. Scenario Template type
                 * then we need to replace any references to scenario parameters with reference value from the examples table
                 */
                if (scenarioParameterNames != null && !scenarioParameterNames.isEmpty()) {
                    // Only add replaceAll calls for parameters that are actually present in the DataTable
                    for (int i = 0; i < scenarioParameterNames.size(); i++) {
                        String scenarioParameterName = scenarioParameterNames.get(i);
                        // Check if this specific parameter appears in the DataTable
                        if (dataTableAsString.contains("<" + scenarioParameterName + ">")) {
                            String testMethodParameterName = testMethodParameterNames.get(i);
                            parameterValuesSB.append("\n.replaceAll(");
                            parameterValuesSB.append("\"<" + scenarioParameterName + ">\"");
                            parameterValuesSB.append(", ");
                            parameterValuesSB.append(testMethodParameterName);
                            parameterValuesSB.append(")");
                        }
                    }
                }

                parameterValuesSB.append(")");
            }

        } else if (step.getDocString().isPresent()) {

            if (!parameterValues.isEmpty()) {
                parameterValuesSB.append(", ");
            }

            DocString docString1 = step.getDocString().get();
            String docString = docString1.getContent();

            // need to escape any occurrences of triple quotes in the doc string content
            docString = docString.replaceAll("\"\"\"", "\\\\\"\"\"");

            // Escape $ for JavaPoet ($ is a special character in JavaPoet's format strings)
            // Must be done AFTER triple quote escaping to avoid double-escaping
            docString = docString.replace("$", "$$");

            /**
             * in case we are processing a scenario with examples table i.e. Scenario Template type
             * then we need to replace any references to scenario parameters with reference value from the examples table
             * BUT only add replaceAll for parameters that are actually present in the DocString
             */
            if (scenarioParameterNames != null && !scenarioParameterNames.isEmpty()) {

                parameterValuesSB.append("\"\"\"\n");
                parameterValuesSB.append(docString);
                parameterValuesSB.append("\n\"\"\"");

                // Only add replaceAll calls for parameters that are actually present in the DocString
                for (int i = 0; i < scenarioParameterNames.size(); i++) {
                    String scenarioParameterName = scenarioParameterNames.get(i);
                    // Check if this specific parameter appears in the DocString
                    if (docString.contains("<" + scenarioParameterName + ">")) {
                        String testMethodParameterName = testMethodParameterNames.get(i);
                        parameterValuesSB.append("\n.replaceAll(");
                        parameterValuesSB.append("\"<" + scenarioParameterName + ">\"");
                        parameterValuesSB.append(", ");
                        parameterValuesSB.append(testMethodParameterName);
                        parameterValuesSB.append(")");
                    }
                }

            } else {
                parameterValuesSB.append("\"\"\"\n");
                parameterValuesSB.append(docString);
                parameterValuesSB.append("\n\"\"\"");
            }
        }

        String parameterValuesPart = parameterValuesSB.toString();
        CodeBlock codeBlock =
                CodeBlock.of(methodNameWithPlaceholders + "(" + parameterValuesPart + ")", formatArgsList.toArray());

        scenarioMethodBuilder.addStatement(codeBlock);
    }

    private String getScenarioParameter(
            String parameterValue, List<String> scenarioParameterNames,
            List<String> testMethodParameterNames
    ) {

        if (scenarioParameterNames == null || scenarioParameterNames.isEmpty()) {
            return null; // no scenario parameters defined
        }

        if (parameterValue.startsWith("<") && parameterValue.endsWith(">") && parameterValue.length() > 2) {

            String valueWithoutBrackets = parameterValue.substring(1, parameterValue.length() - 1);
            int indexOfParameterName = scenarioParameterNames.indexOf(valueWithoutBrackets);
            if (indexOfParameterName > -1) {
                return testMethodParameterNames.get(indexOfParameterName);
            }
        }

        return null; // not a scenario parameter
    }

    /**
     * Transforms a data table cell value by substituting placeholders with parameter references.
     * <p>
     * This method handles three cases:
     * <ul>
     *   <li>Single placeholder only (e.g., {@code <name>}): returns the parameter name directly (e.g., {@code name})</li>
     *   <li>Mixed content (e.g., {@code Hello <name>!}): returns a string concatenation expression
     *       (e.g., {@code "Hello " + name + "!"})</li>
     *   <li>No placeholders (e.g., {@code literal}): returns the quoted string (e.g., {@code "literal"})</li>
     * </ul>
     *
     * @param cellValue              the cell value from the data table
     * @param scenarioParameterNames the list of placeholder names from the Examples table
     * @param testMethodParameterNames the list of corresponding Java parameter names
     * @return the transformed expression suitable for code generation
     */
    private String transformCellValueWithPlaceholders(
            String cellValue,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames
    ) {
        // If no scenario parameters are defined, just quote the value
        if (scenarioParameterNames == null || scenarioParameterNames.isEmpty()) {
            return "\"" + cellValue + "\"";
        }

        // Check if it's a single placeholder only (e.g., "<name>")
        String singlePlaceholderParam = getScenarioParameter(cellValue, scenarioParameterNames, testMethodParameterNames);
        if (singlePlaceholderParam != null) {
            return singlePlaceholderParam;
        }

        // Check if there are any placeholders in the cell value
        boolean hasPlaceholder = false;
        for (String paramName : scenarioParameterNames) {
            if (cellValue.contains("<" + paramName + ">")) {
                hasPlaceholder = true;
                break;
            }
        }

        // If no placeholders, just quote the value
        if (!hasPlaceholder) {
            return "\"" + cellValue + "\"";
        }

        // Mixed content: build a string concatenation expression
        // We need to split the cell value by placeholders and concatenate parts
        StringBuilder result = new StringBuilder();
        String remaining = cellValue;
        boolean firstPart = true;

        while (!remaining.isEmpty()) {
            // Find the next placeholder
            int earliestStart = -1;
            int earliestEnd = -1;
            int earliestParamIndex = -1;

            for (int i = 0; i < scenarioParameterNames.size(); i++) {
                String placeholder = "<" + scenarioParameterNames.get(i) + ">";
                int idx = remaining.indexOf(placeholder);
                if (idx >= 0 && (earliestStart < 0 || idx < earliestStart)) {
                    earliestStart = idx;
                    earliestEnd = idx + placeholder.length();
                    earliestParamIndex = i;
                }
            }

            if (earliestStart < 0) {
                // No more placeholders, add the remaining text
                if (!remaining.isEmpty()) {
                    if (!firstPart) {
                        result.append(" + ");
                    }
                    result.append("\"").append(remaining).append("\"");
                }
                break;
            }

            // Add text before the placeholder
            if (earliestStart > 0) {
                if (!firstPart) {
                    result.append(" + ");
                }
                result.append("\"").append(remaining.substring(0, earliestStart)).append("\"");
                firstPart = false;
            }

            // Add the parameter reference
            if (!firstPart) {
                result.append(" + ");
            }
            result.append(testMethodParameterNames.get(earliestParamIndex));
            firstPart = false;

            // Move past the placeholder
            remaining = remaining.substring(earliestEnd);
        }

        return result.toString();
    }

    private AnnotationSpec buildGWTAnnotation(
            List<MethodSpec> scenarioStepsMethodSpecs,
            String stepKeyword, String stepMethodName,
            long stepLine,
            MethodSignatureAttributes signatureAttributes) {

        List<String> parameterValues = signatureAttributes.parameterValues;

        String keywordLower = stepKeyword.toLowerCase();

        AnnotationSpec.Builder annotationSpecBuilder;
        if (keywordLower.equals("given")) {
            annotationSpecBuilder = AnnotationSpec.builder(Given.class);
        } else if (keywordLower.equals("when")) {
            annotationSpecBuilder = AnnotationSpec.builder(When.class);
        } else if (keywordLower.equals("then")) {
            annotationSpecBuilder = AnnotationSpec.builder(Then.class);
        } else if (
                keywordLower.equals("and") || keywordLower.equals("but")
                        || keywordLower.equals("*")
        ) {
            // 'And' is a special case, which is worked out using previous non And step keyword
            if (scenarioStepsMethodSpecs.isEmpty()) {
                throw new ProcessingException(
                        "Step on line - " + stepLine
                                + " starts with 'And', but there are no previous scenario steps defined");
            }
            MethodSpec lastScenarioMethodSpec = scenarioStepsMethodSpecs.get(scenarioStepsMethodSpecs.size() - 1);

            List<AnnotationSpec> methodAnnotationSpecs = lastScenarioMethodSpec.annotations;
            Class<?> gwtAnnotation = null;
            for (AnnotationSpec methodAnnotationSpec : methodAnnotationSpecs) {
                String annotationName = methodAnnotationSpec.type.toString();
                if (annotationName.equals(Given.class.getName())) {
                    gwtAnnotation = Given.class;
                    break;
                } else if (annotationName.equals(When.class.getName())) {
                    gwtAnnotation = When.class;
                    break;
                } else if (annotationName.equals(Then.class.getName())) {
                    gwtAnnotation = Then.class;
                    break;
                } else {
                    continue; // skip
                }
            }
            if (gwtAnnotation == null) {
                throw new ProcessingException(
                        "Step on line - " + stepLine
                                + " starts with 'And', but there are no previous scenario steps defined that have a step annotation");
            }

            annotationSpecBuilder = AnnotationSpec.builder(gwtAnnotation);

        } else {
            throw new ProcessingException(
                    "Step method name does not start with a valid keyword (Given, When, Then, And): "
                            + stepMethodName);
        }

        String stepPattern = signatureAttributes.stepPattern;

        String[] args = new String[parameterValues.size() + 1];
        for (int j = 0; j < parameterValues.size(); j++) {
            //            args[j] = "$p" + (j + 1);
            args[j] = "(?<p" + (j + 1) + ">.*)";
        }
        String stepPatternWithMarkers =
                stepPattern.replaceAll("\s\\$p[0-9]{1,2}(\s|$)", " \\$L$1");

        String[] words = stepPatternWithMarkers.split("\\s+");
        String[] stepTitleWords = Arrays.copyOfRange(words, 1, words.length); // trim the keyword
        String stepAnnotationValueTrimmed = StringUtils.join(stepTitleWords, " ");

        // Escape regex special characters in literal text, but preserve $L placeholders
        stepAnnotationValueTrimmed = escapeRegexSpecialCharacters(stepAnnotationValueTrimmed);

        // Escape literal dollar signs that are not part of JavaPoet placeholders ($L)
        // In JavaPoet, $$ represents a literal $
        stepAnnotationValueTrimmed = stepAnnotationValueTrimmed.replaceAll("\\$(?!L)", "\\$\\$");

        // Escape literal double quotes for regex pattern
        stepAnnotationValueTrimmed = stepAnnotationValueTrimmed.replace("\"", "\\\"");

        // prepend '^' and append '$' to the annotation pattern value so that IDE plugins discover this step
        stepAnnotationValueTrimmed = "^" + stepAnnotationValueTrimmed + "$L";
        args[args.length - 1] = "$"; // for the '$' at the end of the pattern

        annotationSpecBuilder.addMember("value", "\"" + stepAnnotationValueTrimmed + "\"", (Object[]) args);
        AnnotationSpec annotationSpec = annotationSpecBuilder.build();

        return annotationSpec;
    }

    /**
     * Escapes special regex characters in the step text while preserving $L placeholders for JavaPoet.
     * Special regex characters that need escaping: . ^ $ * + ? { } [ ] ( ) | \
     *
     * @param text the step text that may contain regex special characters
     * @return the text with regex special characters escaped
     */
    private String escapeRegexSpecialCharacters(String text) {
        // Characters that have special meaning in regex and need to be escaped with backslash
        // Note: We process the string character by character to preserve $L placeholders
        StringBuilder result = new StringBuilder();

        for (int i = 0; i < text.length(); i++) {
            char ch = text.charAt(i);

            // Check if this is a $L placeholder (skip escaping)
            if (ch == '$' && i + 1 < text.length() && text.charAt(i + 1) == 'L') {
                result.append("$L");
                i++; // skip the 'L'
                continue;
            }

            // Escape regex special characters
            // Use double backslash (\\) so that the generated Java source code has proper escaping
            switch (ch) {
                case '.':
                case '^':
                case '$':
                case '*':
                case '+':
                case '?':
                case '{':
                case '}':
                case '[':
                case ']':
                case '(':
                case ')':
                case '|':
                case '\\':
                    result.append("\\\\").append(ch);
                    break;
                default:
                    result.append(ch);
                    break;
            }
        }

        return result.toString();
    }

    private MethodSignatureAttributes extractMethodSignature(
            String stepFirstLine,
            List<String> scenarioParameterNames, List<MethodSpec> scenarioStepsMethodSpecs,
            long stepLine) {

        List<String> parameterValues = new ArrayList<>();

        String stepPattern = processWithParameterPattern(
                stepFirstLine, parameterPattern, parameterValues);

        if (scenarioParameterNames != null && !scenarioParameterNames.isEmpty()) {
            // process scenario parameters
            String paramsPatternPart = StringUtils.join(scenarioParameterNames, "|");
            Pattern scenarioParametersPattern = Pattern.compile(
                    "(?<parameter>(?<parameterValue>(<)(" + paramsPatternPart + ")(>)))"
            );
            stepPattern = processWithParameterPattern(stepPattern,
                    scenarioParametersPattern,
                    parameterValues);
        }

        String stepMethodName = MethodNamingUtils.getStepMethodName(stepPattern, scenarioStepsMethodSpecs, stepLine);

        MethodSignatureAttributes signatureAttributes = new MethodSignatureAttributes(
                stepPattern,
                stepMethodName,
                parameterValues
        );
        return signatureAttributes;
    }

    private record AnnotationPatternAttributes(
            String stepAnnotationPattern,
            String gwtAnnotationValue
    ) {

    }

    private String processWithParameterPattern(
            String stepFirstLine,
            Pattern parameterPattern,
            List<String> parameterValues) {

        int lastParameterEnd = 0;

        StringBuilder stepAnnotationPatternSB = new StringBuilder();

        Matcher matcher = parameterPattern.matcher(stepFirstLine);

        while (matcher.find()) {

            int parameterStart = matcher.start("parameter");
            int parameterEnd = matcher.end("parameter");

            int searchStartPos = lastParameterEnd;
            if (searchStartPos < parameterStart) {
                String before = stepFirstLine.substring(searchStartPos, parameterStart);
                stepAnnotationPatternSB.append(before);
            }

            stepAnnotationPatternSB.append("$p" + (parameterValues.size() + 1));

            String parameterValue = matcher.group("parameterValue");
            parameterValues.add(parameterValue);

            lastParameterEnd = parameterEnd;
        }

        if (lastParameterEnd < stepFirstLine.length()) {
            // There is some text after the last parameter
            String after = stepFirstLine.substring(lastParameterEnd);
            stepAnnotationPatternSB.append(after);
        }

        String stepAnnotationPattern = stepAnnotationPatternSB.toString();
        return stepAnnotationPattern;
    }

    /**
     * Information about an inherited List parameter type from a base class method.
     * Used when reusing an existing type from the base class hierarchy for data table handling.
     *
     * @param typeElement the TypeElement of the list's generic type argument (e.g., BaseUserParam)
     * @param constructorMapping the mapping from data table columns to constructor parameters
     * @param isCompatible true if all data table columns can be mapped to constructor parameters
     */
    record InheritedListTypeInfo(
            TypeElement typeElement,
            ConstructorMappingUtils.MappingResult constructorMapping,
            boolean isCompatible
    ) {
    }

    /**
     * Finds the inherited List parameter type from a matching base class method.
     * <p>
     * This method:
     * 1. Finds a matching base class method by name and parameter count
     * 2. Checks if the last parameter (DataTable position) is List&lt;T&gt;
     * 3. Extracts T and checks if its constructor accepts all data table columns
     *
     * @param stepMethodName the step method name to search for
     * @param parameterValues the parameter values from the step text
     * @param columnNames the data table column names
     * @return InheritedListTypeInfo if a matching method with List&lt;T&gt; parameter was found, null otherwise
     */
    InheritedListTypeInfo findInheritedListParameterType(
            String stepMethodName,
            List<String> parameterValues,
            List<String> columnNames) {

        // Find matching base method with DataTable/DocString parameter
        ElementMethodUtils.MethodSignature matchingMethod =
                findMatchingBaseMethod(stepMethodName, parameterValues, true);

        if (matchingMethod == null) {
            return null;
        }

        // Get the last parameter (DataTable position)
        int lastParamIndex = matchingMethod.getParameterCount() - 1;
        if (lastParamIndex < 0) {
            return null;
        }

        TypeMirror lastParamType = matchingMethod.getParameterType(lastParamIndex);

        // Check if it's List<CustomType>
        if (!ElementMethodUtils.isListOfCustomObjectType(lastParamType, processingEnv)) {
            return null;
        }

        // Extract the type argument
        TypeElement listTypeArg = ElementMethodUtils.extractListTypeArgument(lastParamType);
        if (listTypeArg == null) {
            return null;
        }

        // Find the all-args constructor
        ExecutableElement constructor = InnerTypeUtils.findAllArgsConstructor(listTypeArg);
        if (constructor == null) {
            return new InheritedListTypeInfo(listTypeArg, null, false);
        }

        // Get constructor parameter names
        List<String> constructorParams = InnerTypeUtils.getConstructorParameterNames(constructor, listTypeArg);

        // Try to map data table columns to constructor parameters
        ConstructorMappingUtils.MappingResult mapping =
                ConstructorMappingUtils.tryMapColumnsToConstructor(columnNames, constructorParams);

        return new InheritedListTypeInfo(listTypeArg, mapping, mapping.canMap());
    }

}