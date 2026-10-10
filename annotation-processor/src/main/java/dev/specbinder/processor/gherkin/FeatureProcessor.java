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
import dev.specbinder.processor.utils.DescriptionEmitter;
import dev.specbinder.processor.utils.JavaDocUtils;
import dev.specbinder.processor.utils.ParameterConversionUtils;
import dev.specbinder.processor.utils.TagUtils;
import io.cucumber.messages.types.*;
import io.cucumber.messages.types.Tag;
import org.apache.commons.lang3.StringUtils;
import org.junit.jupiter.api.*;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Modifier;
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
        Map<String, List<Class<?>>> preComputedStepTypes = preComputeStepParameterTypes(List.of(feature));

        processFeatureChildren(feature, classBuilder, classBuilder, "", "", preComputedStepTypes);
    }

    /**
     * Processes the specs of a spec file holding several of them. Each spec becomes a nested class named after its
     * keyword and its position in the file (e.g. {@code Business_Need_2}), while the step methods of all specs are
     * shared on the generated class. A spec carrying a matching skip tag produces no nested class, and the other
     * specs keep their position numbers.
     *
     * @param specs        the specs of the file, in file order
     * @param classBuilder the TypeSpec.Builder for the class being generated
     */
    public void processSpecs(List<Feature> specs, TypeSpec.Builder classBuilder) {

        List<Feature> generatedSpecs = specs.stream()
                .filter(spec -> !TagUtils.shouldSkipElement(spec.getTags(), options.getSkipGenerationForTags()))
                .toList();

        // Step methods are shared by all specs, so parameter types are widened across all of them
        Map<String, List<Class<?>>> preComputedStepTypes = preComputeStepParameterTypes(generatedSpecs);

        for (int i = 0; i < specs.size(); i++) {
            Feature spec = specs.get(i);
            if (!generatedSpecs.contains(spec)) {
                continue;
            }
            int specNumber = i + 1;
            String keyword = spec.getKeyword().trim();
            String specClassName = SpecNamingUtils.toIdentifier(keyword) + "_" + specNumber;

            TypeSpec.Builder specClassBuilder = TypeSpec
                    .classBuilder(specClassName)
                    .addModifiers(Modifier.PUBLIC);

            boolean hasRules = spec.getChildren().stream().anyMatch(child -> child.getRule().isPresent());
            boolean hasScenarios = spec.getChildren().stream().anyMatch(child -> child.getScenario().isPresent());
            boolean isEmpty = !hasRules && !hasScenarios;

            addSpecClassAnnotations(spec, specNumber, hasRules, hasScenarios, isEmpty, specClassBuilder);

            String methodNamePrefix = specClassName.toLowerCase(Locale.ROOT) + "_";
            processFeatureChildren(spec, classBuilder, specClassBuilder, specClassName + "_", methodNamePrefix,
                    preComputedStepTypes);

            if (isEmpty) {
                specClassBuilder.addMethod(noScenariosInSpecMethod(keyword));
            }

            classBuilder.addType(specClassBuilder.build());
        }
    }

    /**
     * Generates the children of a feature: its Background, Rules and Scenarios.
     *
     * @param classBuilder       the generated top-level class, which receives the step methods
     * @param targetClassBuilder the class receiving the Background method, Scenario methods and Rule classes
     * @param classNamePrefix    prefix for nested Rule class names ("" for a single-spec file)
     * @param methodNamePrefix   prefix for scenario method names ("" for a single-spec file)
     */
    private void processFeatureChildren(Feature feature, TypeSpec.Builder classBuilder,
                                        TypeSpec.Builder targetClassBuilder, String classNamePrefix,
                                        String methodNamePrefix, Map<String, List<Class<?>>> preComputedStepTypes) {

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
                targetClassBuilder.addMethod(backgroundMethod);
            }
            else if (child.getRule().isPresent()) {

                Rule rule = child.getRule().get();
                boolean ruleSkipped = TagUtils.shouldSkipElement(rule.getTags(), options.getSkipGenerationForTags());
                featureRuleCount++;
                RuleProcessor ruleProcessor = new RuleProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector);
                ruleProcessor.processRule(featureRuleCount, rule, classBuilder, targetClassBuilder, classNamePrefix,
                        methodNamePrefix, preComputedStepTypes, featureBackgroundSteps, ruleSkipped);
            }
            else if (child.getScenario().isPresent()) {

                Scenario scenario = child.getScenario().get();
                boolean scenarioSkipped = TagUtils.shouldSkipElement(scenario.getTags(), options.getSkipGenerationForTags());
                featureScenarioCount++;
                ScenarioProcessor scenarioProcessor = new ScenarioProcessor(processingEnv, options, baseType, dataTableCollector, enumImportCollector, featureBackgroundSteps);
                MethodSpec.Builder scenarioMethodBuilder = scenarioProcessor.processScenario(methodNamePrefix, featureScenarioCount, scenario, classBuilder, preComputedStepTypes, scenarioSkipped);

                MethodSpec scenarioMethod = scenarioMethodBuilder.build();
                targetClassBuilder.addMethod(scenarioMethod);
            }
            else {
                throw new ProcessingException("Unsupported child element type for feature: " + child);
            }

        }
    }

    private void addSpecClassAnnotations(Feature spec, int specNumber, boolean hasRules, boolean hasScenarios,
                                         boolean isEmpty, TypeSpec.Builder specClassBuilder) {

        specClassBuilder.addAnnotation(AnnotationSpec.builder(Nested.class).build());
        specClassBuilder.addAnnotation(AnnotationSpec
                .builder(Order.class)
                .addMember("value", "" + specNumber)
                .build());

        List<Tag> tags = spec.getTags();
        if (tags != null && !tags.isEmpty()) {
            specClassBuilder.addAnnotation(TagUtils.toJUnitTagsAnnotation(tags));
        }

        if (isEmpty && StringUtils.isNotBlank(options.getTagForEmptySpecs())) {
            specClassBuilder.addAnnotation(TagUtils.toJUnitTagsAnnotation(options.getTagForEmptySpecs()));
        }

        if (hasScenarios || isEmpty) {
            specClassBuilder.addAnnotation(AnnotationSpec
                    .builder(TestMethodOrder.class)
                    .addMember("value", "$T.class", ClassName.get(MethodOrderer.OrderAnnotation.class))
                    .build());
        }
        if (hasRules) {
            specClassBuilder.addAnnotation(AnnotationSpec
                    .builder(TestClassOrder.class)
                    .addMember("value", "$T.class", ClassName.get(ClassOrderer.OrderAnnotation.class))
                    .build());
        }

        String specName = spec.getName();
        if (specName != null && !specName.isEmpty()) {
            specName = " " + specName.replaceAll("\"", "\\\\\"");
        } else {
            specName = "";
        }
        String keyword = spec.getKeyword().trim();
        String displayNameValue;
        if (options.isAddSourceLineNumbers()) {
            long line = spec.getLocation().getLine();
            displayNameValue = keyword + " [" + line + "]:" + specName;
        } else {
            displayNameValue = keyword + ":" + specName;
        }
        specClassBuilder.addAnnotation(AnnotationSpec
                .builder(DisplayName.class)
                .addMember("value", "\"" + JavaDocUtils.escapeForJavaPoet(displayNameValue) + "\"")
                .build());

        DescriptionEmitter.emit(specClassBuilder, spec.getDescription(), options);
    }

    /**
     * The placeholder test of a spec without Scenarios or Rules, which fails, aborts or does not compile,
     * depending on the emptySpecBehavior option.
     */
    private MethodSpec noScenariosInSpecMethod(String keyword) {

        MethodSpec.Builder methodBuilder = MethodSpec
                .methodBuilder("noScenariosIn" + SpecNamingUtils.toIdentifier(keyword).replace("_", ""))
                .addModifiers(Modifier.PUBLIC)
                .addAnnotation(AnnotationSpec.builder(Test.class).build());

        if ("ABORT".equals(options.getEmptySpecBehavior())) {
            methodBuilder.addStatement("$T.assumeTrue(false, $S)", Assumptions.class, keyword + " has no scenarios");
        } else if ("COMPILATION_ERROR".equals(options.getEmptySpecBehavior())) {
            methodBuilder.addCode((keyword + " doesn't have any scenarios\n").replace("$", "$$"));
        } else {
            methodBuilder.addStatement("$T.fail($S)", Assertions.class, keyword + " doesn't have any scenarios");
        }

        return methodBuilder.build();
    }

    private static final Pattern PARAM_PATTERN = Pattern.compile("(?<parameter>(\")(?<parameterValue>[^\"]*?)(\"))");

    /**
     * Pre-scans all steps across all scenarios of the given features to determine widened parameter types.
     * When the same step pattern appears multiple times with different parameter values,
     * the widest common type is computed (e.g., Character + String → String).
     */
    private Map<String, List<Class<?>>> preComputeStepParameterTypes(List<Feature> features) {
        // Collect parameter values grouped by step pattern
        Map<String, List<List<String>>> stepPatternValues = new LinkedHashMap<>();

        for (FeatureChild child : features.stream().flatMap(feature -> feature.getChildren().stream()).toList()) {
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
