Feature: SourceFilePath
  As a developer navigating between generated tests and their source specifications
  I want the generated test class to be annotated with the path to its originating feature file
  So that I can quickly locate and edit the corresponding feature file when reviewing or debugging tests

  Scenario: explicit feature file path is specified
    Given the following base class:
      """
      package com.example.shop;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit("features/shopping/cart.feature")
      public abstract class CartFeatureBase {
      }
      """
    And a feature file under path "features/shopping/cart.feature" with the following content:
      """
      Feature: Shopping Cart Management
        As a customer
        I want to manage items in my cart
      """
    When the generator is run
    Then the following class should be generated:
      """
      package features.shopping;

      import com.example.shop.CartFeatureBase;
      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: Shopping Cart Management
       *   As a customer
       *   I want to manage items in my cart
       */
      @DisplayName("cart")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/shopping/cart.feature")
      public class CartTest extends CartFeatureBase {
      }
      """

  Rule: when the @Gherkin2JUnit annotation value is blank, the path is constructed from package and class name of the annotated class

    Scenario: value is blank
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class PaymentProcessing {
      }
      """
      And a feature file under path "com/example/payment/TestFeature.feature" with the following content:
      """
      Feature: Payment Processing
        As a payment system
        I want to process payments
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.payment;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: Payment Processing
       *   As a payment system
       *   I want to process payments
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends PaymentProcessing {
      }
      """

  Rule: when value specified in @Gherkin2JUnit doesn't match any feature files and error should be reported

    Scenario: feature file path specified but file does not exist
      Given the following base class:
      """
      package com.example.nonexistent;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit("features/nonexistent/missing.feature")
      public abstract class MissingFeature {
      }
      """
      And a feature file under path "features/shopping/cart.feature" with the following content:
      """
      Feature: Shopping Cart Management
        As a customer
        I want to manage items in my cart
      """
      When the generator is run
      Then the generator should report an error:
      """
      No feature file found for path 'features/nonexistent/missing.feature'
      """
