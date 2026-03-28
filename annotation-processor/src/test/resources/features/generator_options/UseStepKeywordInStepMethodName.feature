Feature: UseStepKeywordInStepMethodName
  As a developer writing behavior specifications
  I want to control whether the Gherkin keyword (Given/When/Then) is included in generated step method names
  So that I can reuse the same step method across different keywords when the step text is identical

  Rule: When useStepKeywordInStepMethodName is true, step methods are prefixed with the keyword
  - Given user exists → givenUserExists()
  - When user clicks  → whenUserClicks()
  - Then result shown → thenResultShown()

    Scenario: Default behavior includes keyword in method name
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useStepKeywordInStepMethodName = true)
        public abstract class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: Test
          Scenario: Simple test
            Given user exists
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Test
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenResultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Simple test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * When user clicks button
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 */
                thenResultIsDisplayed();
            }
        }
        """

  Rule: When useStepKeywordInStepMethodName is false, step methods are named from step text only
  - The keyword (Given/When/Then) is omitted from the method name
  - The method name starts with the first word of the step text in lowercase

    Scenario: Step methods without keyword prefix
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useStepKeywordInStepMethodName = false)
        public abstract class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: Test
          Scenario: Simple test
            Given user exists
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Test
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Simple test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When user clicks button
                 */
                userClicksButton();
                /*
                 * Then result is displayed
                 */
                resultIsDisplayed();
            }
        }
        """

    Scenario: And/But steps also omit keyword from method names
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useStepKeywordInStepMethodName = false)
        public abstract class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: Test
          Scenario: Test
            Given user exists
            And user is active
            When user logs in
            But session is not expired
            Then dashboard is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Test
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userLogsIn() {
                Assertions.fail("Step is not yet implemented");
            }

            public void sessionIsNotExpired() {
                Assertions.fail("Step is not yet implemented");
            }

            public void dashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user is active
                 */
                userIsActive();
                /*
                 * When user logs in
                 */
                userLogsIn();
                /*
                 * But session is not expired
                 */
                sessionIsNotExpired();
                /*
                 * Then dashboard is displayed
                 */
                dashboardIsDisplayed();
            }
        }
        """

  Rule: When useStepKeywordInStepMethodName is false, identical step text under different keywords resolves to a single method
  - This is the key benefit of omitting keywords: step methods become keyword-agnostic
  - A step method defined once can be called from Given, When, or Then contexts

    Scenario: Same step text with different keywords produces one shared method
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useStepKeywordInStepMethodName = false)
        public abstract class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: Test
          Scenario: Test
            Given user exists
            When action is performed
            Then user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Test
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When action is performed
                 */
                actionIsPerformed();
                /*
                 * Then user exists
                 */
                userExists();
            }
        }
        """


