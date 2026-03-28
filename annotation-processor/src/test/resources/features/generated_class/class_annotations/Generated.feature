Feature: Generated
  As a developer maintaining a codebase with generated code
  I want generated test classes to be clearly marked with @Generated annotation
  So that my development tools can automatically exclude them from code coverage, static analysis, and formatting rules

  Rule: @Generated annotation value is always "dev.specbinder.processor.AnnotationProcessor".

    Scenario: generated class has @Generated annotation with processor name
      Given the following base class:
      """
      package com.example.inventory;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class StockManagement {
      }
      """
      And the following feature file:
      """
      Feature: Stock Management
        As a warehouse manager
        I want to track inventory
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.inventory;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: Stock Management
       *   As a warehouse manager
       *   I want to track inventory
       */
      @DisplayName("StockManagement")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("com/example/inventory/StockManagement.feature")
      public class StockManagementTest extends StockManagement {
      }
      """

