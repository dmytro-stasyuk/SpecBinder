package dev.specbinder.annotations;

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
         * Represents data tables as {@code List<ObjectParam>} where ObjectParam is a generated inner type based on
         * table structure.
         * <p>
         * The generator creates an object type with fields corresponding to the table's column headers,
         * providing type-safe access to table data. Each row becomes an instance of the generated type.
         * This type offers the strongest type safety.
         * <p>
         * Example generated method signature:
         * <pre>
         * public abstract void whenUserHasPermissionsParam(List&lt;PermissionsParam&gt; permissions);
         * </pre>
         * where {@code PermissionsParam} is generated with fields matching the table columns.
         */
        LIST_OF_OBJECT_PARAMS,

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
        LIST_OF_MAPS
    }

    /**
     * Defines the behavior of generated code for empty or unimplemented Gherkin elements
     * (Rules with no Scenarios, Scenarios with no steps, or unimplemented step method stubs).
     *
     * @see #emptyRuleBehavior()
     * @see #emptyScenarioBehavior()
     * @see #unimplementedStepBehavior()
     */
    enum EMPTY_ELEMENT_BEHAVIOUR {
        /**
         * Generates a test method that <strong>fails</strong> using {@code Assertions.fail(...)}.
         * <p>
         * The test is reported as a failure, making it immediately visible in test results.
         * This is the recommended mode for TDD workflows where empty elements represent
         * work that needs to be done.
         */
        FAIL,

        /**
         * Generates a test method that is <strong>skipped</strong> using {@code Assumptions.assumeTrue(false, ...)}.
         * <p>
         * The test is reported as skipped/aborted rather than failed, which can be useful
         * when empty elements are intentional placeholders that should not block the build.
         */
        SKIP,

        /**
         * Generates a test method that <strong>does not compile</strong> by inserting a plain-text
         * statement (e.g. {@code Scenario has no steps}) into the method body.
         * <p>
         * Because the inserted text is not valid Java, compilation fails immediately,
         * making it impossible to overlook empty elements. This is the strictest mode —
         * unlike {@link #FAIL}, which only surfaces the problem at test-run time,
         * {@code COMPILATION_ERROR} prevents the project from compiling at all until
         * the element is filled in or the expected behavior is changed.
         * <p>
         * This mode is useful in CI pipelines or strict TDD workflows where empty
         * elements should be treated as hard blockers rather than deferred failures.
         */
        COMPILATION_ERROR
    }

    /**
     * Specifies the file extensions that the annotation processor recognizes as Gherkin specification files.
     * <p>
     * When using convention-based discovery ({@code @Feature2JUnit} with no value) or glob patterns,
     * the processor will search for files matching any of the specified extensions.
     * When using explicit file paths, the file is processed regardless of its extension.
     * <p>
     * Each extension should be specified without the leading dot (e.g., {@code "feature"}, {@code "specb"}).
     * The array must not be empty and none of the values may be blank.
     * <p>
     * Example usage:
     * <pre>
     * &#64;Feature2JUnitOptions(supportedFileExtensions = {"feature", "specb"})
     * </pre>
     *
     * @return the array of supported file extensions
     */
    String[] supportedFileExtensions() default {"feature", "specb"};

    /**
     * Specifies regex patterns for Gherkin tags for which the generator should skip code generation entirely.
     * <p>
     * Each value is treated as a Java regular expression and matched against the tag names
     * on Feature, Rule, Scenario, and Examples elements (without the leading {@code @} symbol).
     * When any tag on an element matches any of the specified patterns, the generator will not
     * produce the corresponding generated code element (test class, {@code @Nested} class,
     * {@code @Test} method, or {@code @ParameterizedTest} parameter set, respectively).
     * <p>
     * This is useful for excluding elements that are not meant to be executed as automated tests,
     * such as manual test cases or work-in-progress scenarios, without removing them from the
     * specification.
     * <p>
     * Each pattern is matched against the full tag name (without the leading {@code @}).
     * Use {@code .*} for wildcard matching. Patterns are case-sensitive by default;
     * use {@code (?i)} for case-insensitive matching.
     * <p>
     * Example usage:
     * <pre>
     * &#64;Feature2JUnitOptions(skipGenerationForTags = {"manual", "wip-.*", "(?i)ignore"})
     * </pre>
     * This would skip generation for elements tagged with {@code @manual}, any tag starting
     * with {@code @wip-} (e.g., {@code @wip-sprint-42}), or {@code @ignore}/{@code @IGNORE}/{@code @Ignore}.
     * <p>
     * Given the following feature file:
     * <pre>
     * &#64;manual
     * Scenario: User verifies printed report visually
     *   Given a printed report
     *   Then the layout matches the approved template
     * </pre>
     * The above scenario would be excluded from the generated test class entirely.
     *
     * @return the array of regex patterns for tags for which code generation should be skipped
     */
    String[] skipGenerationForTags() default {};

    /**
     * Controls how the generator handles Rules that contain no Scenarios.
     * <ul>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#FAIL FAIL} (default) — generates a test method with
     *     {@code Assertions.fail("Rule doesn't have any scenarios")}, causing the test to fail</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#SKIP SKIP} — generates a test method with
     *     {@code Assumptions.assumeTrue(false, "Rule has no scenarios")}, causing the test to be skipped</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#COMPILATION_ERROR COMPILATION_ERROR} — inserts an invalid
     *     statement that prevents compilation, making empty Rules a hard blocker</li>
     * </ul>
     *
     * @return the behavior for Rules with no Scenarios
     * @see #tagForEmptyRules()
     */
    EMPTY_ELEMENT_BEHAVIOUR emptyRuleBehavior() default EMPTY_ELEMENT_BEHAVIOUR.FAIL;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to failing test method
     * that was added for rules that do not contain any scenarios. By default, this is set to "new".
     * If an empty or blank value is specified, no tag will be added.
     *
     * @return the tag for empty rules
     */
    String tagForEmptyRules() default "new";

    /**
     * Controls how the generator handles Scenarios that contain no steps.
     * <ul>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#FAIL FAIL} (default) — generates a test method with
     *     {@code Assertions.fail("Scenario has no steps")}, causing the test to fail</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#SKIP SKIP} — generates a test method with
     *     {@code Assumptions.assumeTrue(false, "Scenario has no steps")}, causing the test to be skipped</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#COMPILATION_ERROR COMPILATION_ERROR} — inserts an invalid
     *     statement that prevents compilation, making empty Scenarios a hard blocker</li>
     * </ul>
     *
     * @return the behavior for Scenarios with no steps
     * @see #tagForEmptyScenarios()
     */
    EMPTY_ELEMENT_BEHAVIOUR emptyScenarioBehavior() default EMPTY_ELEMENT_BEHAVIOUR.FAIL;

    /**
     * The value for JUnit's @{@link org.junit.jupiter.api.Tag} annotation that will be added to scenarios that do not
     * contain any steps. By default, this is set to "new".
     * If an empty or blank value is specified, no tag will be added.
     *
     * @return the tag for empty scenarios
     */
    String tagForEmptyScenarios() default "new";

    /**
     * If set to true, the generator will embed source line numbers from the feature file
     * into the generated test code in two ways:
     * <ul>
     *     <li>Line numbers are embedded in {@code @DisplayName} annotations on Scenario test methods,
     *     Rule {@code @Nested} inner classes, and Background {@code @BeforeEach} methods</li>
     *     <li>Line numbers are added as a prefix in the block comments above step method calls</li>
     * </ul>
     * <p>
     * An example of what the generated code would look like is:
     * <pre>
     *     &#64;Test
     *     &#64;Order(1)
     *     &#64;DisplayName("Scenario [2]: Successful login")
     *     public void scenario_1() {
     *        &#47;*
     *          * [3] Given user exists
     *          *&#47;
     *         userExists();
     *         &#47;*
     *           * [4] When user clicks button
     *           *&#47;
     *          userClicksButton();
     *      }
     *     </pre>
     *
     * @return true if source line numbers should be added, false otherwise
     */
    boolean addSourceLineNumbers() default false;

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
     * Controls the body of generated step method stubs when {@link #shouldBeAbstract()} is {@code false}
     * (concrete generation mode).
     * <p>
     * When the generated test class is concrete, each unimplemented step produces a non-abstract method
     * whose body is determined by this option:
     * <ul>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#FAIL FAIL} (default) — the method body contains
     *     {@code Assertions.fail("Step is not yet implemented")}, causing the test to fail at runtime
     *     when the step is reached</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#SKIP SKIP} — the method body contains
     *     {@code Assumptions.assumeTrue(false, "Step is not yet implemented")}, causing the test
     *     to be reported as skipped/aborted when the step is reached</li>
     *     <li>{@link EMPTY_ELEMENT_BEHAVIOUR#COMPILATION_ERROR COMPILATION_ERROR} — the method body
     *     contains an invalid statement ({@code Step is not yet implemented}) that prevents compilation,
     *     making unimplemented steps a hard blocker similar to abstract generation mode</li>
     * </ul>
     * <p>
     * This option has no effect when {@link #shouldBeAbstract()} is {@code true}, because in abstract
     * mode step methods are declared as {@code abstract} and have no method body at all.
     *
     * @return the behavior for unimplemented step method stubs
     * @see #shouldBeAbstract()
     */
    EMPTY_ELEMENT_BEHAVIOUR unimplementedStepBehavior() default EMPTY_ELEMENT_BEHAVIOUR.FAIL;

    /**
     * Specifies the type of parameters that will be used for step methods corresponding to steps with data tables.
     * The options are:
     * <ul>
     *     <li>LIST_OF_OBJECT_PARAMS - (default) Each data table will be represented as a List of custom object types generated based on the data table structure.</li>
     *     <li>LIST_OF_MAPS - Each data table will be represented as a List of Maps, where each Map corresponds to a row in the table
     *     with column headers as keys.</li>
     *     <li>CUCUMBER_DATA_TABLE - Each data table will be represented using Cucumber's DataTable class, allowing for more advanced data table handling
     *     features provided by Cucumber.</li>
     * </ul>
     *
     * @return the data table parameter type
     */
    DATA_TABLE_PARAMETER_TYPE dataTableParameterType() default DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

    /* =============================================================================
     * The rest of the options below are experimental and subject to change/removal.
     * =============================================================================
     */

    /**
     * Controls whether the Gherkin step keyword (Given, When, Then) is included as a prefix
     * in generated step method names.
     * <p>
     * When {@code true}:
     * <ul>
     *     <li>The keyword is included as the first word of the method name</li>
     *     <li>Each keyword produces a distinct method name for the same step text</li>
     * </ul>
     * <pre>
     * Given user exists      → givenUserExists()
     * When user exists       → whenUserExists()
     * Then user exists       → thenUserExists()
     * </pre>
     * <p>
     * When {@code false} (default):
     * <ul>
     *     <li>The keyword is omitted from the method name</li>
     *     <li>The method name starts with the first word of the step text (in lowercase)</li>
     *     <li>The same step text used with different keywords (Given/When/Then) resolves to a single shared method</li>
     * </ul>
     * <pre>
     * Given user exists      → userExists()
     * When user exists       → userExists()
     * Then user exists       → userExists()
     * </pre>
     * This can reduce duplication when the same step text appears under different keywords.
     *
     * @return true if step keywords should be included in method names, false otherwise
     */
    boolean useStepKeywordInStepMethodName() default false;

    /**
     * If set to true, the generator will add Cucumber step annotations (e.g. @Given, @When, @Then) to the generated
     * step methods. This can be useful inside IDEs with installed Cucumber/Gherkin plugins to facilitate navigation
     * from textual steps in a Gherkin feature file to step method java code.
     *
     * @return true if Cucumber step annotations should be added, false otherwise
     */
    boolean addCucumberStepAnnotations() default false;

    /**
     * Controls whether Cucumber step annotations ({@code @Given}, {@code @When}, {@code @Then})
     * on methods in the class hierarchy are used to match steps from the feature file to existing
     * method implementations.
     * <p>
     * When {@code true} (default):
     * <ul>
     *     <li>The generator inspects Cucumber step annotations on inherited methods to determine
     *     if a step is already implemented</li>
     *     <li>A method annotated with e.g. {@code @Given("user exists")} will be recognised as
     *     the implementation of the step "Given user exists", even if the method name does not
     *     follow the standard naming convention</li>
     *     <li>Methods without Cucumber step annotations are still matched by method name as usual,
     *     so both annotation-based and name-based matching work together</li>
     *     <li>If both an annotation-matched method and a name-matched method exist for the same step,
     *     the annotation-matched method takes precedence</li>
     *     <li>Matched methods are not re-declared in the generated test class but are called
     *     from the generated scenario methods, just as name-matched methods are</li>
     * </ul>
     * <p>
     * The annotation value can be either a <b>regular expression</b> or a <b>Cucumber expression</b>.
     * Both formats are supported and the generator will attempt to match using each one.
     * <p>
     * <b>Cucumber expressions</b> use a human-readable syntax with built-in parameter types
     * enclosed in curly braces. The following default parameter types are supported:
     * <ul>
     *     <li>{@code {int}} – matches integers (e.g. {@code 71}, {@code -19}), maps to {@code int}</li>
     *     <li>{@code {float}} – matches floats (e.g. {@code 3.6}, {@code .8}, {@code -9.2}), maps to {@code float}</li>
     *     <li>{@code {word}} – matches a single word without whitespace (e.g. {@code banana}), maps to {@code String}</li>
     *     <li>{@code {string}} – matches a single- or double-quoted string (quotes are discarded), maps to {@code String}</li>
     *     <li>{@code {double}} – matches floats, maps to {@code double}</li>
     *     <li>{@code {long}} – matches integers, maps to {@code long}</li>
     *     <li>{@code {short}} – matches integers, maps to {@code short}</li>
     *     <li>{@code {byte}} – matches integers, maps to {@code byte}</li>
     *     <li>{@code {bigdecimal}} – matches floats, maps to {@code BigDecimal}</li>
     *     <li>{@code {biginteger}} – matches integers, maps to {@code BigInteger}</li>
     *     <li>{@code {}} – anonymous parameter, matches anything</li>
     * </ul>
     * <p>
     * <b>Note:</b> Custom parameter types are not supported – only the built-in types listed above.
     * <p>
     * Examples of Cucumber expressions in annotations:
     * <pre>
     * &#64;Given("a user named {string}")
     * public void aUserNamed(String name) { ... }
     *
     * &#64;When("the user buys {int} items at {float} each")
     * public void theUserBuysItems(int count, float price) { ... }
     *
     * &#64;Then("the total is {}")
     * public void theTotalIs(String value) { ... }
     * </pre>
     * <p>
     * When {@code false}:
     * <ul>
     *     <li>Only method name matching is used to look up existing step implementations</li>
     *     <li>Cucumber step annotations on inherited methods are ignored during lookup</li>
     * </ul>
     * For example, if a base class contains:
     * <pre>
     * &#64;Given("user exists")
     * public void setupUser() { ... }
     * </pre>
     * With this option set to {@code false}, the annotation value {@code "user exists"} is ignored
     * and the method is matched only by its name {@code setupUser}. As a result, the step
     * "Given user exists" would not be matched to this method and would still be generated
     * in the output class.
     *
     * @return true if Cucumber step annotations should be used for step matching, false otherwise
     */
    boolean useCucumberAnnotationsForStepMatching() default true;

    /**
     * Controls how enum constants from parent/ancestor classes are referenced in generated test code
     * when using {@link DATA_TABLE_PARAMETER_TYPE#LIST_OF_OBJECT_PARAMS} for data tables.
     * <p>
     * When {@code false} (default):
     * <ul>
     *     <li>Enum constants are imported using static imports</li>
     *     <li>Constants are referenced by their simple name</li>
     * </ul>
     * <pre>
     * import static features.ProductsFeature.Status.AVAILABLE;
     * ...
     * new ProductsParam("Laptop", AVAILABLE)
     * </pre>
     * <p>
     * When {@code true}:
     * <ul>
     *     <li>The enum type is imported (non-static)</li>
     *     <li>Constants are referenced with the type qualifier prefix</li>
     * </ul>
     * <pre>
     * import features.ProductsFeature.Status;
     * ...
     * new ProductsParam("Laptop", Status.AVAILABLE)
     * </pre>
     * <p>
     * The qualified form can improve readability when the enum type provides meaningful context
     * about what the constant represents.
     *
     * @return true if enum constants should be qualified with their type name, false otherwise
     */
    boolean useQualifiedEnumConstants() default false;

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