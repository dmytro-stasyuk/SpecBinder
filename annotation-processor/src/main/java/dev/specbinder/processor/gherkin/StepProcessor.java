package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.*;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.gherkin.utils.RecordMetadata;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.*;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.cucumber.messages.types.DocString;
import io.cucumber.messages.types.Step;
import io.cucumber.messages.types.TableCell;
import io.cucumber.messages.types.TableRow;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Assumptions;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.*;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeMirror;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

class StepProcessor implements LoggingSupport, OptionsSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;
    private final TypeElement baseType;
    private final Map<String, List<ElementMethodUtils.MethodSignature>> baseClassMethodSignatures;
    private final List<ElementMethodUtils.CucumberAnnotationEntry> cucumberAnnotationEntries;
    private final Map<String, List<Class<?>>> preComputedStepTypes;

    private static final Pattern parameterPattern = Pattern.compile("(?<parameter>(\")(?<parameterValue>([^\"\\\\]|\\\\.)+?)(\"))");

    public StepProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options,
                         DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector,
                         TypeElement baseType) {
        this(processingEnv, options, dataTableCollector, enumImportCollector, baseType, Map.of());
    }

    public StepProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options,
                         DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector,
                         TypeElement baseType, Map<String, List<Class<?>>> preComputedStepTypes) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;
        this.baseType = baseType;
        this.preComputedStepTypes = preComputedStepTypes;
        this.baseClassMethodSignatures = baseType != null
                ? ElementMethodUtils.getAllInheritedMethodSignatures(processingEnv, baseType)
                : Map.of();
        this.cucumberAnnotationEntries = baseType != null && options.isUseCucumberAnnotationsForStepMatching()
                ? ElementMethodUtils.getCucumberAnnotationStepEntries(processingEnv, baseType)
                : List.of();
    }

    /**
     * Result of matching a step text against Cucumber annotation entries.
     *
     * @param methodName the matched method name
     * @param entry the matched annotation entry (contains Cucumber expression info)
     */
    private record AnnotationMatchResult(
            String methodName,
            ElementMethodUtils.CucumberAnnotationEntry entry
    ) {}

    /**
     * Finds a matching annotation entry by matching the step text against compiled patterns
     * from Cucumber annotation values (both regex and Cucumber expressions).
     *
     * @param stepText the step text from the feature file
     * @return the match result if a pattern matches, null otherwise
     */
    private AnnotationMatchResult findAnnotationMatch(String stepText) {
        for (ElementMethodUtils.CucumberAnnotationEntry entry : cucumberAnnotationEntries) {
            if (entry.pattern().matcher(stepText).matches()) {
                return new AnnotationMatchResult(entry.methodName(), entry);
            }
        }
        return null;
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
            List<String> parameterValues,
            List<Class<?>> parameterTypes
    ) {

    }

    MethodSpec processStep(
            Step step, MethodSpec.Builder scenarioMethodBuilder,
            List<MethodSpec> scenarioStepsMethodSpecs,
            List<String> resolvedStepKeywords) {

        return processStep(step, scenarioMethodBuilder, scenarioStepsMethodSpecs, resolvedStepKeywords, null, null, null, null);
    }

    public MethodSpec processStep(
            Step step,
            MethodSpec.Builder scenarioMethodBuilder,
            List<MethodSpec> scenarioStepsMethodSpecs,
            List<String> resolvedStepKeywords,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames,
            List<Class<?>> scenarioParameterTypes,
            Map<Integer, TypeMirror> enumParameterTypes
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
                stepFirstLine, scenarioParameterNames, scenarioParameterTypes, scenarioStepsMethodSpecs, stepLine
        );
        String stepMethodName = stepMethodSignatureAttributes.methodName;

        // Check if a Cucumber annotation pattern matches the step text
        AnnotationMatchResult annotationMatch = findAnnotationMatch(step.getText());
        if (annotationMatch != null) {
            stepMethodName = annotationMatch.methodName();

            // For Cucumber expression matches, override parameter values and types
            if (annotationMatch.entry().isCucumberExpression()) {
                String cucumberExpr = annotationMatch.entry().cucumberExpression();
                List<String> ceValues = CucumberExpressionUtils.extractParameterValues(cucumberExpr, step.getText());
                List<String> ceTypeNames = CucumberExpressionUtils.extractParameterTypeNames(cucumberExpr);
                if (!ceValues.isEmpty()) {
                    stepMethodSignatureAttributes = new MethodSignatureAttributes(
                            stepMethodSignatureAttributes.stepPattern(),
                            stepMethodName,
                            ceValues,
                            ceTypeNames.stream().map(CucumberExpressionUtils::toJavaClass).collect(Collectors.toList())
                    );
                }
            }
        }

        MethodSpec.Builder stepMethodBuilder = MethodSpec
                .methodBuilder(stepMethodName)
                .addModifiers(Modifier.PUBLIC);

        if (options.isShouldBeAbstract()) {
            stepMethodBuilder.addModifiers(Modifier.ABSTRACT);
        } else {
            if ("SKIP".equals(options.getUnimplementedStepBehavior())) {
                stepMethodBuilder.addStatement("$T.assumeTrue(false, \"Step is not yet implemented\")", Assumptions.class);
            } else if ("COMPILATION_ERROR".equals(options.getUnimplementedStepBehavior())) {
                stepMethodBuilder.addCode("Step is not yet implemented\n");
            } else {
                stepMethodBuilder.addStatement("$T.fail(\"Step is not yet implemented\")", Assertions.class);
            }
        }

        String resolvedKeyword = resolveGWTKeyword(step.getKeyword().trim(), resolvedStepKeywords, stepLine);
        resolvedStepKeywords.add(resolvedKeyword);

        if (options.isAddCucumberStepAnnotations() && annotationMatch == null) {
            AnnotationSpec annotationSpec = buildGWTAnnotation(resolvedKeyword,
                    stepMethodName, stepMethodSignatureAttributes
            );
            stepMethodBuilder.addAnnotation(annotationSpec);
        }

        /**
         * construct our method parameter
         */
        List<String> parameterValues = stepMethodSignatureAttributes.parameterValues;
        List<Class<?>> parameterTypes = stepMethodSignatureAttributes.parameterTypes;
        for (int j = 0; j < parameterValues.size(); j++) {
            String parameterName = "p" + (j + 1);
            Class<?> parameterType = parameterTypes.get(j);
            ParameterSpec parameterSpec = ParameterSpec
                    .builder(parameterType, parameterName)
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
                    parameterTypes,
                    step,
                    scenarioParameterNames,
                    testMethodParameterNames,
                    scenarioParameterTypes,
                    enumParameterTypes);
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
        return hasCompatibleBaseMethod(step, scenarioParameterNames, null, scenarioStepsMethodSpecs);
    }

    public boolean hasCompatibleBaseMethod(Step step, List<String> scenarioParameterNames, List<Class<?>> scenarioParameterTypes, List<MethodSpec> scenarioStepsMethodSpecs) {
        return hasCompatibleBaseMethod(step, scenarioParameterNames, scenarioParameterTypes, null, scenarioStepsMethodSpecs);
    }

    public boolean hasCompatibleBaseMethod(Step step, List<String> scenarioParameterNames, List<Class<?>> scenarioParameterTypes,
                                           Map<Integer, TypeMirror> enumTypes, List<MethodSpec> scenarioStepsMethodSpecs) {
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

        String stepMethodName = MethodNamingUtils.getStepMethodName(stepPattern, scenarioStepsMethodSpecs, step.getLocation().getLine(),
                getOptions().isUseStepKeywordInStepMethodName());

        // Check if a Cucumber annotation pattern matches the step text
        AnnotationMatchResult annotationMatch = findAnnotationMatch(step.getText());
        if (annotationMatch != null) {
            stepMethodName = annotationMatch.methodName();

            // For Cucumber expression matches, use extracted parameter values
            if (annotationMatch.entry().isCucumberExpression()) {
                String cucumberExpr = annotationMatch.entry().cucumberExpression();
                List<String> ceValues = CucumberExpressionUtils.extractParameterValues(cucumberExpr, step.getText());
                if (!ceValues.isEmpty()) {
                    parameterValues = ceValues;
                }
            }
        }

        // Determine if step has a DataTable or DocString parameter
        boolean hasDataTableOrDocString = step.getDataTable().isPresent() || step.getDocString().isPresent();

        // Convert placeholder parameter values to actual types using scenarioParameterTypes
        List<String> convertedParameterValues = new ArrayList<>();
        for (String paramValue : parameterValues) {
            // Check if this is a scenario outline placeholder (e.g., "<age>")
            if (paramValue.startsWith("<") && paramValue.endsWith(">")) {
                // Extract placeholder name without angle brackets
                String placeholderName = paramValue.substring(1, paramValue.length() - 1);

                // Look up the type from scenarioParameterTypes and enumTypes
                if (scenarioParameterNames != null && scenarioParameterTypes != null) {
                    int index = scenarioParameterNames.indexOf(placeholderName);
                    if (index >= 0 && index < scenarioParameterTypes.size()) {
                        // Check if this is an enum type
                        if (enumTypes != null && enumTypes.containsKey(index)) {
                            // Get the first enum constant from the enum type
                            TypeMirror enumType = enumTypes.get(index);
                            String sampleEnumValue = getFirstEnumConstant(enumType);
                            convertedParameterValues.add(sampleEnumValue);
                            continue;
                        }

                        // Use a sample value that can be converted to the inferred type
                        Class<?> paramType = scenarioParameterTypes.get(index);
                        String sampleValue = getSampleValueForType(paramType);
                        convertedParameterValues.add(sampleValue);
                        continue;
                    }
                }
                // If we can't find the type, keep the placeholder as-is (will fail conversion check)
                convertedParameterValues.add(paramValue);
            } else {
                // For simple quoted parameters, use as-is
                convertedParameterValues.add(paramValue);
            }
        }

        return findMatchingBaseMethod(stepMethodName, convertedParameterValues, hasDataTableOrDocString) != null;
    }

    /**
     * Returns a sample value that can be parsed as the given type.
     * This is used for checking type compatibility with base class methods.
     */
    private String getSampleValueForType(Class<?> type) {
        if (type == Integer.class || type == int.class) {
            return "0";
        } else if (type == Long.class || type == long.class) {
            return "0";
        } else if (type == Double.class || type == double.class) {
            return "0.0";
        } else if (type == Boolean.class || type == boolean.class) {
            return "true";
        } else if (type == Character.class || type == char.class) {
            return "a";
        } else {
            return "sample";
        }
    }

    /**
     * Gets the first enum constant from an enum type.
     * Returns the constant name in uppercase (e.g., "MONDAY").
     */
    private String getFirstEnumConstant(TypeMirror enumType) {
        DeclaredType declaredType = (DeclaredType) enumType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();

        for (Element enclosed : enumElement.getEnclosedElements()) {
            if (enclosed.getKind() == ElementKind.ENUM_CONSTANT) {
                return enclosed.getSimpleName().toString();
            }
        }

        // Fallback - shouldn't happen for valid enums
        return "UNKNOWN";
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
     * Finds a matching base class method signature for the given method name.
     * Matching is based on method name only — neither parameter count nor parameter type
     * compatibility is checked. If the step values cannot be converted to the method's
     * parameter types, the generated code will produce a compilation error, which is the
     * intended behavior.
     *
     * @param stepMethodName          the step method name
     * @param parameterValues         the parameter values from the step text (unused, kept for API compatibility)
     * @param hasDataTableOrDocString true if the step has a DataTable or DocString parameter (unused, kept for API compatibility)
     * @return the matching method signature, or null if no match found
     */
    private ElementMethodUtils.MethodSignature findMatchingBaseMethod(
            String stepMethodName, List<String> parameterValues, boolean hasDataTableOrDocString) {

        if (baseClassMethodSignatures == null || !baseClassMethodSignatures.containsKey(stepMethodName)) {
            return null;
        }

        List<ElementMethodUtils.MethodSignature> signatures = baseClassMethodSignatures.get(stepMethodName);
        if (!signatures.isEmpty()) {
            return signatures.getFirst();
        }

        return null;
    }

    private void addACallToTheStepMethod(
            MethodSpec.Builder scenarioMethodBuilder,
            String stepMethodName,
            List<String> parameterValues,
            List<Class<?>> parameterTypes,
            Step step,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames,
            List<Class<?>> scenarioParameterTypes,
            Map<Integer, TypeMirror> enumParameterTypes
    ) {

        /**
         * add block comment for the step as it appears in the feature file
         */
        String stepFirstLine = step.getKeyword() + step.getText();
        scenarioMethodBuilder.addCode("/*");
        if (options.isAddSourceLineNumbers()) {
            scenarioMethodBuilder.addCode("\n * [$L] $L", step.getLocation().getLine(), stepFirstLine);
        } else {
            scenarioMethodBuilder.addCode("\n * $L", stepFirstLine);
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
            } else {
                /**
                 * Check if the quoted parameter value contains embedded scenario outline placeholders
                 * (e.g., "prefix <value> suffix"). If so, generate a replaceAll chain expression.
                 */
                String embeddedPlaceholderExpr = resolveEmbeddedOutlinePlaceholders(
                        parameterValue, scenarioParameterNames, testMethodParameterNames,
                        scenarioParameterTypes, enumParameterTypes);
                if (embeddedPlaceholderExpr != null) {
                    parameterValuesSB.append(embeddedPlaceholderExpr);
                } else if (matchingBaseMethod != null) {
                    /**
                     * Base class has a method with compatible parameter types
                     * Convert the string value to the appropriate type literal
                     */
                    TypeMirror targetType = matchingBaseMethod.getParameterType(j);
                    String targetTypeName = targetType.toString();

                    if ("java.math.BigDecimal".equals(targetTypeName)) {
                        parameterValuesSB.append("new $T(\"").append(parameterValue).append("\")");
                        formatArgsList.add(java.math.BigDecimal.class);
                    } else if ("java.math.BigInteger".equals(targetTypeName)) {
                        parameterValuesSB.append("new $T(\"").append(parameterValue).append("\")");
                        formatArgsList.add(java.math.BigInteger.class);
                    } else {
                        boolean isEnumType = ParameterConversionUtils.isEnumType(targetType);

                        if (isEnumType && options.isUseQualifiedEnumConstants()) {
                            String resolvedConstant = ParameterConversionUtils.resolveEnumConstantName(parameterValue, targetType);
                            if (resolvedConstant != null) {
                                // Use qualified enum literal (e.g., Status.AVAILABLE)
                                String literal = ParameterConversionUtils.toQualifiedEnumLiteral(parameterValue, targetType);
                                parameterValuesSB.append(literal);
                                // Register enum type for regular import (only if external)
                                if (enumImportCollector != null && isEnumExternal(targetType)) {
                                    String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(targetType);
                                    enumImportCollector.registerEnumType(enumQualifiedName);
                                }
                            } else {
                                // Value couldn't be resolved - place as quoted string (will cause compilation error)
                                parameterValuesSB.append("\"").append(escapeForJavaStringLiteral(parameterValue)).append("\"");
                            }
                        } else {
                            String literal = ParameterConversionUtils.toLiteral(parameterValue, targetType);
                            // If toLiteral did not perform a conversion (returned the value as a quoted string),
                            // try domain value object factory method resolution for non-enum declared types.
                            String quotedFallback = "\"" + escapeForJavaStringLiteral(parameterValue) + "\"";
                            if (!isEnumType && literal.equals(quotedFallback)) {
                                String inferredColumnTypeName = inferredColumnTypeNameForClass(parameterTypes.get(j));
                                String factoryCall = resolveDomainValueObjectFactoryCall(parameterValue, targetType, inferredColumnTypeName);
                                if (factoryCall != null) {
                                    parameterValuesSB.append(factoryCall);
                                } else {
                                    parameterValuesSB.append(literal);
                                }
                            } else {
                                parameterValuesSB.append(literal);
                            }
                            // Register enum constants for static import only if value resolved to a constant
                            if (enumImportCollector != null && isEnumType) {
                                String resolvedConstant = ParameterConversionUtils.resolveEnumConstantName(parameterValue, targetType);
                                if (resolvedConstant != null) {
                                    String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(targetType);
                                    enumImportCollector.registerEnumConstant(enumQualifiedName, resolvedConstant);
                                }
                            }
                        }
                    }
                } else {
                    /**
                     * No matching base method, use inferred type from parameter value
                     */
                    Class<?> inferredType = parameterTypes.get(j);
                    if (inferredType == java.math.BigDecimal.class) {
                        parameterValuesSB.append("new $T(\"").append(parameterValue).append("\")");
                        formatArgsList.add(java.math.BigDecimal.class);
                    } else if (inferredType == java.math.BigInteger.class) {
                        parameterValuesSB.append("new $T(\"").append(parameterValue).append("\")");
                        formatArgsList.add(java.math.BigInteger.class);
                    } else {
                        String literal = toLiteralForInferredType(parameterValue, inferredType);
                        parameterValuesSB.append(literal);
                    }
                }
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

                        // Get constructor parameter types for type conversion
                        List<TypeMirror> constructorParamTypes = null;
                        if (useExistingTypeOrder) {
                            TypeElement existingType = inheritedTypeInfo != null && inheritedTypeInfo.isCompatible()
                                    ? inheritedTypeInfo.typeElement()
                                    : recordMetadata.getExistingType();
                            if (existingType != null) {
                                ExecutableElement constructor = InnerTypeUtils.findAllArgsConstructor(existingType);
                                if (constructor != null) {
                                    constructorParamTypes = constructor.getParameters().stream()
                                            .map(VariableElement::asType)
                                            .collect(Collectors.toList());
                                }
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

                                // First pass: collect all transformed values to check if any contain replaceAll
                                List<String> transformedValues = new ArrayList<>();
                                for (int i = 0; i < constructorParams.size(); i++) {
                                    String mappedColumnName = paramIndexToColumnName.get(i);
                                    if (mappedColumnName != null) {
                                        int columnIndex = columnNames.indexOf(mappedColumnName);
                                        if (columnIndex >= 0 && columnIndex < cells.size()) {
                                            String cellValue = cells.get(columnIndex).getValue().trim();
                                            // Empty cell values should be treated as null
                                            if (cellValue.isEmpty()) {
                                                transformedValues.add("null");
                                            } else {
                                                TypeMirror targetType = (constructorParamTypes != null && i < constructorParamTypes.size())
                                                        ? constructorParamTypes.get(i)
                                                        : null;
                                                String transformedValue = transformCellValueWithPlaceholders(
                                                        cellValue, scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes, targetType);
                                                if (targetType != null) {
                                                    String inferredColumnType = lookupInferredColumnType(recordMetadata, mappedColumnName);
                                                    transformedValue = applyTypeConversion(transformedValue, targetType, inferredColumnType);
                                                }
                                                transformedValues.add(transformedValue);
                                            }
                                        } else {
                                            transformedValues.add("null");
                                        }
                                    } else {
                                        transformedValues.add("null");
                                    }
                                }

                                // Multi-line format: each constructor argument on new line
                                for (int i = 0; i < transformedValues.size(); i++) {
                                    if (i > 0) {
                                        parameterValuesSB.append(",");
                                    }
                                    parameterValuesSB.append("\n                ");
                                    parameterValuesSB.append(transformedValues.get(i));
                                }
                                // Close parenthesis on new line
                                parameterValuesSB.append("\n        )");
                            } else {
                                // Generate new type: use data table column order
                                List<String> recordColumnNames = recordMetadata.getColumnNames();
                                List<String> recordColumnTypes = recordMetadata.getColumnTypes();

                                // First pass: collect all transformed values
                                List<String> transformedValues = new ArrayList<>();
                                for (int i = 0; i < recordColumnNames.size(); i++) {
                                    String columnType = recordColumnTypes.get(i);

                                    // Get TypeMirror for the inferred column type
                                    TypeMirror targetType = getTypeMirrorForColumnType(columnType);

                                    // Find column index in the current data table
                                    int columnIndex = columnNames.indexOf(recordColumnNames.get(i));
                                    if (columnIndex >= 0 && columnIndex < cells.size()) {
                                        String cellValue = cells.get(columnIndex).getValue().trim();
                                        // Empty cell values should be treated as null
                                        if (cellValue.isEmpty()) {
                                            transformedValues.add("null");
                                        } else {
                                            String transformedValue = transformCellValueWithPlaceholders(
                                                    cellValue, scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes, targetType);
                                            // Apply type conversion for non-String types
                                            if (targetType != null) {
                                                transformedValue = applyTypeConversion(transformedValue, targetType, columnType);
                                            }
                                            transformedValues.add(transformedValue);
                                        }
                                    } else {
                                        // Column not present in this data table, use null
                                        transformedValues.add("null");
                                    }
                                }

                                // Multi-line format: each constructor argument on new line
                                for (int i = 0; i < transformedValues.size(); i++) {
                                    if (i > 0) {
                                        parameterValuesSB.append(",");
                                    }
                                    parameterValuesSB.append("\n                ");
                                    parameterValuesSB.append(transformedValues.get(i));
                                }
                                // Close parenthesis on new line
                                parameterValuesSB.append("\n        )");
                            }
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

                            // Check if parameter type is String, if not, call .toString()
                            if (scenarioParameterTypes != null && i < scenarioParameterTypes.size()) {
                                Class<?> paramType = scenarioParameterTypes.get(i);
                                if (paramType != String.class) {
                                    parameterValuesSB.append(testMethodParameterName).append(".toString()");
                                } else {
                                    parameterValuesSB.append(testMethodParameterName);
                                }
                            } else {
                                parameterValuesSB.append(testMethodParameterName);
                            }

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
            // Must be done AFTER triple quote and backslash escaping to avoid double-escaping
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

                        // Check if parameter type is String, if not, call .toString()
                        if (scenarioParameterTypes != null && i < scenarioParameterTypes.size()) {
                            Class<?> paramType = scenarioParameterTypes.get(i);
                            if (paramType != String.class) {
                                parameterValuesSB.append(testMethodParameterName).append(".toString()");
                            } else {
                                parameterValuesSB.append(testMethodParameterName);
                            }
                        } else {
                            parameterValuesSB.append(testMethodParameterName);
                        }

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
     * Checks if a quoted parameter value contains embedded scenario outline placeholders
     * (e.g., "prefix &lt;value&gt; suffix") and builds a replaceAll chain expression.
     * <p>
     * This follows the same pattern used by {@link #transformCellValueWithPlaceholders}
     * for DataTable cells with mixed content.
     *
     * @return a replaceAll chain expression, or null if no embedded placeholders are found
     */
    private String resolveEmbeddedOutlinePlaceholders(
            String parameterValue, List<String> scenarioParameterNames,
            List<String> testMethodParameterNames,
            List<Class<?>> scenarioParameterTypes,
            Map<Integer, TypeMirror> enumParameterTypes
    ) {
        if (scenarioParameterNames == null || scenarioParameterNames.isEmpty()) {
            return null;
        }

        // Find all outline placeholders present in the parameter value
        List<Integer> presentPlaceholderIndices = new ArrayList<>();
        for (int i = 0; i < scenarioParameterNames.size(); i++) {
            String placeholder = "<" + scenarioParameterNames.get(i) + ">";
            if (parameterValue.contains(placeholder)) {
                presentPlaceholderIndices.add(i);
            }
        }

        if (presentPlaceholderIndices.isEmpty()) {
            return null;
        }

        // Build a replaceAll chain: "prefix <value> suffix".replaceAll("<value>", value)
        StringBuilder result = new StringBuilder();
        result.append("\"").append(parameterValue.replace("$", "$$")).append("\"");

        for (int paramIndex : presentPlaceholderIndices) {
            String placeholder = "<" + scenarioParameterNames.get(paramIndex) + ">";
            String paramName = testMethodParameterNames.get(paramIndex);
            result.append("\n.replaceAll(\"").append(placeholder).append("\", ");

            // For non-String types, call .toString() or .name() for enums
            boolean isEnum = enumParameterTypes != null && enumParameterTypes.containsKey(paramIndex);
            Class<?> paramType = (scenarioParameterTypes != null && paramIndex < scenarioParameterTypes.size())
                    ? scenarioParameterTypes.get(paramIndex) : String.class;

            if (isEnum) {
                result.append(paramName).append(".name()");
            } else if (paramType != String.class) {
                result.append(paramName).append(".toString()");
            } else {
                result.append(paramName);
            }

            result.append(")");
        }

        return result.toString();
    }

    /**
     * Converts a parameter value to a typed literal based on the inferred type.
     *
     * @param value the parameter value (e.g., "42", "true", "A")
     * @param inferredType the inferred type (Boolean.class, Integer.class, Long.class, Double.class, Character.class, or String.class)
     * @return the typed literal (e.g., true, 42, 42L, 19.99, 'A', "text")
     */
    private String toLiteralForInferredType(String value, Class<?> inferredType) {
        if (inferredType == Boolean.class) {
            return value.toLowerCase(); // "true" or "false"
        } else if (inferredType == Integer.class || inferredType == int.class) {
            return value; // No suffix needed for int
        } else if (inferredType == Long.class || inferredType == long.class) {
            return value + "L"; // Add L suffix for long
        } else if (inferredType == Float.class || inferredType == float.class) {
            return value + "F"; // Add F suffix for float
        } else if (inferredType == Double.class || inferredType == double.class) {
            // Check if the value already has a decimal point
            if (value.contains(".")) {
                return value; // No suffix needed for double with decimal
            } else {
                return value + ".0"; // Add .0 for whole numbers
            }
        } else if (inferredType == Byte.class || inferredType == byte.class) {
            return "(byte) " + value; // Cast for byte
        } else if (inferredType == Short.class || inferredType == short.class) {
            return "(short) " + value; // Cast for short
        } else if (inferredType == java.math.BigDecimal.class) {
            return "new BigDecimal(\"" + value + "\")";
        } else if (inferredType == java.math.BigInteger.class) {
            return "new BigInteger(\"" + value + "\")";
        } else if (inferredType == Character.class) {
            return "'" + value + "'"; // Single quotes for char
        } else {
            // String type: use quoted string
            // Escape backslashes and quotes for valid Java string literal,
            // and $ as $$ for JavaPoet's CodeBlock.of() which uses $ as format specifier
            return "\"" + escapeForJavaStringLiteral(value) + "\"";
        }
    }

    private static String escapeForJavaStringLiteral(String value) {
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("$", "$$");
    }

    /**
     * Applies type conversion to a transformed cell value based on the target constructor parameter type.
     * Handles primitives (int, long, double, boolean), wrapper types (Integer, Long, Double, Boolean),
     * and enum types (with static import registration).
     * <p>
     * For values containing .replaceAll() (i.e., Scenario Outline placeholders with mixed content),
     * returns the expression as-is without any type conversion. This produces a String value which
     * will cause compilation errors if the target type is not String-compatible, ensuring compile-time
     * type safety.
     *
     * @param value the transformed cell value (typically a quoted string like "30" or a replaceAll expression)
     * @param targetType the target constructor parameter type
     * @return the converted value literal (e.g., 30 for int, 30L for long, AVAILABLE for enum)
     */
    private String applyTypeConversion(String value, TypeMirror targetType) {
        return applyTypeConversion(value, targetType, null);
    }

    private String applyTypeConversion(String value, TypeMirror targetType, String inferredColumnTypeName) {
        // For replaceAll expressions (mixed content with placeholders), return as-is.
        // This produces a String value which will cause compilation errors if the target
        // type is not String-compatible (int, long, double, boolean, enum, etc.)
        if (value.contains(".replaceAll(")) {
            return value;
        }

        // If not a quoted string (e.g., a parameter reference), don't convert
        if (!value.startsWith("\"")) {
            return value;
        }

        // Extract the string content (remove surrounding quotes)
        String stringValue = value.substring(1, value.length() - 1);

        boolean isEnumType = ParameterConversionUtils.isEnumType(targetType);

        // Handle enum types with qualified constants option
        if (isEnumType && options.isUseQualifiedEnumConstants()) {
            String resolvedConstant = ParameterConversionUtils.resolveEnumConstantName(stringValue, targetType);
            if (resolvedConstant != null) {
                // Use qualified enum literal (e.g., Status.AVAILABLE)
                String literal = ParameterConversionUtils.toQualifiedEnumLiteral(stringValue, targetType);
                // Register enum type for regular import (only if external)
                if (enumImportCollector != null && isEnumExternal(targetType)) {
                    String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(targetType);
                    enumImportCollector.registerEnumType(enumQualifiedName);
                }
                return literal;
            }
            return value;
        }

        // Apply type conversion using ParameterConversionUtils
        String literal = ParameterConversionUtils.toLiteral(stringValue, targetType);

        // If the literal is different from the original quoted string, we converted successfully
        if (!literal.equals(value)) {
            // Register enum constant for static import if this is an enum type
            if (isEnumType && enumImportCollector != null) {
                String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(targetType);
                enumImportCollector.registerEnumConstant(enumQualifiedName, literal);
            }
            return literal;
        }

        // Try domain value object factory method resolution for non-enum declared types
        String factoryCall = resolveDomainValueObjectFactoryCall(stringValue, targetType, inferredColumnTypeName);
        if (factoryCall != null) {
            return factoryCall;
        }

        // Return original if no conversion was applied
        return value;
    }

    private String inferredColumnTypeNameForClass(Class<?> inferredType) {
        if (inferredType == null) {
            return null;
        }
        if (inferredType == Boolean.class || inferredType == boolean.class) {
            return "Boolean";
        }
        if (inferredType == Integer.class || inferredType == int.class) {
            return "Integer";
        }
        if (inferredType == Long.class || inferredType == long.class) {
            return "Long";
        }
        if (inferredType == Double.class || inferredType == double.class
                || inferredType == Float.class || inferredType == float.class) {
            return "Double";
        }
        if (inferredType == Character.class || inferredType == char.class) {
            return "Character";
        }
        if (inferredType == String.class) {
            return "String";
        }
        return null;
    }

    private String lookupInferredColumnType(RecordMetadata recordMetadata, String columnName) {
        if (recordMetadata == null || columnName == null) {
            return null;
        }
        int idx = recordMetadata.getColumnNames().indexOf(columnName);
        if (idx < 0 || idx >= recordMetadata.getColumnTypes().size()) {
            return null;
        }
        return recordMetadata.getColumnTypes().get(idx);
    }

    /**
     * Attempts to wrap the given cell value in a static factory method call on {@code targetType}
     * when the target is a non-enum declared domain value object type (e.g., {@code Money}).
     *
     * @param stringValue            the raw cell value (without surrounding quotes)
     * @param targetType             the declared parameter class field type
     * @param inferredColumnTypeName the inferred Gherkin column type (e.g., "Double"), or {@code null}
     * @return the factory call expression (e.g., {@code Money.of(60.00)}), or {@code null} when no
     * suitable factory method is found or the resolution is ambiguous
     */
    private String resolveDomainValueObjectFactoryCall(String stringValue, TypeMirror targetType,
                                                       String inferredColumnTypeName) {
        DomainValueObjectFactoryResolver.Resolution resolution =
                DomainValueObjectFactoryResolver.resolve(targetType, inferredColumnTypeName);
        if (resolution == null) {
            return null;
        }
        TypeElement typeElement = (TypeElement) ((DeclaredType) targetType).asElement();
        String renderedArg = ParameterConversionUtils.toLiteral(stringValue, resolution.paramType());
        registerDomainTypeImportIfNeeded(typeElement);
        return typeElement.getSimpleName().toString()
                + "."
                + resolution.factory().getSimpleName().toString()
                + "(" + renderedArg + ")";
    }

    /**
     * Registers an import for the given domain type unless it is already accessible by simple name
     * from the generated test class: nested in the base class hierarchy, or a top-level type in
     * the same package as the base class.
     */
    private void registerDomainTypeImportIfNeeded(TypeElement typeElement) {
        if (enumImportCollector == null) {
            return;
        }
        if (baseType != null && isNestedInBaseHierarchy(typeElement)) {
            return;
        }
        if (isTopLevelInSamePackageAsBase(typeElement)) {
            return;
        }
        String qualifiedName = typeElement.getQualifiedName().toString();
        enumImportCollector.registerAdditionalImport(qualifiedName);
    }

    private boolean isNestedInBaseHierarchy(TypeElement typeElement) {
        String qualifiedName = typeElement.getQualifiedName().toString();
        String baseQualifiedName = baseType.getQualifiedName().toString();
        if (qualifiedName.startsWith(baseQualifiedName + ".")) {
            return true;
        }
        TypeMirror superclass = baseType.getSuperclass();
        while (superclass != null && superclass.getKind() == javax.lang.model.type.TypeKind.DECLARED) {
            DeclaredType declaredSuperclass = (DeclaredType) superclass;
            TypeElement superclassElement = (TypeElement) declaredSuperclass.asElement();
            String superQualifiedName = superclassElement.getQualifiedName().toString();
            if (qualifiedName.startsWith(superQualifiedName + ".")) {
                return true;
            }
            superclass = superclassElement.getSuperclass();
        }
        return false;
    }

    private boolean isTopLevelInSamePackageAsBase(TypeElement typeElement) {
        if (baseType == null) {
            return false;
        }
        Element enclosing = typeElement.getEnclosingElement();
        if (!(enclosing instanceof PackageElement packageElement)) {
            return false;
        }
        String typePackage = packageElement.getQualifiedName().toString();
        String basePackage = processingEnv.getElementUtils().getPackageOf(baseType).getQualifiedName().toString();
        return typePackage.equals(basePackage);
    }

    /**
     * Checks if the source type (test method parameter) matches the target type (constructor parameter).
     * This is used to determine if type conversion is needed when passing parameters directly.
     *
     * @param sourceType the source type from the test method parameter
     * @param targetType the target type for the constructor parameter
     * @param enumParameterTypes map of parameter indices to enum types
     * @param paramIndex the parameter index
     * @return true if types match and no conversion is needed, false otherwise
     */
    private boolean checkTypesMatch(Class<?> sourceType, TypeMirror targetType,
                                     Map<Integer, TypeMirror> enumParameterTypes, int paramIndex) {
        String targetTypeName = targetType.toString();
        boolean sourceIsEnum = enumParameterTypes != null && enumParameterTypes.containsKey(paramIndex);

        // If source is enum, check if target is the same enum type
        if (sourceIsEnum) {
            TypeMirror sourceEnumType = enumParameterTypes.get(paramIndex);
            return sourceEnumType.toString().equals(targetTypeName);
        }

        // Check if source class name matches target type name
        String sourceTypeName = sourceType.getName();

        // Direct match
        if (sourceTypeName.equals(targetTypeName)) {
            return true;
        }

        // Handle primitive to wrapper matching (e.g., int vs java.lang.Integer)
        if (targetType.getKind().isPrimitive()) {
            javax.lang.model.type.TypeKind targetKind = targetType.getKind();
            if (targetKind == javax.lang.model.type.TypeKind.INT && sourceTypeName.equals("java.lang.Integer")) {
                return true;
            }
            if (targetKind == javax.lang.model.type.TypeKind.LONG && sourceTypeName.equals("java.lang.Long")) {
                return true;
            }
            if (targetKind == javax.lang.model.type.TypeKind.DOUBLE && sourceTypeName.equals("java.lang.Double")) {
                return true;
            }
            if (targetKind == javax.lang.model.type.TypeKind.BOOLEAN && sourceTypeName.equals("java.lang.Boolean")) {
                return true;
            }
        }

        // Handle wrapper to primitive matching (e.g., java.lang.Integer vs int)
        if (sourceTypeName.equals("java.lang.Integer") && targetTypeName.equals("int")) {
            return true;
        }
        if (sourceTypeName.equals("java.lang.Long") && targetTypeName.equals("long")) {
            return true;
        }
        if (sourceTypeName.equals("java.lang.Double") && targetTypeName.equals("double")) {
            return true;
        }
        if (sourceTypeName.equals("java.lang.Boolean") && targetTypeName.equals("boolean")) {
            return true;
        }

        return false;
    }

    /**
     * Transforms a data table cell value by substituting placeholders with replaceAll chains.
     * <p>
     * This method handles three cases:
     * <ul>
     *   <li>Cell is exactly a single placeholder (e.g., {@code <name>}): returns the parameter directly
     *       (e.g., {@code name})</li>
     *   <li>Cell contains mixed content or multiple placeholders (e.g., {@code Hello <name>!}): returns a replaceAll chain
     *       (e.g., {@code "Hello <name>!".replaceAll("<name>", name)})</li>
     *   <li>No placeholders (e.g., {@code literal}): returns the quoted string (e.g., {@code "literal"})</li>
     * </ul>
     *
     * @param cellValue              the cell value from the data table
     * @param scenarioParameterNames the list of placeholder names from the Examples table
     * @param testMethodParameterNames the list of corresponding Java parameter names
     * @param scenarioParameterTypes the list of parameter types (may be null)
     * @return the transformed expression suitable for code generation
     */
    private String transformCellValueWithPlaceholders(
            String cellValue,
            List<String> scenarioParameterNames,
            List<String> testMethodParameterNames,
            List<Class<?>> scenarioParameterTypes,
            Map<Integer, TypeMirror> enumParameterTypes,
            TypeMirror targetType
    ) {
        // If no scenario parameters are defined, just quote the value
        if (scenarioParameterNames == null || scenarioParameterNames.isEmpty()) {
            return "\"" + cellValue + "\"";
        }

        // Find all placeholders that are present in the cell value
        List<Integer> presentPlaceholderIndices = new ArrayList<>();
        for (int i = 0; i < scenarioParameterNames.size(); i++) {
            String placeholder = "<" + scenarioParameterNames.get(i) + ">";
            if (cellValue.contains(placeholder)) {
                presentPlaceholderIndices.add(i);
            }
        }

        // If no placeholders, just quote the value
        if (presentPlaceholderIndices.isEmpty()) {
            return "\"" + cellValue + "\"";
        }

        // Special case: if the cell value is exactly a single placeholder, return the parameter directly
        if (presentPlaceholderIndices.size() == 1) {
            int paramIndex = presentPlaceholderIndices.get(0);
            String placeholder = "<" + scenarioParameterNames.get(paramIndex) + ">";
            if (cellValue.equals(placeholder)) {
                String paramName = testMethodParameterNames.get(paramIndex);

                // No automatic type conversion - return parameter as-is
                // If types don't match, let the compiler catch it at compile-time
                return paramName;
            }
        }

        // Build a replaceAll chain expression for mixed content or multiple placeholders
        // Start with the quoted cell value, then chain replaceAll calls for each placeholder
        StringBuilder result = new StringBuilder();
        result.append("\"").append(cellValue).append("\"");

        for (int paramIndex : presentPlaceholderIndices) {
            String placeholder = "<" + scenarioParameterNames.get(paramIndex) + ">";
            String paramName = testMethodParameterNames.get(paramIndex);
            result.append(".replaceAll(\"").append(placeholder).append("\", ");

            // Check if parameter type is String, if not, call .toString() or .name() for enums
            if (scenarioParameterTypes != null && paramIndex < scenarioParameterTypes.size()) {
                // Check if this parameter is an enum by looking it up in enumParameterTypes
                boolean isEnum = enumParameterTypes != null && enumParameterTypes.containsKey(paramIndex);

                Class<?> paramType = scenarioParameterTypes.get(paramIndex);
                if (paramType != String.class || isEnum) {
                    if (isEnum) {
                        result.append(paramName).append(".name()");
                    } else {
                        result.append(paramName).append(".toString()");
                    }
                } else {
                    result.append(paramName);
                }
            } else {
                result.append(paramName);
            }

            result.append(")");
        }

        return result.toString();
    }

    /**
     * Resolves the GWT keyword for a step. For Given/When/Then steps, returns the keyword directly.
     * For And/But/* steps, inherits the keyword from the previous step.
     */
    private String resolveGWTKeyword(String stepKeyword, List<String> resolvedStepKeywords, long stepLine) {
        String keywordLower = stepKeyword.toLowerCase();

        if (keywordLower.equals("given") || keywordLower.equals("when") || keywordLower.equals("then")) {
            return keywordLower;
        } else if (keywordLower.equals("and") || keywordLower.equals("but") || keywordLower.equals("*")) {
            if (resolvedStepKeywords.isEmpty()) {
                throw new ProcessingException(
                        "Step on line - " + stepLine
                                + " starts with 'And', but there are no previous scenario steps defined");
            }
            return resolvedStepKeywords.get(resolvedStepKeywords.size() - 1);
        } else {
            throw new ProcessingException(
                    "Step keyword is not a valid Gherkin keyword (Given, When, Then, And, But, *): "
                            + stepKeyword);
        }
    }

    private AnnotationSpec buildGWTAnnotation(
            String resolvedKeyword, String stepMethodName,
            MethodSignatureAttributes signatureAttributes) {

        List<String> parameterValues = signatureAttributes.parameterValues;

        AnnotationSpec.Builder annotationSpecBuilder;
        if (resolvedKeyword.equals("given")) {
            annotationSpecBuilder = AnnotationSpec.builder(Given.class);
        } else if (resolvedKeyword.equals("when")) {
            annotationSpecBuilder = AnnotationSpec.builder(When.class);
        } else if (resolvedKeyword.equals("then")) {
            annotationSpecBuilder = AnnotationSpec.builder(Then.class);
        } else {
            throw new ProcessingException(
                    "Step method name does not start with a valid keyword (Given, When, Then): "
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
            List<String> scenarioParameterNames,
            List<Class<?>> scenarioParameterTypes,
            List<MethodSpec> scenarioStepsMethodSpecs,
            long stepLine) {

        List<String> parameterValues = new ArrayList<>();

        String stepPattern = processWithParameterPattern(
                stepFirstLine, parameterPattern, parameterValues);

        // Look up pre-computed widened types using the pattern before scenario parameter replacement
        List<Class<?>> preComputed = preComputedStepTypes.get(stepPattern);

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

        String stepMethodName = MethodNamingUtils.getStepMethodName(stepPattern, scenarioStepsMethodSpecs, stepLine,
                getOptions().isUseStepKeywordInStepMethodName());
        List<Class<?>> parameterTypes = new ArrayList<>();
        for (int i = 0; i < parameterValues.size(); i++) {
            String paramValue = parameterValues.get(i);
            // Check if this is a scenario outline placeholder (e.g., "<age>")
            if (paramValue.startsWith("<") && paramValue.endsWith(">")) {
                // Extract placeholder name without angle brackets
                String placeholderName = paramValue.substring(1, paramValue.length() - 1);

                // Look up the type from scenarioParameterTypes
                Class<?> paramType = String.class; // default
                if (scenarioParameterNames != null && scenarioParameterTypes != null) {
                    int index = scenarioParameterNames.indexOf(placeholderName);
                    if (index >= 0 && index < scenarioParameterTypes.size()) {
                        paramType = scenarioParameterTypes.get(index);
                    }
                }
                parameterTypes.add(paramType);
            } else if (preComputed != null && i < preComputed.size()) {
                // Use pre-computed widened type (considers all occurrences of this step)
                parameterTypes.add(preComputed.get(i));
            } else {
                // For simple quoted parameters, infer the type from the value
                Class<?> inferredType = ParameterConversionUtils.inferType(paramValue);
                parameterTypes.add(inferredType);
            }
        }

        MethodSignatureAttributes signatureAttributes = new MethodSignatureAttributes(
                stepPattern,
                stepMethodName,
                parameterValues,
                parameterTypes
        );
        return signatureAttributes;
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
            parameterValue = parameterValue.replaceAll("\\\\([\"\\\\])", "$1");
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

    /**
     * Checks if an enum type is external to the base class hierarchy.
     * An enum is considered external if it's not defined as a nested type in the base class or any of its ancestors.
     *
     * @param enumType the enum TypeMirror to check
     * @return true if the enum is external (needs import), false if it's internal (no import needed)
     */
    private boolean isEnumExternal(TypeMirror enumType) {
        if (baseType == null) {
            // If there's no base type, consider all enums as external
            return true;
        }

        String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(enumType);

        // Check if the enum is nested in the base class
        String baseQualifiedName = baseType.getQualifiedName().toString();
        if (enumQualifiedName.startsWith(baseQualifiedName + ".")) {
            return false; // Enum is nested in base class
        }

        // Check if the enum is nested in any superclass
        TypeMirror superclass = baseType.getSuperclass();
        while (superclass != null && superclass.getKind() == javax.lang.model.type.TypeKind.DECLARED) {
            DeclaredType declaredSuperclass = (DeclaredType) superclass;
            TypeElement superclassElement = (TypeElement) declaredSuperclass.asElement();
            String superclassQualifiedName = superclassElement.getQualifiedName().toString();

            if (enumQualifiedName.startsWith(superclassQualifiedName + ".")) {
                return false; // Enum is nested in superclass
            }

            superclass = superclassElement.getSuperclass();
        }

        // Enum is not nested in base class or any superclass - it's external
        return true;
    }

    /**
     * Converts a column type string to the corresponding TypeMirror.
     * Supports Java wrapper types and String.
     *
     * @param columnType the column type string (e.g., "Boolean", "Integer", "String")
     * @return the corresponding TypeMirror
     */
    private TypeMirror getTypeMirrorForColumnType(String columnType) {
        String qualifiedTypeName = switch (columnType) {
            case "Boolean" -> "java.lang.Boolean";
            case "Integer" -> "java.lang.Integer";
            case "Long" -> "java.lang.Long";
            case "Double" -> "java.lang.Double";
            case "Character" -> "java.lang.Character";
            default -> "java.lang.String";
        };

        TypeElement typeElement = processingEnv.getElementUtils().getTypeElement(qualifiedTypeName);
        return typeElement != null ? typeElement.asType() :
                processingEnv.getElementUtils().getTypeElement("java.lang.String").asType();
    }

}