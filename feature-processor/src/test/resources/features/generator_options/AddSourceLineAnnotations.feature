Feature: AddSourceLineAnnotations
  As a developer navigating generated test code
  I want @SourceLine annotations on scenario methods and Rule inner classes that record where each element is defined in the feature file
  So that my IDE can provide clickable navigation from generated code back to the exact specification line, reducing context-switching when debugging test failures

  Rule: when addSourceLineAnnotations is enabled, @SourceLine annotations are added to scenario methods

    Scenario: @SourceLine annotations are added when option is enabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Source Line Annotations
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
        import dev.specbinder.annotations.output.SourceLine;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Source Line Annotations
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
            @SourceLine(2)
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

  Rule: when addSourceLineAnnotations is enabled, @SourceLine annotations are also added to Rule @Nested inner classes

    Scenario: @SourceLine annotation is added to Rule nested inner class
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Rules With Source Lines
          Rule: user management
            Scenario: Test
              Given user exists
              When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Rules With Source Lines
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Nested
            @Order(1)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @SourceLine(2)
            @DisplayName("Rule: user management")
            public class Rule_1 {
                @Test
                @Order(1)
                @SourceLine(3)
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
                }
            }
        }
        """

    Scenario: @SourceLine annotations are added to multiple Rules with correct line numbers
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Multiple Rules With Source Lines
          Rule: first rule
            Scenario: First test
              Given user exists
          Rule: second rule
            Scenario: Second test
              When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Rules With Source Lines
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Nested
            @Order(1)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @SourceLine(2)
            @DisplayName("Rule: first rule")
            public class Rule_1 {
                @Test
                @Order(1)
                @SourceLine(3)
                @DisplayName("Scenario: First test")
                public void scenario_1() {
                    /*
                     * Given user exists
                     */
                    givenUserExists();
                }
            }

            @Nested
            @Order(2)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @SourceLine(5)
            @DisplayName("Rule: second rule")
            public class Rule_2 {
                @Test
                @Order(1)
                @SourceLine(6)
                @DisplayName("Scenario: Second test")
                public void scenario_1() {
                    /*
                     * When user clicks button
                     */
                    whenUserClicksButton();
                }
            }
        }
        """
