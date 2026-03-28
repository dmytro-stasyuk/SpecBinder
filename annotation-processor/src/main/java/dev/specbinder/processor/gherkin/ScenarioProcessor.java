package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeName;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.gherkin.utils.RecordMetadata;
import dev.specbinder.processor.support.BaseTypeSupport;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.*;
import io.cucumber.messages.types.*;
import io.cucumber.messages.types.Tag;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.*;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeMirror;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class ScenarioProcessor implements LoggingSupport, OptionsSupport, BaseTypeSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final TypeElement baseType;
    private final Set<String> baseClassMethodNames;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;

    public ScenarioProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options, TypeElement baseType,
                             DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.baseType = baseType;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;

        baseClassMethodNames = ElementMethodUtils.getAllInheritedMethodNames(processingEnv, baseType);
    }

    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    public GeneratorOptions getOptions() {
        return options;
    }

    public TypeElement getBaseType() {
        return baseType;
    }

    MethodSpec.Builder processScenario(int scenarioNumber, Scenario scenario, TypeSpec.Builder classBuilder) {

        List<MethodSpec> allMethodSpecs = classBuilder.methodSpecs;

        List<Step> scenarioSteps = scenario.getSteps();
        List<MethodSpec> scenarioStepsMethodSpecs = new ArrayList<>(scenarioSteps.size());
        List<String> resolvedStepKeywords = new ArrayList<>(scenarioSteps.size());

        String scenarioMethodName = "scenario_" + scenarioNumber;
        MethodSpec.Builder scenarioMethodBuilder = MethodSpec
                .methodBuilder(scenarioMethodName)
                //                .addParameter(TestInfo.class, "testInfo")
                .addModifiers(Modifier.PUBLIC);

        String description = scenario.getDescription();
        if (StringUtils.isNotBlank(description)) {
            description = JavaDocUtils.trimLeadingAndTrailingWhitespace(description);
            scenarioMethodBuilder.addJavadoc(JavaDocUtils.escapeForJavaPoet(description));
        }

        List<Examples> examples = scenario.getExamples();
        List<String> scenarioParameterNames;
        List<String> testMethodParameterNames;
        List<Class<?>> scenarioParameterTypes;
        Map<Integer, TypeMirror> enumParameterTypes;

        if (examples != null && !examples.isEmpty()) {

            scenarioParameterNames = addJUnitAnnotationsForParameterizedTest(scenarioMethodBuilder, scenario);
            testMethodParameterNames = new ArrayList<>(scenarioParameterNames.size());

            // Extract parameter class field types from data tables (if any)
            Map<String, TypeMirror> allParameterClassFieldTypes = extractParameterClassFieldTypes(scenarioSteps);

            // Filter to only include field types for columns actually used as placeholders in data tables
            Map<String, TypeMirror> parameterClassFieldTypes = allParameterClassFieldTypes;
            if (allParameterClassFieldTypes != null && !allParameterClassFieldTypes.isEmpty()) {
                Set<String> columnsUsedAsPlaceholders = findColumnsUsedAsPlaceholders(scenarioSteps);
                if (!columnsUsedAsPlaceholders.isEmpty()) {
                    parameterClassFieldTypes = new HashMap<>();
                    for (Map.Entry<String, TypeMirror> entry : allParameterClassFieldTypes.entrySet()) {
                        if (columnsUsedAsPlaceholders.contains(entry.getKey())) {
                            parameterClassFieldTypes.put(entry.getKey(), entry.getValue());
                        }
                    }
                }
            }

            // Infer types for each column in the Examples tables
            ParameterConversionUtils.InferredColumnTypes inferredTypes = ParameterConversionUtils.inferColumnTypes(examples, baseType, processingEnv, parameterClassFieldTypes);
            enumParameterTypes = inferredTypes.enumTypes;

            // Convert map to list for easier access in processStep
            scenarioParameterTypes = new ArrayList<>(scenarioParameterNames.size());

            for (int i = 0; i < scenarioParameterNames.size(); i++) {
                String scenarioParameterName = scenarioParameterNames.get(i);
                String methodParameterName = ParameterNamingUtils.toMethodParameterName(scenarioParameterName);
                testMethodParameterNames.add(methodParameterName);

                // Use inferred type instead of hardcoded String.class
                TypeName parameterType = inferredTypes.typeNames.getOrDefault(i, TypeName.get(String.class));

                // When useQualifiedEnumConstants is true, customize the parameter type for enums
                if (getOptions().isUseQualifiedEnumConstants() && inferredTypes.enumTypes.containsKey(i)) {
                    TypeMirror enumType = inferredTypes.enumTypes.get(i);
                    String enumSimpleName = ParameterConversionUtils.getEnumSimpleName(enumType);

                    if (isEnumExternal(enumType)) {
                        // For external enums: register in EnumImportCollector and use simple name
                        // The import will be added via addEnumTypeImportsToSource() to avoid duplicates
                        String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(enumType);
                        if (enumImportCollector != null) {
                            enumImportCollector.registerEnumType(enumQualifiedName);
                        }
                        parameterType = com.squareup.javapoet.ClassName.bestGuess(enumSimpleName);
                    } else {
                        // For internal enums: use simple name without package qualification
                        // JavaPoet will not add an import for this
                        parameterType = com.squareup.javapoet.ClassName.bestGuess(enumSimpleName);
                    }
                }

                scenarioMethodBuilder.addParameter(parameterType, methodParameterName);

                // For scenarioParameterTypes, use String.class as a placeholder for enums
                // The actual enum type checking will happen via hasCompatibleBaseMethod() using TypeMirror
                if (inferredTypes.enumTypes.containsKey(i)) {
                    // Use String.class as a placeholder - the actual type checking will use TypeMirror
                    scenarioParameterTypes.add(String.class);
                } else {
                    // For primitives, extract the Class from TypeName
                    Class<?> parameterClass = typeNameToClass(parameterType);
                    scenarioParameterTypes.add(parameterClass);
                }
            }
        } else {
            scenarioParameterNames = null;
            testMethodParameterNames = null;
            scenarioParameterTypes = null;
            enumParameterTypes = null;

            addJUnitAnnotationsForSingleTest(scenarioMethodBuilder, scenario);
        }

        addOrderAnnotation(scenarioMethodBuilder, scenarioNumber);

        List<Tag> tags = scenario.getTags();
        if (tags != null && !tags.isEmpty()) {
            AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tags);
            scenarioMethodBuilder.addAnnotation(jUnitTagsAnnotation);
        }

        // Add tag for empty scenarios before @DisplayName
        if (scenarioSteps.isEmpty()) {
            String tagForEmptyScenarios = options.getTagForEmptyScenarios();
            if (StringUtils.isNotBlank(tagForEmptyScenarios)) {
                AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tagForEmptyScenarios);
                scenarioMethodBuilder.addAnnotation(jUnitTagsAnnotation);
            }
        }

        addDisplayNameAnnotation(scenarioMethodBuilder, scenario);

        if (scenarioSteps.isEmpty()) {

            if ("SKIP".equals(options.getEmptyScenarioBehavior())) {
                scenarioMethodBuilder.addStatement("$T.assumeTrue(false, \"Scenario has no steps\")", Assumptions.class);
            } else if ("COMPILATION_ERROR".equals(options.getEmptyScenarioBehavior())) {
                scenarioMethodBuilder.addCode("Scenario has no steps\n");
            } else {
                // Default to FAIL behavior
                scenarioMethodBuilder.addStatement("$T.fail(\"Scenario has no steps\")", Assertions.class);
            }

        } else {

            // Detect composite step patterns if enabled
            if (options.isEnableCompositeSteps()) {
                logInfo("Composite steps ENABLED - detecting composite step groups");
                logInfo("Number of scenario steps: " + scenarioSteps.size());
                List<Object> stepGroups = detectCompositeStepGroups(scenarioSteps);
                logInfo("Detected " + stepGroups.size() + " step groups");
                for (int i = 0; i < stepGroups.size(); i++) {
                    Object group = stepGroups.get(i);
                    if (group instanceof CompositeStepGroup) {
                        logInfo("Group " + i + ": CompositeStepGroup with " + ((CompositeStepGroup) group).size() + " sub-steps");
                    } else {
                        logInfo("Group " + i + ": Regular Step");
                    }
                }

                for (Object item : stepGroups) {
                    if (item instanceof CompositeStepGroup compositeGroup) {
                        // Process composite step
                        CompositeStepProcessor compositeProcessor = new CompositeStepProcessor(
                                processingEnv, options, dataTableCollector, enumImportCollector, baseType);
                        compositeProcessor.processCompositeStep(
                                compositeGroup, scenarioMethodBuilder, scenarioStepsMethodSpecs,
                                resolvedStepKeywords,
                                classBuilder, allMethodSpecs, baseClassMethodNames,
                                scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes
                        );
                    } else if (item instanceof Step regularStep) {
                        // Process regular step
                        StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);
                        MethodSpec stepMethodSpec = stepProcessor.processStep(
                                regularStep, scenarioMethodBuilder, scenarioStepsMethodSpecs,
                                resolvedStepKeywords,
                                scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes
                        );
                        scenarioStepsMethodSpecs.add(stepMethodSpec);

                        String stepMethodName = stepMethodSpec.name;
                        MethodSpec existingMethodSpec =
                                allMethodSpecs.stream().filter(methodSpec -> methodSpec.name.equals(stepMethodName))
                                        .findFirst()
                                        .orElse(null);

                        if (existingMethodSpec == null) {
                            // Check if base class has a compatible method (not just by name, but by signature)
                            boolean baseClassHasCompatibleMethod = stepProcessor.hasCompatibleBaseMethod(regularStep, scenarioParameterNames, scenarioParameterTypes, enumParameterTypes, scenarioStepsMethodSpecs);
                            // Also check if we need an overloaded method (inherited type incompatible)
                            boolean needsOverloadedMethod = stepNeedsOverloadedMethod(regularStep);
                            if (baseClassHasCompatibleMethod && !needsOverloadedMethod) {
                                logInfo("Skipping generation of method '" + stepMethodName + "', as base class already contains it");
                            } else {
                                classBuilder.addMethod(stepMethodSpec);
                            }
                        }
                    }
                }
            } else {
                // Original logic without composite steps
                for (Step scenarioStep : scenarioSteps) {

                    StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);
                    MethodSpec stepMethodSpec = stepProcessor.processStep(
                            scenarioStep, scenarioMethodBuilder, scenarioStepsMethodSpecs,
                            resolvedStepKeywords,
                            scenarioParameterNames, testMethodParameterNames, scenarioParameterTypes, enumParameterTypes
                    );
                    scenarioStepsMethodSpecs.add(stepMethodSpec);

                    String stepMethodName = stepMethodSpec.name;
                    MethodSpec existingMethodSpec =
                            allMethodSpecs.stream().filter(methodSpec -> methodSpec.name.equals(stepMethodName))
                                    .findFirst()
                                    .orElse(null);

                    if (existingMethodSpec == null) {
                        // Check if base class has a compatible method (not just by name, but by signature)
                        boolean baseClassHasCompatibleMethod = stepProcessor.hasCompatibleBaseMethod(scenarioStep, scenarioParameterNames, scenarioParameterTypes, enumParameterTypes, scenarioStepsMethodSpecs);
                        // Also check if we need an overloaded method (inherited type incompatible)
                        boolean needsOverloadedMethod = stepNeedsOverloadedMethod(scenarioStep);
                        if (baseClassHasCompatibleMethod && !needsOverloadedMethod) {
                            logInfo("Skipping generation of method '" + stepMethodName + "', as base class already contains it");
                        } else {
                            classBuilder.addMethod(stepMethodSpec);
                        }
                    }
                }
            }

        }

        return scenarioMethodBuilder;
    }

    private void addDisplayNameAnnotation(MethodSpec.Builder scenarioMethodBuilder, Scenario scenario) {

        String scenarioKeyword = scenario.getKeyword().trim();
        String scenarioName = scenario.getName();
        if (scenarioName != null) {
            scenarioName = scenarioName.replaceAll("\"", "\\\\\"");
            if (!scenarioName.isEmpty()) {
                scenarioName = " " + scenarioName;
            }
        }
        String displayNameValue;
        if (options.isAddSourceLineNumbers()) {
            long line = scenario.getLocation().getLine();
            displayNameValue = scenarioKeyword + " [" + line + "]:" + scenarioName;
        } else {
            displayNameValue = scenarioKeyword + ":" + scenarioName;
        }
        AnnotationSpec displayNameAnnotation = AnnotationSpec
                .builder(DisplayName.class)
                .addMember("value", "\"" + JavaDocUtils.escapeForJavaPoet(displayNameValue) + "\"")
                .build();
        scenarioMethodBuilder.addAnnotation(displayNameAnnotation);
    }

    private void addOrderAnnotation(MethodSpec.Builder scenarioMethodBuilder, int scenarioNumber) {

        AnnotationSpec orderAnnotation = AnnotationSpec
                .builder(Order.class)
                .addMember("value", "" + scenarioNumber)
                .build();
        scenarioMethodBuilder.addAnnotation(orderAnnotation);
    }

    private void addJUnitAnnotationsForSingleTest(MethodSpec.Builder scenarioMethodBuilder, Scenario scenario) {

        AnnotationSpec testAnnotation = AnnotationSpec
                .builder(Test.class)
                .build();
        scenarioMethodBuilder.addAnnotation(testAnnotation);
    }

    private List<String> addJUnitAnnotationsForParameterizedTest(
            MethodSpec.Builder scenarioMethodBuilder,
            Scenario scenario) {

        List<Examples> examples = scenario.getExamples();

        // Add @ParameterizedTest annotation once
        AnnotationSpec parameterizedTestAnnotation = AnnotationSpec
                .builder(ParameterizedTest.class)
                .addMember("name", "\"Example {index}: [{arguments}]\"")
                .build();
        scenarioMethodBuilder.addAnnotation(parameterizedTestAnnotation);

        // Validate that all Examples sections have the same header columns in the same order
        List<String> headerCells = null;
        for (int exampleIndex = 0; exampleIndex < examples.size(); exampleIndex++) {
            Examples examplesTable = examples.get(exampleIndex);
            List<String> currentHeaderCells = examplesTable.getTableHeader().get().getCells().stream()
                    .map(TableCell::getValue)
                    .toList();

            if (headerCells == null) {
                headerCells = currentHeaderCells;
            } else {
                // Validate headers match exactly (same columns in same order)
                if (!headerCells.equals(currentHeaderCells)) {
                    // Provide detailed error message
                    String errorMsg = "ERROR: All Examples sections must have identical header columns in the same order. ";
                    
                    if (headerCells.size() != currentHeaderCells.size()) {
                        errorMsg += "Expected " + headerCells.size() + " columns " + headerCells + 
                                    ", but found " + currentHeaderCells.size() + " columns " + currentHeaderCells +
                                    " in Examples section " + (exampleIndex + 1) + ".";
                    } else {
                        errorMsg += "Expected columns " + headerCells + 
                                    ", but found " + currentHeaderCells +
                                    " in Examples section " + (exampleIndex + 1) + 
                                    " (columns are in different order or have different names).";
                    }
                    
                    throw new ProcessingException(errorMsg);
                }
            }
        }

        // Add a @CsvSource annotation for each Examples section
        for (Examples examplesTable : examples) {
            /**
             * convert Examples into data table so that we can format it easily with pipe characters
             */
            TableRow tableHeader = examplesTable.getTableHeader().get();
            List<TableRow> tableBody = examplesTable.getTableBody();
            List<TableRow> allRows = new ArrayList<>(tableBody.size() + 1);
            allRows.add(tableHeader);
            allRows.addAll(tableBody);

            Location examplesTableLocation = examplesTable.getLocation();
            DataTable examplesDataTable = new DataTable(examplesTableLocation, allRows);

            List<Integer> maxColumnLengths = TableUtils.workOutMaxColumnLength(examplesDataTable);

            StringBuilder textBlockSB = new StringBuilder();
            textBlockSB.append("\"\"\"\n");

            for (TableRow row : allRows) {

                List<TableCell> rowCells = row.getCells();
                List<String> cellValues = new ArrayList<>(rowCells.size());

                for (int i = 0; i < rowCells.size(); i++) {
                    TableCell cell = rowCells.get(i);
                    String value = cell.getValue();

                    // Pad all columns except the last one to avoid trailing spaces
                    if (i < rowCells.size() - 1) {
                        int maxColumnLength = maxColumnLengths.get(i);
                        String paddedValue = StringUtils.rightPad(value, maxColumnLength);
                        cellValues.add(paddedValue);
                    } else {
                        // Last column - don't pad to avoid trailing spaces
                        cellValues.add(value);
                    }
                }

                String rowLine = String.join(" | ", cellValues);
                // If the last cell is empty, remove the trailing space after the last separator
                if (!cellValues.isEmpty() && cellValues.get(cellValues.size() - 1).isEmpty()) {
                    rowLine = rowLine.substring(0, rowLine.length() - 1);
                }
                textBlockSB.append(rowLine);
                textBlockSB.append("\n");
            }

            textBlockSB.append("\"\"\"");

            String textBlock = JavaDocUtils.escapeForJavaPoet(textBlockSB.toString());

            AnnotationSpec csvSourceAnnotation = AnnotationSpec
                    .builder(CsvSource.class)
                    .addMember("useHeadersInDisplayName", "true")
                    .addMember("delimiter", "'|'")
                    .addMember("textBlock", textBlock)
                    .build();
            scenarioMethodBuilder.addAnnotation(csvSourceAnnotation);
        }

        return headerCells;
    }

    /**
     * Detects composite step patterns in a list of steps.
     * A composite step is a Given/When/Then/And/But step followed by one or more '*' steps.
     *
     * @param steps the list of steps to analyze
     * @return a list where each element is either a CompositeStepGroup or a single Step
     */
    private static List<Object> detectCompositeStepGroups(List<Step> steps) {
        List<Object> result = new ArrayList<>();

        for (int i = 0; i < steps.size(); i++) {
            Step step = steps.get(i);
            String keyword = step.getKeyword().trim();

            // Check if this is a potential composite step parent (not *)
            if (!"*".equals(keyword)) {
                // Look ahead to see if there are * steps following
                List<Step> subSteps = new ArrayList<>();
                int j = i + 1;
                while (j < steps.size() && "*".equals(steps.get(j).getKeyword().trim())) {
                    subSteps.add(steps.get(j));
                    j++;
                }

                if (!subSteps.isEmpty()) {
                    // This is a composite step
                    CompositeStepGroup group = new CompositeStepGroup(step);
                    for (Step subStep : subSteps) {
                        group.addSubStep(subStep);
                    }
                    result.add(group);
                    i = j - 1;  // Skip the sub-steps we just processed
                } else {
                    // Regular step
                    result.add(step);
                }
            }
            // Note: * steps that aren't part of a composite group are skipped
            // (they would be orphaned * steps, which shouldn't happen in valid Gherkin)
        }

        return result;
    }

    /**
     * Checks if a step requires an overloaded method to be generated.
     * This happens when an inherited method exists but its List parameter type
     * doesn't have a constructor that can accept all data table columns.
     *
     * @param step the step to check
     * @return true if an overloaded method should be generated
     */
    private boolean stepNeedsOverloadedMethod(Step step) {
        if (dataTableCollector == null) {
            return false;
        }

        if (step.getDataTable().isEmpty()) {
            return false;
        }

        String stepText = step.getKeyword() + step.getText();
        String recordName = dataTableCollector.deriveRecordNameFromStepText(stepText);
        RecordMetadata recordMetadata = dataTableCollector.getRecordMetadataMap().get(recordName);

        return recordMetadata != null && recordMetadata.needsOverloadedMethod();
    }

    /**
     * Converts a TypeName to a Class<?> for primitive wrapper types.
     * Returns String.class for any non-primitive types.
     */
    private Class<?> typeNameToClass(TypeName typeName) {
        String typeNameStr = typeName.toString();
        return switch (typeNameStr) {
            case "java.lang.Boolean" -> Boolean.class;
            case "java.lang.Integer" -> Integer.class;
            case "java.lang.Long" -> Long.class;
            case "java.lang.Double" -> Double.class;
            case "java.lang.Character" -> Character.class;
            case "java.lang.String" -> String.class;
            default -> String.class; // Fallback for unknown types
        };
    }

    /**
     * Checks if an enum type is defined outside the base class hierarchy.
     * External enums require regular imports, while internal enums do not.
     */
    private boolean isEnumExternal(TypeMirror enumType) {
        if (baseType == null) {
            return true;
        }

        String enumQualifiedName = ParameterConversionUtils.getEnumQualifiedName(enumType);
        String baseQualifiedName = baseType.getQualifiedName().toString();

        // Check if enum is defined in the base class
        if (enumQualifiedName.startsWith(baseQualifiedName + ".")) {
            return false;
        }

        // Check superclass hierarchy
        TypeMirror superclass = baseType.getSuperclass();
        while (superclass != null && superclass.getKind() == javax.lang.model.type.TypeKind.DECLARED) {
            javax.lang.model.type.DeclaredType declaredSuperclass = (javax.lang.model.type.DeclaredType) superclass;
            TypeElement superclassElement = (TypeElement) declaredSuperclass.asElement();
            String superclassQualifiedName = superclassElement.getQualifiedName().toString();

            if (enumQualifiedName.startsWith(superclassQualifiedName + ".")) {
                return false;
            }

            superclass = superclassElement.getSuperclass();
        }

        return true;
    }

    /**
     * Extracts parameter class field types from data tables in the scenario steps.
     * Looks for the first step with a data table and finds its corresponding parameter class.
     *
     * @param scenarioSteps the list of steps in the scenario
     * @return a map of field name to TypeMirror, or null if no data table found
     */
    private Set<String> findColumnsUsedAsPlaceholders(List<Step> scenarioSteps) {
        Set<String> columnsUsedAsPlaceholders = new HashSet<>();

        if (scenarioSteps == null) {
            return columnsUsedAsPlaceholders;
        }

        // Pattern to match placeholders like <columnName>
        Pattern placeholderPattern = Pattern.compile("<([^>]+)>");

        for (Step step : scenarioSteps) {
            if (step.getDataTable().isEmpty()) {
                continue;
            }

            // Parse all cells in the data table
            DataTable dataTable = step.getDataTable().get();
            for (TableRow row : dataTable.getRows()) {
                for (TableCell cell : row.getCells()) {
                    String cellValue = cell.getValue();
                    Matcher matcher = placeholderPattern.matcher(cellValue);
                    while (matcher.find()) {
                        String columnName = matcher.group(1);
                        columnsUsedAsPlaceholders.add(columnName);
                    }
                }
            }
        }

        return columnsUsedAsPlaceholders;
    }

    private Map<String, TypeMirror> extractParameterClassFieldTypes(List<Step> scenarioSteps) {
        if (dataTableCollector == null || scenarioSteps == null) {
            return null;
        }

        // Find the first step with a data table
        for (Step step : scenarioSteps) {
            if (step.getDataTable().isEmpty()) {
                continue;
            }

            // Get the record name for this step
            String stepText = step.getKeyword() + step.getText();
            String recordName = dataTableCollector.deriveRecordNameFromStepText(stepText);

            // Get the record metadata
            RecordMetadata recordMetadata = dataTableCollector.getRecordMetadataMap().get(recordName);
            if (recordMetadata == null || !recordMetadata.hasExistingType()) {
                continue;
            }

            // Extract field types from the parameter class
            TypeElement parameterClass = recordMetadata.getExistingType();
            return ParameterConversionUtils.extractParameterClassFieldTypes(parameterClass, processingEnv);
        }

        return null;
    }

}
