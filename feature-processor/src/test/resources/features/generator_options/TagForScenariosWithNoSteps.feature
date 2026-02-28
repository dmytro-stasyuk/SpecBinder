Feature: TagForScenariosWithNoSteps
  As a test developer using Gherkin
  I want to configure the tag applied to empty Scenarios (Scenarios without steps)
  So that I can categorize incomplete specifications with custom tags

  Rule: Empty Scenarios can be tagged with a custom tag using the "tagForScenariosWithNoSteps" option

    Scenario: Empty scenario with custom tag
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        tagForScenariosWithNoSteps = "todo"
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
          @Tag("todo")
          @DisplayName("Scenario: Not implemented yet")
          public void scenario_1() {
              Assumptions.assumeTrue(false, "Scenario has no steps");
          }
      }
      """

  Rule: When "tagForScenariosWithNoSteps" is not set, empty Scenarios get a default tag "new"

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
          @DisplayName("Scenario: Work in progress")
          public void scenario_1() {
              Assumptions.assumeTrue(false, "Scenario has no steps");
          }
      }
      """

  Rule: The custom tag for empty Scenarios works independently of the failScenariosWithNoSteps option

    Scenario: Empty scenario with custom tag but failScenariosWithNoSteps disabled
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        failScenariosWithNoSteps = false,
        tagForScenariosWithNoSteps = "wip"
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty scenario

        Scenario: Under construction
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
          @Tag("wip")
          @DisplayName("Scenario: Under construction")
          public void scenario_1() {
          }
      }
      """
