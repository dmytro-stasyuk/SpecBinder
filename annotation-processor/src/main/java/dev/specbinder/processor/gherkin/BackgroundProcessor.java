package dev.specbinder.processor.gherkin;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.gherkin.utils.DataTableCollector;
import dev.specbinder.processor.gherkin.utils.EnumImportCollector;
import dev.specbinder.processor.support.BaseTypeSupport;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.OptionsSupport;
import dev.specbinder.processor.utils.ElementMethodUtils;
import dev.specbinder.processor.utils.JavaDocUtils;
import io.cucumber.messages.types.Background;
import io.cucumber.messages.types.Step;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.TestInfo;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

class BackgroundProcessor implements LoggingSupport, OptionsSupport, BaseTypeSupport {

    private final ProcessingEnvironment processingEnv;
    private final GeneratorOptions options;
    private final TypeElement baseType;
    private final Set<String> baseClassMethodNames;
    private final DataTableCollector dataTableCollector;
    private final EnumImportCollector enumImportCollector;

    BackgroundProcessor(ProcessingEnvironment processingEnv, GeneratorOptions options, TypeElement baseType,
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


    MethodSpec.Builder processFeatureBackground(Background background, TypeSpec.Builder classBuilder) {

        return processBackground(background, classBuilder, "featureBackground");
    }

    MethodSpec.Builder processRuleBackground(Background background, TypeSpec.Builder classBuilder) {

        return processBackground(background, classBuilder, "ruleBackground");
    }

    private MethodSpec.Builder processBackground(
            Background background,
            TypeSpec.Builder classBuilder,
            String backgroundMethodName) {

        List<MethodSpec> allMethodSpecs = classBuilder.methodSpecs;

        List<Step> backgroundSteps = background.getSteps();
        List<MethodSpec> backgroundStepsMethodSpecs = new ArrayList<>(backgroundSteps.size());
        List<String> resolvedStepKeywords = new ArrayList<>(backgroundSteps.size());

        MethodSpec.Builder backgroundMethodBuilder = MethodSpec
                .methodBuilder(backgroundMethodName)
                .addModifiers(Modifier.PUBLIC);

        String description = background.getDescription();
        if (StringUtils.isNotBlank(description)) {
            description = JavaDocUtils.trimLeadingAndTrailingWhitespace(description);
            backgroundMethodBuilder.addJavadoc(description);
        }

        addJUnitAnnotations(backgroundMethodBuilder, background);

        backgroundMethodBuilder.addParameter(TestInfo.class, "testInfo");

        for (Step scenarioStep : backgroundSteps) {

            StepProcessor stepProcessor = new StepProcessor(processingEnv, options, dataTableCollector, enumImportCollector, baseType);
            MethodSpec stepMethodSpec = stepProcessor.processStep(scenarioStep, backgroundMethodBuilder, backgroundStepsMethodSpecs, resolvedStepKeywords);
            backgroundStepsMethodSpecs.add(stepMethodSpec);

            String stepMethodName = stepMethodSpec.name;
            MethodSpec existingMethodSpec =
                    allMethodSpecs.stream().filter(methodSpec -> methodSpec.name.equals(stepMethodName))
                            .findFirst()
                            .orElse(null);

            if (existingMethodSpec == null) {
                // Check if base class has a compatible method (not just by name, but by signature)
                boolean baseClassHasCompatibleMethod = stepProcessor.hasCompatibleBaseMethod(scenarioStep, null, backgroundStepsMethodSpecs);
                if (baseClassHasCompatibleMethod) {
                    logInfo("Skipping generation of method '" + stepMethodName + "', as base class already contains it");
                } else {
                    classBuilder.addMethod(stepMethodSpec);
                }
            }
        }

        return backgroundMethodBuilder;
    }

    private void addJUnitAnnotations(MethodSpec.Builder scenarioMethodBuilder, Background background) {

        String backgroundName = background.getName();
        String displayNameValue;
        if (StringUtils.isBlank(backgroundName)) {
            if (options.isAddSourceLineNumbers()) {
                displayNameValue = background.getKeyword() + " [" + background.getLocation().getLine() + "]:";
            } else {
                displayNameValue = background.getKeyword() + ":";
            }
        } else {
            backgroundName = backgroundName.replaceAll("\"", "\\\\\"");
            if (options.isAddSourceLineNumbers()) {
                displayNameValue = "Background [" + background.getLocation().getLine() + "]: " + backgroundName;
            } else {
                displayNameValue = "Background: " + backgroundName;
            }
        }
        AnnotationSpec displayNameAnnotation = AnnotationSpec
                .builder(DisplayName.class)
                .addMember("value", "\"" + displayNameValue + "\"")
                .build();

        AnnotationSpec testAnnotation = AnnotationSpec
                .builder(BeforeEach.class)
                .build();
        scenarioMethodBuilder
                .addAnnotation(testAnnotation)
                .addAnnotation(displayNameAnnotation);
    }

}
