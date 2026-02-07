package dev.specbinder.feature2junit.gherkin;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.ClassName;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import dev.specbinder.feature2junit.exception.ProcessingException;
import dev.specbinder.feature2junit.support.BaseTypeSupport;
import dev.specbinder.feature2junit.support.LoggingSupport;
import dev.specbinder.feature2junit.support.OptionsSupport;
import dev.specbinder.feature2junit.gherkin.utils.DataTableCollector;
import dev.specbinder.feature2junit.gherkin.utils.EnumImportCollector;
import dev.specbinder.feature2junit.utils.JavaDocUtils;
import dev.specbinder.feature2junit.utils.LocationUtils;
import dev.specbinder.feature2junit.utils.TagUtils;
import io.cucumber.messages.types.*;
import io.cucumber.messages.types.Tag;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import java.util.List;

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

    void processRule(int ruleNumber, Rule rule, TypeSpec.Builder classBuilder) {

        TypeSpec.Builder nestedRuleClassBuilder = TypeSpec
                .classBuilder("Rule_" + ruleNumber)
                .addModifiers(Modifier.PUBLIC);

        String description = rule.getDescription();
        if (StringUtils.isNotBlank(description)) {
            description = JavaDocUtils.trimLeadingAndTrailingWhitespace(description);
            nestedRuleClassBuilder.addJavadoc(description);
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
        /*
          add {@link TestMethodOrder} annotation
         */
        nestedRuleClassBuilder.addAnnotation(AnnotationSpec
                .builder(TestMethodOrder.class)
                .addMember("value", "$T.class", ClassName.get(MethodOrderer.OrderAnnotation.class))
                .build()
        );

        /*
          add {@link Tag} annotations
         */
        List<Tag> tags = rule.getTags();
        if (tags != null && !tags.isEmpty()) {
            AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tags);
            nestedRuleClassBuilder.addAnnotation(jUnitTagsAnnotation);
        }

        /*
          add {@link SourceLine} annotation
         */
        if (options.isAddSourceLineAnnotations()) {
            AnnotationSpec locationAnnotation = LocationUtils.toJUnitTagsAnnotation(rule.getLocation());
            nestedRuleClassBuilder.addAnnotation(locationAnnotation);
        }

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
        nestedRuleClassBuilder.addAnnotation(
                AnnotationSpec.builder(DisplayName.class)
                        .addMember("value", "\"Rule:" + ruleName + "\"")
                        .build()
        );

        List<RuleChild> children = rule.getChildren();

        int ruleScenarioCount = 0;

        boolean hasScenarios = false;
        for (RuleChild child : children) {

            if (child.getScenario().isPresent()) {

                Scenario scenario = child.getScenario().get();

                ruleScenarioCount++;
                ScenarioProcessor scenarioProcessor = new ScenarioProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);
                MethodSpec.Builder scenarioMethodBuilder = scenarioProcessor.processScenario(ruleScenarioCount, scenario, classBuilder);

                MethodSpec scenarioMethod = scenarioMethodBuilder.build();
                nestedRuleClassBuilder.addMethod(scenarioMethod);

                hasScenarios = true;

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

        if (!hasScenarios && options.isFailRulesWithNoScenarios()) {
            /*
              If there are no scenarios in the rule, we add an empty method that throws an exception.
             */
            MethodSpec.Builder noScenariosInRuleMSB = MethodSpec
                    .methodBuilder("noScenariosInRule")
                    .addModifiers(Modifier.PUBLIC);
            noScenariosInRuleMSB.addStatement("$T.assumeTrue(false, \"Rule has no scenarios\")", Assumptions.class);

            AnnotationSpec testAnnotation = AnnotationSpec
                    .builder(Test.class)
                    .build();
            noScenariosInRuleMSB.addAnnotation(testAnnotation);

            String tagForEmptyRules = options.getTagForRulesWithNoScenarios();
            if (StringUtils.isNotBlank(tagForEmptyRules)) {
                /*
                  add JUnit Tag annotation
                 */
                AnnotationSpec jUnitTagsAnnotation = TagUtils.toJUnitTagsAnnotation(tagForEmptyRules);
                noScenariosInRuleMSB.addAnnotation(jUnitTagsAnnotation);
            }

            MethodSpec noScenariosInRule = noScenariosInRuleMSB.build();
            nestedRuleClassBuilder.addMethod(noScenariosInRule);
        }

        TypeSpec nestedRuleClassSpec = nestedRuleClassBuilder.build();
        classBuilder.addType(nestedRuleClassSpec);
    }

}
