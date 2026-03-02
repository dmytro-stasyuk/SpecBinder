Feature: ClassSuffixIfConcrete
  As a developer generating concrete test classes
  I want to customize the suffix appended to the generated class name when shouldBeAbstract is false
  So that I can follow my team's naming conventions for generated test classes

  Rule: the default suffix for concrete generated classes is "Test"
  - when shouldBeAbstract is false and classSuffixIfConcrete is not specified, the suffix "Test" is used
  - the generated class name is formed by appending the suffix to the base feature name

    Scenario: default suffix "Test" is used when classSuffixIfConcrete is not specified
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(shouldBeAbstract = false)
        public class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Default Concrete Suffix
          Scenario: Test
            Given user exists
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
         * Feature: Default Concrete Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
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

  Rule: classSuffixIfConcrete overrides the default "Test" suffix when shouldBeAbstract is false
  - the custom suffix replaces "Test" in the generated class name
  - the suffix is appended directly to the base feature name without any separator

    Scenario: custom suffix is applied to the generated concrete class name
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(shouldBeAbstract = false, classSuffixIfConcrete = "Spec")
        public class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Custom Concrete Suffix
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
         * Feature: Custom Concrete Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureSpec extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
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
                 * When user clicks button
                 */
                userClicksButton();
            }
        }
        """

  Rule: classSuffixIfConcrete has no effect when shouldBeAbstract is true
  - when shouldBeAbstract is true, the classSuffixIfAbstract option is used instead
  - even if classSuffixIfConcrete is explicitly set, it is ignored for abstract classes

    Scenario: classSuffixIfConcrete is ignored when shouldBeAbstract is true
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(shouldBeAbstract = true, classSuffixIfConcrete = "Spec")
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Ignored Concrete Suffix
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Ignored Concrete Suffix
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
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
