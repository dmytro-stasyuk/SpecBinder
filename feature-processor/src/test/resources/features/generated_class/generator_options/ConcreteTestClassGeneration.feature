Feature: ConcreteTestClassGeneration
  As a developer
  I want step method bodies to be generated based on the shouldBeAbstract option
  So that I can choose between abstract step methods or concrete methods with fail() statements

  Rule: When shouldBeAbstract is false, generated class is not abstract and method stubs contain failing assertions

    Scenario: Concrete step method with fail() statement
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
        Feature: Concrete Steps
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
         * Feature: Concrete Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
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
            }
        }
        """

    Scenario: Concrete step method with parameters and fail() statement
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
        Feature: Concrete Steps With Parameters
          Scenario: Test
            When user "Alice" logs in with password "secret123"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Concrete Steps With Parameters
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void whenUser$p1LogsInWithPassword$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user "Alice" logs in with password "secret123"
                 */
                whenUser$p1LogsInWithPassword$p2("Alice", "secret123");
            }
        }
        """
