package dev.specbinder.story2junit.config;

import lombok.Getter;

import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

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
     * If set to true, the generator will add {@link dev.specbinder.annotations.output.SourceLine} annotation to test methods and
     * nested test classes containing line numbers where these elements appear in the Feature file.
     */
    private final boolean addSourceLineAnnotations;

    /**
     * If set to true, the generator will add source location as a java comment just before a call to each step method
     * inside the test methods.
     */
    private final boolean addSourceLineBeforeStepCalls;

    /**
     * If set to true, the generator will add a call to a failing JUnit assumption for scenarios that have no steps.
     */
    private final boolean failScenariosWithNoSteps;

    /**
     * If set to true, the generator will add a failing test method for rules that have no scenarios.
     */
    private final boolean failRulesWithNoScenarios;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to scenarios that do not
     * contain any steps. If an empty or blank value is specified, no tag will be added.
     */
    private final String tagForScenariosWithNoSteps;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to failing test method
     * that was added for rules that do not contain any scenarios.
     * If an empty or blank value is specified, no tag will be added.
     */
    private final String tagForRulesWithNoScenarios;

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
        this.addSourceLineAnnotations = false;
        this.addSourceLineBeforeStepCalls = false;
        this.failScenariosWithNoSteps = true;
        this.failRulesWithNoScenarios = true;
        this.tagForScenariosWithNoSteps = "new";
        this.tagForRulesWithNoScenarios = "new";
        this.addCucumberStepAnnotations = false;
        this.placeGeneratedClassNextToAnnotatedClass = false;
        this.dataTableParameterType = LIST_OF_MAPS.name();
    }

    /**
     * Custom options
     *
     * @param classSuffixIfAbstract        see {@link #classSuffixIfAbstract}
     * @param addSourceLineAnnotations     see {@link #addSourceLineAnnotations}
     * @param addSourceLineBeforeStepCalls see {@link #addSourceLineBeforeStepCalls}
     * @param failScenariosWithNoSteps     see {@link #failScenariosWithNoSteps}
     * @param failRulesWithNoScenarios     see {@link #failRulesWithNoScenarios}
     * @param tagForScenariosWithNoSteps   see {@link #tagForScenariosWithNoSteps}
     * @param tagForRulesWithNoScenarios   see {@link #tagForRulesWithNoScenarios}
     * @param addCucumberStepAnnotations   see {@link #addCucumberStepAnnotations}
     * @param placeGeneratedClassNextToAnnotatedClass see {@link #placeGeneratedClassNextToAnnotatedClass}
     * @param dataTableParameterType       see {@link #dataTableParameterType}
     */
    public GeneratorOptions(
            String classSuffixIfAbstract,
            boolean addSourceLineAnnotations,
            boolean addSourceLineBeforeStepCalls,
            boolean failScenariosWithNoSteps,
            boolean failRulesWithNoScenarios,
            String tagForScenariosWithNoSteps,
            String tagForRulesWithNoScenarios,
            boolean addCucumberStepAnnotations,
            boolean placeGeneratedClassNextToAnnotatedClass,
            String dataTableParameterType
    ) {
        this.classSuffixIfAbstract = classSuffixIfAbstract;
        this.addSourceLineAnnotations = addSourceLineAnnotations;
        this.addSourceLineBeforeStepCalls = addSourceLineBeforeStepCalls;
        this.failScenariosWithNoSteps = failScenariosWithNoSteps;
        this.failRulesWithNoScenarios = failRulesWithNoScenarios;
        this.tagForScenariosWithNoSteps = tagForScenariosWithNoSteps;
        this.tagForRulesWithNoScenarios = tagForRulesWithNoScenarios;
        this.addCucumberStepAnnotations = addCucumberStepAnnotations;
        this.placeGeneratedClassNextToAnnotatedClass = placeGeneratedClassNextToAnnotatedClass;
        this.dataTableParameterType = dataTableParameterType;
    }

}
