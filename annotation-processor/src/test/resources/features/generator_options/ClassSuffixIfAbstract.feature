Feature: ClassSuffixIfAbstract
  As a developer generating abstract test classes
  I want to customize the suffix appended to the generated class name when shouldBeAbstract is true
  So that I can follow my team's naming conventions for generated abstract test hierarchies

  Rule: the default suffix for abstract generated classes is "Scenarios"
  - when shouldBeAbstract is true and classSuffixIfAbstract is not specified, the suffix "Scenarios" is used
  - the generated class name is formed by appending the suffix to the base feature name

    Scenario: default suffix "Scenarios" is used when classSuffixIfAbstract is not specified
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(shouldBeAbstract = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Default Abstract Suffix
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Default Abstract Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public abstract class TestFeatureScenarios extends MockedAnnotatedTestClass {
            public abstract void userExists();

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }
        }
        """

  Rule: classSuffixIfAbstract overrides the default "Scenarios" suffix when shouldBeAbstract is true
  - the custom suffix replaces "Scenarios" in the generated class name
  - the suffix is appended directly to the base feature name without any separator

    Scenario: custom suffix is applied to the generated abstract class name
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(shouldBeAbstract = true, classSuffixIfAbstract = "Steps")
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Custom Abstract Suffix
          Scenario: Test
            Given user exists
            When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Custom Abstract Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public abstract class TestFeatureSteps extends MockedAnnotatedTestClass {
            public abstract void userExists();

            public abstract void userClicksButton();

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When user clicks button
                 */
                userClicksButton();
            }
        }
        """

  Rule: classSuffixIfAbstract has no effect when shouldBeAbstract is false
  - when shouldBeAbstract is false, the classSuffixIfConcrete option is used instead
  - even if classSuffixIfAbstract is explicitly set, it is ignored for concrete classes

    Scenario: classSuffixIfAbstract is ignored when shouldBeAbstract is false
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(shouldBeAbstract = false, classSuffixIfAbstract = "Steps")
        public class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Ignored Abstract Suffix
          Scenario: Test
            Given user exists
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
         * Feature: Ignored Abstract Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
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
            }
        }
        """
