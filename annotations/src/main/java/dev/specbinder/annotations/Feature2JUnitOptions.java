package dev.specbinder.annotations;

import dev.specbinder.annotations.output.SourceLine;

import java.lang.annotation.*;

/**
 * Specifies configuration options for generating JUnit test classes from classes annotated with {@link Feature2JUnit}.
 * Use this annotation to customize the structure and behavior of the generated test classes.
 * <p>
 * This annotation is inherited, so it can be specified on a parent class in your test hierarchy to apply its options to all subclasses.
 * <p>
 * RUNTIME retention is used to ensure compatibility with incremental build systems.
 * SOURCE retention does not work well with incremental compilation, notably with IntelliJ IDEA's incremental build system.
 */
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface Feature2JUnitOptions {

    /**
     * Defines how data tables in Gherkin steps are represented as parameters in generated step methods.
     * <p>
     * This enum controls the type of parameter generated for steps that contain data tables,
     * affecting both the method signature and how the data is passed to your test implementation.
     */
    enum DATA_TABLE_PARAMETER_TYPE {
        /**
         * Represents data tables as {@code List<Map<String, String>>}.
         * <p>
         * Each row in the table becomes a Map where keys are column headers and values are cell values.
         * This type is convenient for working with tabular data without additional type definitions.
         * <p>
         * Example generated method signature:
         * <pre>
         * public abstract void givenTheFollowingProducts(List&lt;Map&lt;String, String&gt;&gt; dataTable);
         * </pre>
         */
        LIST_OF_MAPS,

        /**
         * Represents data tables using Cucumber's {@code DataTable} class.
         * <p>
         * This option provides access to Cucumber's full data table API, including type conversion
         * and custom transformations through {@code TableConverter}. It can be more powerful if
         * you're already familiar with Cucumber's data table handling, but may be more complex to
         * configure and use compared to simpler alternatives.
         * <p>
         * Requires helper methods {@code getTableConverter()} and {@code createDataTable(String)}
         * to be present in the class hierarchy.
         * <p>
         * Example generated method signature:
         * <pre>
         * public abstract void whenUserHasPermissions(DataTable dataTable);
         * </pre>
         */
        CUCUMBER_DATA_TABLE,

        /**
         * -- EXPERIMENTAL OPTION --
         * <br/><br/>
         * Represents data tables as {@code List<ObjectParam>} where ObjectParam is a generated inner type based on
         * table structure.
         * <p>
         * The generator creates an object type with fields corresponding to the table's column headers,
         * providing type-safe access to table data. Each row becomes an instance of the generated type.
         * This type offers the strongest type safety but is currently experimental.
         * <p>
         * Example generated method signature:
         * <pre>
         * public abstract void whenUserHasPermissionsParam(List&lt;PermissionsParam&gt; permissions);
         * </pre>
         * where {@code PermissionsParam} is generated with fields matching the table columns.
         */
        LIST_OF_OBJECT_PARAMS
    }

    /**
     * If set to true, the generator will add a failing test method for rules that have no scenarios.
     * An example of what the generated inner class would look like for an empty rule is:
     * <pre>
     *     &#64;Nested
     *     &#64;Order(1)
     *     &#64;DisplayName("Rule: Processing rules")
     *     public class Rule_1 {
     *         &#64;Test
     *         &#64;Tag("new")
     *         public void noScenariosInRule() {
     *             Assertions.fail("Rule doesn't have any scenarios");
     *         }
     *     }
     * </pre>
     *
     * @return true if rules with no scenarios should fail, false otherwise
     */
    boolean failRulesWithNoScenarios() default true;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to failing test method
     * that was added for rules that do not contain any scenarios. By default, this is set to "new".
     * If an empty or blank value is specified, no tag will be added.
     *
     * @return the tag for rules with no scenarios
     */
    String tagForRulesWithNoScenarios() default "new";

    /**
     * If set to true, the generator will add a call to a failing JUnit failing assertion for scenarios that have no steps.
     * An example of what the generated test method would look like for an empty scenario is:
     * <pre>
     *     &#64;Test
     *     &#64;Order(1)
     *     &#64;Tag("new")
     *     &#64;DisplayName("Scenario: Empty scenario")
     *     public void scenario_Empty_scenario() {
     *         Assertions.fail("Scenario has no steps");
     *     }
     * </pre>
     *
     * @return true if scenarios with no steps should fail, false otherwise
     */
    boolean failScenariosWithNoSteps() default true;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to scenarios that do not
     * contain any steps. By default, this is set to "new".
     * If an empty or blank value is specified, no tag will be added.
     *
     * @return the tag for scenarios with no steps
     */
    String tagForScenariosWithNoSteps() default "new";

    /**
     * If set to true, the generator will add {@link SourceLine} annotation to test methods and
     * nested test classes containing line numbers where these elements appear in the Feature file.
     * <p>
     * An example of what the generated annotation would look like is:
     * <pre>
     *     &#64;Test
     *     &#64;Order(1)
     *     &#64;SourceLine(12)
     *     &#64;DisplayName("Scenario: Successful login")
     *     public void scenario_Successful_login() {
     *     ...
     *     }
     *     </pre>
     *
     * @return true if source line annotations should be added, false otherwise
     */
    boolean addSourceLineAnnotations() default false;

    /**
     * If set to true, the generator will append the source location in the java block comment just before a call
     * to each step method.
     * An example of what the generated comment would look like is:
     * <pre>
     *     &#64;Test
     *     &#64;Order(1)
     *     &#64;SourceLine(2)
     *     &#64;DisplayName("Scenario: Test")
     *     public void scenario_1() {
     *        &#47;*
     *          * Given user exists
     *          * (source line - 3)
     *          *&#47;
     *         givenUserExists();
     *         &#47;*
     *           * When user clicks button
     *           * (source line - 4)
     *           *&#47;
     *          whenUserClicksButton();
     *          &#47;*
     *           * Then result is displayed
     *           * (source line - 5)
     *           *&#47;
     *          thenResultIsDisplayed();
     *      }
     *     </pre>
     *
     * @return true if source line comments should be added before step calls, false otherwise
     */
    boolean addSourceLineBeforeStepCalls() default false;

    /**
     * Controls whether the generated test class is abstract or concrete, determining how step methods are generated
     * and where they should be implemented.
     * <p>
     * When {@code true} (abstract generation):
     * <ul>
     *     <li>The generated test class will be declared as {@code abstract}</li>
     *     <li>Step methods will be generated as {@code abstract} methods without method bodies</li>
     *     <li>You must create a concrete subclass that extends the generated class and implements all abstract step methods</li>
     *     <li>This approach provides compile-time safety - missing step implementations cause compilation errors</li>
     * </ul>
     * <p>
     * When {@code false} (concrete generation, default):
     * <ul>
     *     <li>The generated test class will be a concrete class that can be executed directly</li>
     *     <li>Step methods will be generated with method bodies containing {@code Assertions.fail("Step is not yet implemented")}</li>
     *     <li>Tests can run immediately but will fail until step methods are implemented</li>
     *     <li>To implement steps: move the failing step methods from the generated class to the annotated base class
     *     and provide the actual implementation. On the next generation run, implemented methods will be detected
     *     in the class hierarchy and excluded from the generated output</li>
     *     <li>This approach enables iterative development - start with failing tests, implement gradually</li>
     * </ul>
     *
     * @return true if the generated test class should be abstract, false otherwise
     */
    boolean shouldBeAbstract() default false;

    /**
     * Suffix that will be used for the name of the generated test class in case it is abstract (i.e., when shouldBeAbstract is true).
     *
     * @return the suffix for the generated test class name
     */
    String classSuffixIfAbstract() default "Scenarios";

    /**
     * Suffix that will be used for the name of the generated test class in case it is concrete (i.e., when shouldBeAbstract is false).
     *
     * @return the suffix for the generated test class name
     */
    String classSuffixIfConcrete() default "Test";

    /**
     * Specifies the type of parameters that will be used for step methods corresponding to steps with data tables.
     * The options are:
     * <ul>
     *     <li>LIST_OF_MAPS - (default) Each data table will be represented as a List of Maps, where each Map corresponds to a row in the table
     *     with column headers as keys.</li>
     *     <li>CUCUMBER_DATA_TABLE - Each data table will be represented using Cucumber's DataTable class, allowing for more advanced data table handling
     *     <li>LIST_OF_OBJECT_PARAMS - (experimental) Each data table will be represented as a List of custom object types generated based on the data table structure.
     *     features provided by Cucumber.</li>
     * </ul>
     *
     * @return the data table parameter type
     */
    DATA_TABLE_PARAMETER_TYPE dataTableParameterType() default DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

    /* =============================================================================
     * The rest of the options below are experimental and subject to change/removal.
     * =============================================================================
     */

    /**
     * If set to true, the generator will add Cucumber step annotations (e.g. @Given, @When, @Then) to the generated
     * step methods. This can be useful inside IDEs with installed Cucumber/Gherkin plugins to facilitate navigation
     * from textual steps in a Gherkin feature file to step method java code.
     * <br/><br/>
     * Note that this would introduce a dependency on Cucumber annotations in the generated test class, which the client
     * project would need to have on its classpath.
     *
     * @return true if Cucumber step annotations should be added, false otherwise
     */
    boolean addCucumberStepAnnotations() default false;

    /**
     * -- EXPERIMENTAL OPTION --
     * <br/><br/>
     * Enables composite step pattern where a Given/When/Then/And/But step followed by one or more steps
     * using the '*' keyword generates a composite step method that wraps the sub-steps.
     * <p>
     * This pattern is inspired by JBehave's textual composite steps and allows grouping related steps
     * under a higher-level abstraction without creating additional step implementations.
     * <p>
     * When enabled, the generator detects this pattern:
     * <pre>
     * Given customer "Alice" has product "Laptop" in shopping cart
     * * login as customer $p1
     * * search for product $p2
     * * add product to cart
     * * verify cart contains $p2
     * </pre>
     * And generates a composite step method with a lambda parameter:
     * <pre>
     * protected void customerHasProductInShoppingCart(String customer, String product,
     *                                                  BiConsumer&lt;String, String&gt;... composite) {
     *     if (composite.length &gt; 0) {
     *         stream(composite).forEach(action -&gt; action.accept(customer, product));
     *     } else {
     *         throw new UnsupportedOperationException("Step is not yet implemented");
     *     }
     * }
     * </pre>
     * The composite step is invoked in test methods with sub-steps as a lambda body:
     * <pre>
     * customerHasProductInShoppingCart("Alice", "Laptop", (p1, p2) -&gt; {
     *     loginAsCustomer(p1);
     *     searchForProduct(p2);
     *     addProductToCart();
     *     verifyCartContains(p2);
     * });
     * </pre>
     * <p>
     * Parameters from the composite step (quoted strings) are available to sub-steps via $p1, $p2, etc. syntax.
     * The composite step method's Consumer parameter is optional (varargs), allowing users to override
     * the method and provide custom default behavior if needed.
     * <p>
     * Note: This feature is experimental and the API may change in future versions.
     *
     * @return true if composite step pattern should be enabled, false otherwise
     */
    boolean enableCompositeSteps() default false;

}