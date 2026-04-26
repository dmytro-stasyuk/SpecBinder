package dev.specbinder.processor.config;

import dev.specbinder.annotations.Gherkin2JUnitOptions.Verbosity;
import lombok.Getter;

import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;
import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.FAIL;

/**
 * Options for the generator that can be used to customize the generated test classes.
 */
@Getter
public class GeneratorOptions {

    /**
     * If set to true, the generated test class will be abstract and will have abstract step methods that need to be
     * implemented. If set to false, the generated test class will be concrete and will include step method bodies
     * with failing assertions for all methods required for the feature file to run. To implement those step test
     * methods - move them to the superclass and add appropriate code in the method body.
     */
    private final boolean shouldBeAbstract;

    /**
     * Suffix that will be used for the name of the generated test class if it is concrete.
     */
    private final String classSuffixIfConcrete;

    /**
     * Suffix that will be used for the name of the generated test class if it is abstract.
     */
    private final String classSuffixIfAbstract;

    /**
     * If set to true, the generator will embed source line numbers from the feature file into
     * {@code @DisplayName} annotations and step block comments in the generated test code.
     */
    private final boolean addSourceLineNumbers;

    /**
     * Controls how the generator handles Scenarios that contain no steps.
     * Valid values: "FAIL", "SKIP", "COMPILATION_ERROR"
     */
    private final String emptyScenarioBehavior;

    /**
     * Controls how the generator handles Rules that contain no Scenarios.
     * Valid values: "FAIL", "SKIP", "COMPILATION_ERROR"
     */
    private final String emptyRuleBehavior;

    /**
     * Controls the body of generated step method stubs when shouldBeAbstract is false.
     * Valid values: "FAIL", "SKIP", "COMPILATION_ERROR"
     */
    private final String unimplementedStepBehavior;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to scenarios that do not
     * contain any steps. If an empty or blank value is specified, no tag will be added.
     */
    private final String tagForEmptyScenarios;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to failing test method
     * that was added for rules that do not contain any scenarios.
     * If an empty or blank value is specified, no tag will be added.
     */
    private final String tagForEmptyRules;

    /**
     * If set to true, the generator will add Cucumber step annotations (e.g. @Given, @When, @Then) to the generated
     * step methods. This can be useful inside IDEs with installed Cucumber/Gherkin plugins to facilitate navigation
     * from textual steps in Gherkin feature file to step method java code.
     */
    private boolean addCucumberStepAnnotations;

    /**
     * If set to true, the generated class source file will be placed next to the annotated class instead of
     * the default location for generated sources.
     */
    private boolean placeGeneratedClassNextToAnnotatedClass;

    /**
     * The style of parameters to use for step methods with data tables.
     * Valid values: "LIST_OF_MAPS", "CUCUMBER_DATA_TABLE", "LIST_OF_OBJECT_PARAMS"
     */
    private final String dataTableParameterType;

    /**
     * If set to true, enables composite step pattern where Given/When/Then/And/But steps followed by '*' steps
     * generate composite methods with lambda parameters.
     */
    private final boolean enableCompositeSteps;

    /**
     * If set to true, enum constants will be referenced with their type qualifier (e.g., Status.AVAILABLE)
     * instead of using static imports and simple names (e.g., AVAILABLE).
     */
    private final boolean useQualifiedEnumConstants;

    /**
     * Controls whether the Gherkin step keyword (Given, When, Then) is included as a prefix
     * in generated step method names.
     */
    private final boolean useStepKeywordInStepMethodName;

    /**
     * Controls whether Cucumber step annotations (@Given, @When, @Then) on methods in the class hierarchy
     * are used to match steps from the feature file to existing method implementations.
     */
    private final boolean useCucumberAnnotationsForStepMatching;

    /**
     * The file extensions that the processor recognizes as Gherkin specification files.
     * Extensions are stored without the leading dot (e.g., "feature", "specb").
     */
    private final String[] supportedFileExtensions;

    /**
     * Regex patterns for Gherkin tags for which the generator should skip code generation entirely.
     * Each value is treated as a Java regular expression matched against tag names (without the leading @).
     */
    private final String[] skipGenerationForTags;

    /**
     * The verbosity level that controls how much detail SpecBinder writes to the build log
     * during annotation processing for this annotated class.
     */
    private final Verbosity verbosity;

    /**
     * If set to true, the generator emits a {@code @ScenarioHash} annotation on each generated
     * {@code @Test} / {@code @ParameterizedTest} method, carrying the canonical SHA-256 hash of
     * the scenario's executable content. Consumed downstream by the execution-reporter (which
     * copies the hash into JSON output) and the IntelliJ plugin (which uses it to drive
     * staleness-aware gutter icons).
     */
    private final boolean emitScenarioHash;

