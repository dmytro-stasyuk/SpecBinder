package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.ClassName;
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
import dev.specbinder.processor.utils.JavaDocUtils;
import dev.specbinder.processor.utils.TagUtils;
import io.cucumber.messages.types.*;
import io.cucumber.messages.types.Tag;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import java.util.List;
import java.util.Map;

@SuppressWarnings({"LombokGetterMayBeUsed", "ClassCanBeRecord"})
class RuleProcessor implements LoggingSupport, OptionsSupport, BaseTypeSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final TypeElement baseType;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;

    public RuleProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options, TypeElement baseType,
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

    void processRule(int ruleNumber, Rule rule, TypeSpec.Builder classBuilder, Map<String, List<Class<?>>> preComputedStepTypes, List<Step> featureBackgroundSteps) {

        List<Step> ruleBackgroundSteps = BackgroundStepCollector.collectRuleBackgroundSteps(rule);
        List<Step> combinedBackgroundSteps = BackgroundStepCollector.combine(featureBackgroundSteps, ruleBackgroundSteps);

        TypeSpec.Builder nestedRuleClassBuilder = TypeSpec
                .classBuilder("Rule_" + ruleNumber)
                .addModifiers(Modifier.PUBLIC);

        String description = rule.getDescription();
        if (StringUtils.isNotBlank(description)) {
            description = JavaDocUtils.trimLeadingAndTrailingWhitespace(description);
            nestedRuleClassBuilder.addJavadoc(JavaDocUtils.escapeForJavaPoet(description));
        }

        /*
          add {@link org.junit.jupiter.api.Nested} annotation
         */
        nestedRuleClassBuilder.addAnnotation(
                AnnotationSpec.builder(Nested.class).build()
        );

        /*
          add {@link Order} annotation
         */
        AnnotationSpec orderAnnotation = AnnotationSpec
                .builder(Order.class)
                .addMember("value", "" + ruleNumber)
                .build();
        nestedRuleClassBuilder.addAnnotation(orderAnnotation);

        List<RuleChild> children = rule.getChildren();

        boolean hasScenarios = children.stream().anyMatch(child ->
                child.getScenario().isPresent() &&
                !TagUtils.shouldSkipElement(child.getScenario().get().getTags(), options.getSkipGenerationForTags()));

        /*
          add {@link Tag} annotations from Gherkin tags
         */
        List<Tag> tags = rule.getTags();
        if (tags != null && !tags.isEmpty()) {
            AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tags);
            nestedRuleClassBuilder.addAnnotation(jUnitTagsAnnotation);
        }

        /*
          add empty rule tag to the Rule class when the rule has no scenarios
         */
        if (!hasScenarios) {
            String tagForEmptyRules = options.getTagForEmptyRules();
            if (StringUtils.isNotBlank(tagForEmptyRules)) {
                AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tagForEmptyRules);
                nestedRuleClassBuilder.addAnnotation(jUnitTagsAnnotation);
            }
        }

        /*
          add {@link TestMethodOrder} annotation
         */
        nestedRuleClassBuilder.addAnnotation(AnnotationSpec
                .builder(TestMethodOrder.class)
                .addMember("value", "$T.class", ClassName.get(MethodOrderer.OrderAnnotation.class))
                .build()
        );

        /*
          add {@link DisplayName} annotation
         */
        String ruleName = rule.getName();
        if (ruleName != null) {
            ruleName = ruleName.replaceAll("\"", "\\\\\"");
            if (!ruleName.isEmpty()) {
                ruleName = " " + ruleName;
            }
        }
        String displayNameValue;
        if (options.isAddSourceLineNumbers()) {
            long line = rule.getLocation().getLine();
            displayNameValue = "Rule [" + line + "]:" + ruleName;
        } else {
            displayNameValue = "Rule:" + ruleName;
        }
        nestedRuleClassBuilder.addAnnotation(
                AnnotationSpec.builder(DisplayName.class)
                        .addMember("value", "\"" + JavaDocUtils.escapeForJavaPoet(displayNameValue) + "\"")
                        .build()
        );

        int ruleScenarioCount = 0;

        for (RuleChild child : children) {

            if (child.getScenario().isPresent()) {

                Scenario scenario = child.getScenario().get();

                if (TagUtils.shouldSkipElement(scenario.getTags(), options.getSkipGenerationForTags())) {
                    continue;
                }

                ruleScenarioCount++;
                ScenarioProcessor scenarioProcessor = new ScenarioProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector, combinedBackgroundSteps);
                String rulePrefix = "rule_" + ruleNumber + "_";
                MethodSpec.Builder scenarioMethodBuilder = scenarioProcessor.processScenario(rulePrefix, ruleScenarioCount, scenario, classBuilder, preComputedStepTypes);

                MethodSpec scenarioMethod = scenarioMethodBuilder.build();
                nestedRuleClassBuilder.addMethod(scenarioMethod);

            } else if (child.getBackground().isPresent()) {

                Background background = child.getBackground().get();

                BackgroundProcessor backgroundProcessor = new BackgroundProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);
                MethodSpec.Builder ruleBackgroundMethodBuilder = backgroundProcessor.processRuleBackground(background, classBuilder);

                MethodSpec backgroundMethod = ruleBackgroundMethodBuilder.build();
                nestedRuleClassBuilder.addMethod(backgroundMethod);
            } else {
                throw new ProcessingException("Unsupported rule child type: " + child);
            }
        }

        if (!hasScenarios) {
            /*
              If there are no scenarios in the rule, add a test method that either fails or is skipped,
              depending on the emptyRuleBehavior option.
             */
            MethodSpec.Builder noScenariosInRuleMSB = MethodSpec
                    .methodBuilder("noScenariosInRule")
                    .addModifiers(Modifier.PUBLIC);

            if ("SKIP".equals(options.getEmptyRuleBehavior())) {
                noScenariosInRuleMSB.addStatement("$T.assumeTrue(false, \"Rule has no scenarios\")", Assumptions.class);
            } else if ("COMPILATION_ERROR".equals(options.getEmptyRuleBehavior())) {
                noScenariosInRuleMSB.addCode("Rule doesn't have any scenarios\n");
            } else {
                noScenariosInRuleMSB.addStatement("$T.fail(\"Rule doesn't have any scenarios\")", Assertions.class);
            }

            AnnotationSpec testAnnotation = AnnotationSpec
                    .builder(Test.class)
                    .build();
            noScenariosInRuleMSB.addAnnotation(testAnnotation);

            MethodSpec noScenariosInRule = noScenariosInRuleMSB.build();
            nestedRuleClassBuilder.addMethod(noScenariosInRule);
        }

        TypeSpec nestedRuleClassSpec = nestedRuleClassBuilder.build();
        classBuilder.addType(nestedRuleClassSpec);
    }

}
