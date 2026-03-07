package dev.specbinder.story2junit.config;

import lombok.Getter;

import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

/**
 * Options for the generator that can be used to customize the generated test classes.
 */
@Getter
public class GeneratorOptions {

    /**
     * Suffix that will be used for the name of the generated test class if it is abstract.
     */
    private final String classSuffixIfAbstract;

    /**
     * If set to true, the generator will embed source line numbers from the feature file
     * into the generated test code in two ways:
     * line numbers in @DisplayName annotations and [N] prefixes in step block comments.
     */
    private final boolean addSourceLineNumbers;

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
     * Default options
     */
    public GeneratorOptions() {
        this.classSuffixIfAbstract = "Scenarios";
        this.addSourceLineNumbers = false;
        this.tagForEmptyScenarios = "new";
        this.tagForEmptyRules = "new";
        this.addCucumberStepAnnotations = false;
        this.placeGeneratedClassNextToAnnotatedClass = false;
        this.dataTableParameterType = LIST_OF_OBJECT_PARAMS.name();
    }

    /**
     * Custom options
     *
     * @param classSuffixIfAbstract        see {@link #classSuffixIfAbstract}
     * @param addSourceLineNumbers         see {@link #addSourceLineNumbers}
     * @param tagForEmptyScenarios   see {@link #tagForEmptyScenarios}
     * @param tagForEmptyRules   see {@link #tagForEmptyRules}
     * @param addCucumberStepAnnotations   see {@link #addCucumberStepAnnotations}
     * @param placeGeneratedClassNextToAnnotatedClass see {@link #placeGeneratedClassNextToAnnotatedClass}
     * @param dataTableParameterType       see {@link #dataTableParameterType}
     */
    public GeneratorOptions(
            String classSuffixIfAbstract,
            boolean addSourceLineNumbers,
            String tagForEmptyScenarios,
            String tagForEmptyRules,
            boolean addCucumberStepAnnotations,
            boolean placeGeneratedClassNextToAnnotatedClass,
            String dataTableParameterType
    ) {
        this.classSuffixIfAbstract = classSuffixIfAbstract;
        this.addSourceLineNumbers = addSourceLineNumbers;
        this.tagForEmptyScenarios = tagForEmptyScenarios;
        this.tagForEmptyRules = tagForEmptyRules;
        this.addCucumberStepAnnotations = addCucumberStepAnnotations;
        this.placeGeneratedClassNextToAnnotatedClass = placeGeneratedClassNextToAnnotatedClass;
        this.dataTableParameterType = dataTableParameterType;
    }

}
