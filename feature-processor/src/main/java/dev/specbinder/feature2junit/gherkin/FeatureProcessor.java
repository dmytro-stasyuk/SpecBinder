package dev.specbinder.feature2junit.gherkin;

import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import dev.specbinder.feature2junit.exception.ProcessingException;
import dev.specbinder.feature2junit.gherkin.utils.DataTableCollector;
import dev.specbinder.feature2junit.gherkin.utils.EnumImportCollector;
import dev.specbinder.feature2junit.support.BaseTypeSupport;
import dev.specbinder.feature2junit.support.LoggingSupport;
import dev.specbinder.feature2junit.support.OptionsSupport;
import dev.specbinder.feature2junit.utils.TagUtils;
import io.cucumber.messages.types.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.TypeElement;
import java.util.List;

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
                ruleProcessor.processRule(featureRuleCount, rule, classBuilder);
            }
            else if (child.getScenario().isPresent()) {

                Scenario scenario = child.getScenario().get();
                if (TagUtils.shouldSkipElement(scenario.getTags(), options.getSkipGenerationForTags())) {
                    continue;
                }
                featureScenarioCount++;
                ScenarioProcessor scenarioProcessor = new ScenarioProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);
                MethodSpec.Builder scenarioMethodBuilder = scenarioProcessor.processScenario(featureScenarioCount, scenario, classBuilder);

                MethodSpec scenarioMethod = scenarioMethodBuilder.build();
                classBuilder.addMethod(scenarioMethod);
            }
            else {
                throw new ProcessingException("Unsupported child element type for feature: " + child);
            }

        }
    }

}
