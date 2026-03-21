Feature: GeneratedClassName
  As a developer using the code generator
  I want the generated test class name to be derived from the feature file name plus a configurable suffix
  So that I can maintain consistent naming conventions that match my team's code organization patterns

  Rule: Generated class name is feature file name plus suffix

    Scenario: with default suffix
      Given the following base class:
      """
      package com.example.cart;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("com/example/cart/CartFeature.feature")
      public abstract class CartFeature {
      }
      """
      And a feature file under path "com/example/cart/CartFeature.feature" with the following content:
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
      @Feature2JUnitOptions(shouldBeAbstract = false, classSuffixIfConcrete = "Spec")
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
      public class PaymentSpec extends PaymentFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Process payment")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

  Rule: Feature file name is sanitized before forming the generated class name
  - characters that are not valid in a Java class name are removed
  - the first character is capitalized to follow Java class naming conventions

    Scenario: hyphens are removed and next letter is capitalized
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("com/example/my-shopping-cart.feature")
      public abstract class MyFeature {
      }
      """
      And a feature file under path "com/example/my-shopping-cart.feature" with the following content:
      """
      Feature: My Shopping Cart
        Scenario: Add item
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: My Shopping Cart
       */
      @DisplayName("my-shopping-cart")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/my-shopping-cart.feature")
      public class MyShoppingCartTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Add item")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: dots are treated as word separators
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("com/example/user.login.feature")
      public abstract class MyFeature {
      }
      """
      And a feature file under path "com/example/user.login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Valid credentials
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: User Login
       */
      @DisplayName("user.login")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/user.login.feature")
      public class UserLoginTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Valid credentials")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: special characters are removed
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("com/example/cart@v2!.feature")
      public abstract class MyFeature {
      }
      """
      And a feature file under path "com/example/cart@v2!.feature" with the following content:
      """
      Feature: Cart V2
        Scenario: Add item
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Cart V2
       */
      @DisplayName("cart@v2!")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/cart@v2!.feature")
      public class Cartv2Test extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Add item")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: leading digits are removed
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("com/example/123checkout.feature")
      public abstract class MyFeature {
      }
      """
      And a feature file under path "com/example/123checkout.feature" with the following content:
      """
      Feature: Checkout
        Scenario: Complete order
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Checkout
       */
      @DisplayName("123checkout")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/123checkout.feature")
      public class CheckoutTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: Complete order")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