    /**
     * Default options
     */
    public GeneratorOptions() {
        this.shouldBeAbstract = false;
        this.classSuffixIfConcrete = "Test";
        this.classSuffixIfAbstract = "Scenarios";
        this.addSourceLineNumbers = false;
        this.emptyScenarioBehavior = FAIL.name();
        this.emptyRuleBehavior = FAIL.name();
        this.unimplementedStepBehavior = FAIL.name();
        this.tagForEmptyScenarios = "new";
        this.tagForEmptyRules = "new";
        this.addCucumberStepAnnotations = false;
        this.placeGeneratedClassNextToAnnotatedClass = false;
        this.dataTableParameterType = LIST_OF_OBJECT_PARAMS.name();
        this.enableCompositeSteps = false;
        this.useQualifiedEnumConstants = false;
        this.useStepKeywordInStepMethodName = false;
        this.useCucumberAnnotationsForStepMatching = true;
        this.supportedFileExtensions = new String[]{"feature", "specb"};
        this.skipGenerationForTags = new String[]{};
        this.verbosity = Verbosity.NORMAL;
        this.emitScenarioHash = false;
    }

    /**
     * Custom options
     *
     * @param shouldBeAbstract             see {@link #shouldBeAbstract}
     * @param classSuffixIfConcrete        see {@link #classSuffixIfConcrete}
     * @param classSuffixIfAbstract        see {@link #classSuffixIfAbstract}
     * @param addSourceLineNumbers         see {@link #addSourceLineNumbers}
     * @param emptyScenarioBehavior        see {@link #emptyScenarioBehavior}
     * @param emptyRuleBehavior            see {@link #emptyRuleBehavior}
     * @param unimplementedStepBehavior    see {@link #unimplementedStepBehavior}
     * @param tagForEmptyScenarios   see {@link #tagForEmptyScenarios}
     * @param tagForEmptyRules   see {@link #tagForEmptyRules}
     * @param addCucumberStepAnnotations   see {@link #addCucumberStepAnnotations}
     * @param placeGeneratedClassNextToAnnotatedClass see {@link #placeGeneratedClassNextToAnnotatedClass}
     * @param dataTableParameterType       see {@link #dataTableParameterType}
     * @param enableCompositeSteps         see {@link #enableCompositeSteps}
     * @param useQualifiedEnumConstants    see {@link #useQualifiedEnumConstants}
     * @param useStepKeywordInStepMethodName see {@link #useStepKeywordInStepMethodName}
     * @param useCucumberAnnotationsForStepMatching see {@link #useCucumberAnnotationsForStepMatching}
     * @param supportedFileExtensions see {@link #supportedFileExtensions}
     * @param skipGenerationForTags see {@link #skipGenerationForTags}
     * @param verbosity see {@link #verbosity}
     * @param emitScenarioHash see {@link #emitScenarioHash}
     */
    public GeneratorOptions(
            boolean shouldBeAbstract,
            String classSuffixIfConcrete,
            String classSuffixIfAbstract,
            boolean addSourceLineNumbers,
            String emptyScenarioBehavior,
            String emptyRuleBehavior,
            String unimplementedStepBehavior,
            String tagForEmptyScenarios,
            String tagForEmptyRules,
            boolean addCucumberStepAnnotations,
            boolean placeGeneratedClassNextToAnnotatedClass,
            String dataTableParameterType,
            boolean enableCompositeSteps,
            boolean useQualifiedEnumConstants,
            boolean useStepKeywordInStepMethodName,
            boolean useCucumberAnnotationsForStepMatching,
            String[] supportedFileExtensions,
            String[] skipGenerationForTags,
            Verbosity verbosity,
            boolean emitScenarioHash
    ) {
        this.shouldBeAbstract = shouldBeAbstract;
        this.classSuffixIfConcrete = classSuffixIfConcrete;
        this.classSuffixIfAbstract = classSuffixIfAbstract;
        this.addSourceLineNumbers = addSourceLineNumbers;
        this.emptyScenarioBehavior = emptyScenarioBehavior;
        this.emptyRuleBehavior = emptyRuleBehavior;
        this.unimplementedStepBehavior = unimplementedStepBehavior;
        this.tagForEmptyScenarios = tagForEmptyScenarios;
        this.tagForEmptyRules = tagForEmptyRules;
        this.addCucumberStepAnnotations = addCucumberStepAnnotations;
        this.placeGeneratedClassNextToAnnotatedClass = placeGeneratedClassNextToAnnotatedClass;
        this.dataTableParameterType = dataTableParameterType;
        this.enableCompositeSteps = enableCompositeSteps;
        this.useQualifiedEnumConstants = useQualifiedEnumConstants;
        this.useStepKeywordInStepMethodName = useStepKeywordInStepMethodName;
        this.useCucumberAnnotationsForStepMatching = useCucumberAnnotationsForStepMatching;
        this.supportedFileExtensions = supportedFileExtensions;
        this.skipGenerationForTags = skipGenerationForTags;
        this.verbosity = verbosity == null ? Verbosity.NORMAL : verbosity;
        this.emitScenarioHash = emitScenarioHash;
    }

}
