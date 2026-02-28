Feature: FailScenariosWithNoSteps
  As a test developer using Gherkin
  I want to configure how empty Scenarios (Scenarios without steps) are handled
  So that I can control test behavior and tag incomplete specifications

  Rule: Empty Scenarios generate a failing test method when "failScenariosWithNoSteps" option is enabled

    Scenario: with failScenariosWithNoSteps = enabled
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        failScenariosWithNoSteps = true
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty scenario

        Scenario: Future implementation
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Future implementation")
          public void scenario_1() {
              Assumptions.assumeTrue(false, "Scenario has no steps");
          }
      }
      """

    Scenario: Empty scenario with failScenariosWithNoSteps disabled
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        failScenariosWithNoSteps = false
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty scenario

        Scenario: Placeholder test
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with empty scenario
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Placeholder test")
          public void scenario_1() {
          }
      }
      """
