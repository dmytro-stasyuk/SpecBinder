package dev.specbinder.feature2junit.gherkin;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import dev.specbinder.feature2junit.exception.ProcessingException;
import dev.specbinder.feature2junit.gherkin.utils.DataTableCollector;
import dev.specbinder.feature2junit.gherkin.utils.EnumImportCollector;
import dev.specbinder.feature2junit.gherkin.utils.RecordMetadata;
import dev.specbinder.feature2junit.support.BaseTypeSupport;
import dev.specbinder.feature2junit.support.LoggingSupport;
import dev.specbinder.feature2junit.support.OptionsSupport;
import dev.specbinder.feature2junit.utils.*;
import io.cucumber.messages.types.*;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

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

        String scenarioMethodName = "scenario_" + scenarioNumber;
        MethodSpec.Builder scenarioMethodBuilder = MethodSpec
                .methodBuilder(scenarioMethodName)
                //                .addParameter(TestInfo.class, "testInfo")
                .addModifiers(Modifier.PUBLIC);

        String description = scenario.getDescription();
        if (StringUtils.isNotBlank(description)) {
            description = JavaDocUtils.trimLeadingAndTrailingWhitespace(description);
            scenarioMethodBuilder.addJavadoc(description);
        }

        List<Examples> examples = scenario.getExamples();
        List<String> scenarioParameterNames;
        List<String> testMethodParameterNames;

        if (examples != null && !examples.isEmpty()) {

            scenarioParameterNames = addJUnitAnnotationsForParameterizedTest(scenarioMethodBuilder, scenario);
            testMethodParameterNames = new ArrayList<>(scenarioParameterNames.size());

            for (String scenarioParameterName : scenarioParameterNames) {
                String methodParameterName = ParameterNamingUtils.toMethodParameterName(scenarioParameterName);
                testMethodParameterNames.add(methodParameterName);
                scenarioMethodBuilder.addParameter(String.class, methodParameterName);
            }
        } else {
            scenarioParameterNames = null;
            testMethodParameterNames = null;

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
            String tagForEmptyScenarios = options.getTagForScenariosWithNoSteps();
            if (StringUtils.isNotBlank(tagForEmptyScenarios)) {
                AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tagForEmptyScenarios);
                scenarioMethodBuilder.addAnnotation(jUnitTagsAnnotation);
            }
        }

        if (options.isAddSourceLineAnnotations()) {
            AnnotationSpec locationAnnotation = LocationUtils.toJUnitTagsAnnotation(scenario.getLocation());
            scenarioMethodBuilder.addAnnotation(locationAnnotation);
        }

        addDisplayNameAnnotation(scenarioMethodBuilder, scenario);

        if (scenarioSteps.isEmpty()) {

            if (options.isFailScenariosWithNoSteps()) {
                /**
                 * add an empty method that throws an exception
                 */
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
                                classBuilder, allMethodSpecs, baseClassMethodNames,
                                scenarioParameterNames, testMethodParameterNames
                        );
                    } else if (item instanceof Step regularStep) {
                        // Process regular step
                        StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);
                        MethodSpec stepMethodSpec = stepProcessor.processStep(
                                regularStep, scenarioMethodBuilder, scenarioStepsMethodSpecs,
                                scenarioParameterNames, testMethodParameterNames
                        );
                        scenarioStepsMethodSpecs.add(stepMethodSpec);

                        String stepMethodName = stepMethodSpec.name;
                        MethodSpec existingMethodSpec =
                                allMethodSpecs.stream().filter(methodSpec -> methodSpec.name.equals(stepMethodName))
                                        .findFirst()
                                        .orElse(null);

                        if (existingMethodSpec == null) {
                            // Check if base class has a compatible method (not just by name, but by signature)
                            boolean baseClassHasCompatibleMethod = stepProcessor.hasCompatibleBaseMethod(regularStep, scenarioParameterNames, scenarioStepsMethodSpecs);
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
                            scenarioParameterNames, testMethodParameterNames
                    );
                    scenarioStepsMethodSpecs.add(stepMethodSpec);

                    String stepMethodName = stepMethodSpec.name;
                    MethodSpec existingMethodSpec =
                            allMethodSpecs.stream().filter(methodSpec -> methodSpec.name.equals(stepMethodName))
                                    .findFirst()
                                    .orElse(null);

                    if (existingMethodSpec == null) {
                        // Check if base class has a compatible method (not just by name, but by signature)
                        boolean baseClassHasCompatibleMethod = stepProcessor.hasCompatibleBaseMethod(scenarioStep, scenarioParameterNames, scenarioStepsMethodSpecs);
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
        AnnotationSpec displayNameAnnotation = AnnotationSpec
                .builder(DisplayName.class)
                .addMember("value", "\"" + scenarioKeyword + ":" + scenarioName + "\"")
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
                textBlockSB.append(rowLine);
                textBlockSB.append("\n");
            }

            textBlockSB.append("\"\"\"");

            String textBlock = textBlockSB.toString();

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

}
