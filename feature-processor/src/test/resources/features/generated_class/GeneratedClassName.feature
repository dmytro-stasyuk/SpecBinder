Feature: GeneratedClassName
  As a developer configuring the code generator for my project
  I want to control the suffix appended to generated test class names
  So that I can maintain consistent naming conventions that match my team's code organization patterns

  Rule: Generated class name is base class name plus suffix

    Scenario: with default suffix
      Given the following base class:
      """
      package com.example.cart;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class CartFeature {
      }
      """
      And the following feature file:
      """
      Feature: Shopping Cart
        Scenario: Add item
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.cart;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Shopping Cart
       */
      @DisplayName("CartFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/cart/CartFeature.feature")
      public class CartFeatureTest extends CartFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Add item")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: with custom suffix
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/payment.feature")
      public class PaymentFeature {
      }
      """
      And a feature file under path "features/payment.feature" with the following content:
      """
      Feature: Payment Processing
        Scenario: Process payment
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.payment.PaymentFeature;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Payment Processing
       */
      @DisplayName("payment")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/payment.feature")
      public class PaymentTest extends PaymentFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Process payment")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

