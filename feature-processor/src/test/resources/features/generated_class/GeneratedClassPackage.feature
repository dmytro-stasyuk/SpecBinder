Feature: GeneratedClassPackage
  As a developer navigating between feature specifications and generated test code
  I want generated test classes to mirror the package structure of their source feature files
  So that I can quickly locate the generated code and maintain clear traceability between specifications and implementation

  Rule: Package name is based on the path/package of where the feature feature file is located

    Scenario: path of the feature file is different to the package of the annotated class
      Given the following base class:
      """
      package com.example.cart;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/checkout/cart/cart.feature")
      public abstract class CartFeature {
      }
      """
      And a feature file under path "features/checkout/cart/cart.feature" with the following content:
      """
      Feature: Shopping Cart
        Scenario: Add item
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features.checkout.cart;

      import com.example.cart.CartFeature;
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
       * Feature: Shopping Cart
       */
      @DisplayName("cart")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/checkout/cart/cart.feature")
      public class CartTest extends CartFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Add item")
          public void scenario_1() {
              Assumptions.assumeTrue(false, "Scenario has no steps");
          }
      }
      """



