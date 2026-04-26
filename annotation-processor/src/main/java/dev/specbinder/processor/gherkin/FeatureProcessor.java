package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.gherkin.utils.BackgroundStepCollector;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.support.BaseTypeSupport;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.ParameterConversionUtils;
import dev.specbinder.processor.utils.TagUtils;
import io.cucumber.messages.types.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.TypeElement;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Processes a Gherkin feature and generates corresponding JUnit test methods.
 */
@SuppressWarnings("LombokGetterMayBeUsed")
public class FeatureProcessor implements LoggingSupport, OptionsSupport, BaseTypeSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final TypeElement baseType;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;

    /**
     * Constructs a FeatureProcessor with the given processing environment, options, and base type.
     *
     * @param processingEnv the processing environment
     * @param options the generator options
     * @param baseType the base type element
     * @param dataTableCollector the data table collector for LIST_OF_OBJECT_PARAMS option (may be null)
     * @param enumImportCollector the enum import collector for static imports (may be null)
     */
    public FeatureProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options, TypeElement baseType,
                            DataTableCollector dataTableCollector, EnumImportCollector enumImportCollector) {
        this.processingEnv = processingEnv;
        this.options = options;
        this.baseType = baseType;
        this.dataTableCollector = dataTableCollector;
        this.enumImportCollector = enumImportCollector;
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

    /**
     * Processes a Gherkin feature and generates JUnit test methods for its children.
     * @param feature the Gherkin feature to process
     * @param classBuilder the TypeSpec.Builder for the class being generated
     */
    public void processFeature(Feature feature, TypeSpec.Builder classBuilder) {

        // Skip all children if the Feature itself has a matching skip tag
        if (TagUtils.shouldSkipElement(feature.getTags(), options.getSkipGenerationForTags())) {
            return;
        }

        // Pre-scan all steps to compute widened parameter types across all occurrences
        Map<String, List<Class<?>>> preComputedStepTypes = preComputeStepParameterTypes(feature);

        // Pre-collect feature-level Background steps for scenario-hash assembly. Empty list when
        // emitScenarioHash is off — collection is cheap and unused branches are pruned downstream.
        List<Step> featureBackgroundSteps = BackgroundStepCollector.collectFeatureBackgroundSteps(feature);

        List<FeatureChild> children = feature.getChildren();

        int featureRuleCount = 0;
        int featureScenarioCount = 0;

        for (FeatureChild child : children) {

            if (child.getBackground().isPresent()) {

                BackgroundProcessor backgroundProcessor = new BackgroundProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);

                Background background = child.getBackground().get();
                MethodSpec.Builder featureBackgroundMethodBuilder = backgroundProcessor.processFeatureBackground(background, classBuilder);

                MethodSpec backgroundMethod = featureBackgroundMethodBuilder.build();
                classBuilder.addMethod(backgroundMethod);
            }
            else if (child.getRule().isPresent()) {

                Rule rule = child.getRule().get();
                if (TagUtils.shouldSkipElement(rule.getTags(), options.getSkipGenerationForTags())) {
                    continue;
                }
                featureRuleCount++;
                RuleProcessor ruleProcessor = new RuleProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);
                ruleProcessor.processRule(featureRuleCount, rule, classBuilder, preComputedStepTypes, featureBackgroundSteps);
            }
            else if (child.getScenario().isPresent()) {

                Scenario scenario = child.getScenario().get();
                if (TagUtils.shouldSkipElement(scenario.getTags(), options.getSkipGenerationForTags())) {
                    continue;
                }
                featureScenarioCount++;
                ScenarioProcessor scenarioProcessor = new ScenarioProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector, featureBackgroundSteps);
                MethodSpec.Builder scenarioMethodBuilder = scenarioProcessor.processScenario("", featureScenarioCount, scenario, classBuilder, preComputedStepTypes);

                MethodSpec scenarioMethod = scenarioMethodBuilder.build();
                classBuilder.addMethod(scenarioMethod);
            }
            else {
                throw new ProcessingException("Unsupported child element type for feature: " + child);
            }

        }
    }

    private static final Pattern PARAM_PATTERN = Pattern.compile("(?<parameter>(\")(?<parameterValue>[^\"]+?)(\"))");

    /**
     * Pre-scans all steps across all scenarios in the feature to determine widened parameter types.
     * When the same step pattern appears multiple times with different parameter values,
     * the widest common type is computed (e.g., Character + String → String).
     */
    private Map<String, List<Class<?>>> preComputeStepParameterTypes(Feature feature) {
        // Collect parameter values grouped by step pattern
        Map<String, List<List<String>>> stepPatternValues = new LinkedHashMap<>();

        for (FeatureChild child : feature.getChildren()) {
            if (child.getScenario().isPresent()) {
                collectStepPatternValues(child.getScenario().get().getSteps(), stepPatternValues);
            }
            if (child.getRule().isPresent()) {
                for (RuleChild ruleChild : child.getRule().get().getChildren()) {
                    if (ruleChild.getScenario().isPresent()) {
                        collectStepPatternValues(ruleChild.getScenario().get().getSteps(), stepPatternValues);
                    }
                    if (ruleChild.getBackground().isPresent()) {
                        collectStepPatternValues(ruleChild.getBackground().get().getSteps(), stepPatternValues);
                    }
                }
            }
            if (child.getBackground().isPresent()) {
                collectStepPatternValues(child.getBackground().get().getSteps(), stepPatternValues);
            }
        }

        // For patterns with multiple occurrences, compute widened types
        Map<String, List<Class<?>>> result = new HashMap<>();
        for (Map.Entry<String, List<List<String>>> entry : stepPatternValues.entrySet()) {
            List<List<String>> allOccurrences = entry.getValue();
            if (allOccurrences.size() <= 1) {
                continue; // Single occurrence - no widening needed
            }

            int paramCount = allOccurrences.get(0).size();
            List<Class<?>> widenedTypes = new ArrayList<>(paramCount);
            for (int i = 0; i < paramCount; i++) {
                List<String> valuesAtPosition = new ArrayList<>();
                for (List<String> occurrence : allOccurrences) {
                    if (i < occurrence.size()) {
                        String val = occurrence.get(i);
                        // Skip scenario outline placeholders
                        if (!(val.startsWith("<") && val.endsWith(">"))) {
                            valuesAtPosition.add(val);
                        }
                    }
                }
                widenedTypes.add(ParameterConversionUtils.inferTypeForAllValues(valuesAtPosition));
            }
            result.put(entry.getKey(), widenedTypes);
        }

        return result;
    }

    private void collectStepPatternValues(List<Step> steps, Map<String, List<List<String>>> stepPatternValues) {
        for (Step step : steps) {
            String stepText = step.getKeyword() + " " + step.getText();
            String stepFirstLine = stepText.trim().split("\\n")[0].trim();

            List<String> parameterValues = new ArrayList<>();
            String pattern = extractPattern(stepFirstLine, parameterValues);

            if (!parameterValues.isEmpty()) {
                stepPatternValues.computeIfAbsent(pattern, k -> new ArrayList<>()).add(parameterValues);
            }
        }
    }

    private String extractPattern(String stepFirstLine, List<String> parameterValues) {
        StringBuilder patternBuilder = new StringBuilder();
        Matcher matcher = PARAM_PATTERN.matcher(stepFirstLine);
        int lastEnd = 0;

        while (matcher.find()) {
            patternBuilder.append(stepFirstLine, lastEnd, matcher.start("parameter"));
            patternBuilder.append("$p").append(parameterValues.size() + 1);
            parameterValues.add(matcher.group("parameterValue"));
            lastEnd = matcher.end("parameter");
        }

        if (lastEnd < stepFirstLine.length()) {
            patternBuilder.append(stepFirstLine.substring(lastEnd));
        }

        return patternBuilder.toString();
    }

}
