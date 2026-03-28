Feature: CompositeSteps
  As a developer using the Gherkin2JUnit generator
  I want to use composite step pattern to group related sub-steps under a higher-level abstraction
  So that I can create reusable step compositions without implementing additional glue code, similar to JBehave's textual composite steps



#
#    Call site generation with lambda:
#    - In test methods, composite steps are invoked with the extracted parameter values
#    - A lambda expression is added as the last argument, containing the sub-step method calls
#    - The lambda parameters match the number of parameters from the parent step (p1, p2, etc.)
#    - Sub-step calls within the lambda use the lambda parameters when $pN references are present
#    - The lambda body is properly indented and formatted
#
#    Consumer functional interface selection:
#    - Zero parameters: Runnable is used
#    - One parameter: Consumer<String> is used
#    - Two parameters: BiConsumer<String, String> is used
#    - Three or more parameters: Custom functional interfaces (TriConsumer, QuadConsumer, etc.) are used
#    - All Consumer parameters use varargs syntax (...composite)
#
#    Method naming:
#    - Composite step methods use the same naming conventions as regular step methods
#    - Quoted parameters in the parent step text are replaced with $p1, $p2, $p3, etc. in the method name
#    - For example: "customer "Alice" has product "Laptop" in cart" becomes customer$p1HasProduct$p2InCart
#    - Method parameter names are then positionally referred to by p1, p2, etc.
#    - Standard camelCase conversion rules apply
#    - Keywords (Given/When/Then/And/But) are removed from method names
#
#    Required imports:
#    - java.util.function.Consumer (for single parameter)
#    - java.util.function.BiConsumer (for two parameters)
#    - Custom functional interfaces for 3+ parameters (TriConsumer, QuadConsumer, PentaConsumer)
#    - static import for java.util.Arrays.stream
#
#    Integration with existing features:
#    - Composite steps work with tags, scenarios, rules, and backgrounds
#    - Sub-steps can have their own parameters (quoted strings) in addition to $pN references
#    - Sub-steps generate their own step methods as usual
#    - Step deduplication applies to sub-step methods
#    - Source line annotations and comments work within composite step structures

  Scenario: first scenario
    Given the following base class:
    """
    package com.example2;

    import dev.specbinder.annotations.Gherkin2JUnit;
    import dev.specbinder.annotations.Gherkin2JUnitOptions;

    @Gherkin2JUnit
    @Gherkin2JUnitOptions(enableCompositeSteps = true)
    public abstract class MyTestFeature {

    }
    """
    And the following feature file:
    """
    Feature: User Management
        Scenario: Create new user
        Given admin "Bob" wants to create a new user
        * navigate to "User Management" page
        * click on "Create User" button
        * fill in user details for "$p1"
        * submit the form
        * verify user "$p1" is created
    """
    When the generator is run

  Scenario: Composite step with two parameters using BiConsumer
    Given the following base class:
    """
    package com.example;

    import dev.specbinder.annotations.Gherkin2JUnit;
    import dev.specbinder.annotations.Gherkin2JUnitOptions;

    @Gherkin2JUnit("features/*.feature")
    @Gherkin2JUnitOptions(enableCompositeSteps = true)
    public abstract class TestFeature {

    }
    """
    And a feature file under path "features/ShoppingCart.feature" with the following content:
      """
      Feature: Shopping Cart
        Scenario: Add product to cart
          Given customer "Alice" has product "Laptop" in shopping cart
          * login as customer $p1
          * search for product $p2
          * add product to cart
          * verify cart contains $p2
          When customer proceeds to checkout
          * click on button "Checkout"
          * select payment method "Credit Card"
          * click on the "Confirm Order" button
          Then order is confirmed
      """
    When the generator is run
#    Then a class named "ShoppingCartTest" should be generated with content:
    Then the following class should be generated:
      """
      package features;

      import static java.util.Arrays.stream;

      import com.example.TestFeature;
      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Runnable;
      import java.lang.String;
      import java.util.function.BiConsumer;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Shopping Cart
       */
      @DisplayName("ShoppingCart")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ShoppingCart.feature")
      public class ShoppingCartTest extends TestFeature {
          protected void customer$p1HasProduct$p2InShoppingCart(String p1, String p2,
                  BiConsumer<String, String>... composite) {
              if (composite.length > 0) {
                  stream(composite).forEach(action -> action.accept(p1, p2));
              } else {
                  Assertions.fail("Step is not yet implemented");
              }
          }

          public void loginAsCustomer$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void searchForProduct$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void addProductToCart() {
              Assertions.fail("Step is not yet implemented");
          }

          public void verifyCartContains$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          protected void customerProceedsToCheckout(Runnable... composite) {
              if (composite.length > 0) {
                  stream(composite).forEach(r -> r.run());
              } else {
                  Assertions.fail("Step is not yet implemented");
              }
          }

          public void clickOnButton$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void selectPaymentMethod$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void clickOnThe$p1Button(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void orderIsConfirmed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Add product to cart")
          public void scenario_1() {
              /*
               * Given customer "Alice" has product "Laptop" in shopping cart
               */
              customer$p1HasProduct$p2InShoppingCart("Alice", "Laptop", (p1, p2) -> {
                  loginAsCustomer$p1(p1);
                  searchForProduct$p1(p2);
                  addProductToCart();
                  verifyCartContains$p1(p2);
              });
              /*
               * When customer proceeds to checkout
               */
              customerProceedsToCheckout(() -> {
                  clickOnButton$p1("Checkout");
                  selectPaymentMethod$p1("Credit Card");
                  clickOnThe$p1Button("Confirm Order");
              });
              /*
               * Then order is confirmed
               */
              orderIsConfirmed();
          }
      }
      """
