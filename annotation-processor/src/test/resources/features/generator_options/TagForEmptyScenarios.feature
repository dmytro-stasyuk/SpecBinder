Feature: TagForEmptyScenarios
  As a test developer using Gherkin
  I want to configure the tag applied to empty Scenarios (Scenarios without steps)
  So that I can categorize incomplete specifications with custom tags

  Rule: Empty Scenarios can be tagged with a custom tag using the "tagForEmptyScenarios" option

    Scenario: Empty scenario with custom tag
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        tagForEmptyScenarios = "todo"
      )
      public class TestFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with empty scenario

        Scenario: Not implemented yet
      """
      When the generator is run
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      package com.example;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assumptions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with empty scenario
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Test
          @Order(1)
          @Tag("todo")
          @DisplayName("Scenario: Not implemented yet")
          public void scenario_1() {
              Assumptions.assumeTrue(false, "Scenario has no steps");
          }
      }
      """

  Rule: When "tagForEmptyScenarios" is not set, empty Scenarios get a default tag "new"

    Scenario: Empty scenario with default tag
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty scenario

        Scenario: Work in progress
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with empty scenario
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Work in progress")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """
