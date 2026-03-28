Feature: ClassAnnotationTestMethodOrder
  As a developer maintaining executable specifications
  I want scenarios at the Feature level to execute in their defined sequence
  So that test behavior is predictable when scenarios are not organized under Rules

  Rule: @TestMethodOrder annotation is added to every generated test class if it has at least one scenario

    Scenario: feature with no scenarios
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: Empty Feature
        This feature has no scenarios yet
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: Empty Feature
       *   This feature has no scenarios yet
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

    Scenario: feature with just one scenario
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Test Ordering
        Scenario: First scenario
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

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
       * Feature: Test Ordering
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

  Rule: Each scenario method gets @Order(1), @Order(2), etc., matching their position in the feature file.

    Scenario: multiple scenarios get sequential @Order annotations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Sequential Scenarios
        Scenario: First test
        Scenario: Second test
        Scenario: Third test
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

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
       * Feature: Sequential Scenarios
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: First test")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }

          @Test
          @Order(2)
          @Tag("new")
          @DisplayName("Scenario: Second test")
          public void scenario_2() {
              Assertions.fail("Scenario has no steps");
          }

          @Test
          @Order(3)
          @Tag("new")
          @DisplayName("Scenario: Third test")
          public void scenario_3() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

