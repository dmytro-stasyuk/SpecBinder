Feature: ClassAnnotationTestClassOrder
  As a developer maintaining features with ordered business rules
  I want @TestClassOrder annotation to be added when the feature contains Rules
  So that the generated nested test classes execute in the same sequence as defined in the feature file

  Rule: @TestClassOrder annotation is added only when the feature contains Rules

    Scenario: feature file without any Rules
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class SimpleFeature {
      }
      """
      And the following feature file:
      """
      Feature: Simple Feature
        Scenario: Only scenario
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
       * Feature: Simple Feature
       */
      @DisplayName("SimpleFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/SimpleFeature.feature")
      public class SimpleFeatureTest extends SimpleFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Only scenario")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: feature file with single rule
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class BusinessRules {
      }
      """
      And the following feature file:
      """
      Feature: Business Rules
        Rule: First rule
          Scenario: First scenario
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Business Rules
       */
      @DisplayName("BusinessRules")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/BusinessRules.feature")
      public class BusinessRulesTest extends BusinessRules {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: First rule")
          public class Rule_1 {
              @Test
              @Order(1)
              @Tag("new")
              @DisplayName("Scenario: First scenario")
              public void scenario_1() {
                  Assertions.fail("Scenario has no steps");
              }
          }
      }
      """

  Rule: each nested Rule class gets @Order(1), @Order(2), etc., matching their position in the feature file.

    Scenario: feature with 3 rules
      Given the following base class:
      """
      package com.example.workflow;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class WorkflowTests {
      }
      """
      And the following feature file:
      """
      Feature: Workflow Processing
        Rule: Validation rules
          Scenario: Validate input

        Rule: Processing rules
          Scenario: Process data

        Rule: Output rules
          Scenario: Generate output
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.workflow;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Workflow Processing
       */
      @DisplayName("WorkflowTests")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/workflow/WorkflowTests.feature")
      public class WorkflowTestsTest extends WorkflowTests {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Validation rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @Tag("new")
              @DisplayName("Scenario: Validate input")
              public void scenario_1() {
                  Assertions.fail("Scenario has no steps");
              }
          }

          @Nested
          @Order(2)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Processing rules")
          public class Rule_2 {
              @Test
              @Order(1)
              @Tag("new")
              @DisplayName("Scenario: Process data")
              public void scenario_1() {
                  Assertions.fail("Scenario has no steps");
              }
          }

          @Nested
          @Order(3)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Output rules")
          public class Rule_3 {
              @Test
              @Order(1)
              @Tag("new")
              @DisplayName("Scenario: Generate output")
              public void scenario_1() {
                  Assertions.fail("Scenario has no steps");
              }
          }
      }
      """


