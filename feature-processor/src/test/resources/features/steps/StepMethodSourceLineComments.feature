Feature: StepMethodSourceLineComments
  As a developer
  I want source line references in block comments at step method call sites
  So that I can easily trace generated code back to the original feature file lines

  Rule: When addSourceLineBeforeStepCalls is disabled (default), no source line information appears in block comments
    - block comments above step calls contain only the step text
    - no line numbers are included in the comments
    - this is the default behavior to keep generated code clean

    Scenario: Source line comments are not added when option is disabled (default)
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Default Behavior
          Scenario: Test
            Given user exists
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Default Behavior
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
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
            @DisplayName("Scenario: Test")
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

  Rule: When addSourceLineBeforeStepCalls is enabled, source line numbers are added to block comments
    - each step call block comment includes the line number where the step appears in the feature file
    - format is "(source line - X)" on a separate line in the comment
    - this helps developers navigate from generated code back to feature file

    Scenario: Source line comments are added when option is enabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Source Line Comments
          Scenario: Test
            Given user exists
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Source Line Comments
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                givenUserExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 5)
                 */
                thenResultIsDisplayed();
            }
        }
        """

  Rule: addSourceLineBeforeStepCalls works independently of addSourceLineAnnotations
    - addSourceLineBeforeStepCalls only affects block comments, not @SourceLine annotations
    - addSourceLineAnnotations only affects @SourceLine annotations, not block comments
    - both options can be enabled or disabled independently

    Scenario: Only source line comments are added, not @SourceLine annotations
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true, addSourceLineAnnotations = false)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Independent Options
          Scenario: Test
            Given user exists
            When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Independent Options
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                givenUserExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                whenUserClicksButton();
            }
        }
        """

    Scenario: Source line comments work with multiple steps
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Multiple Steps
          Scenario: Test
            Given user exists
            And user is active
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenUserIsActive() {
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
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                givenUserExists();
                /*
                 * And user is active
                 * (source line - 4)
                 */
                givenUserIsActive();
                /*
                 * When user clicks button
                 * (source line - 5)
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 6)
                 */
                thenResultIsDisplayed();
            }
        }
        """
