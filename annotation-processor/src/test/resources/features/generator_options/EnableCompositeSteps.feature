Feature: EnableCompositeSteps
  As a developer writing high-level BDD scenarios
  I want to optionally group sub-steps under a parent step using the * keyword
  So that I can compose reusable step abstractions without writing additional glue code

  Rule: when enableCompositeSteps is enabled, * steps become sub-steps grouped under the preceding GWT step
  - the parent GWT step generates a method with a varargs Consumer parameter
  - the * sub-steps are invoked inside a lambda passed to the parent step method
  - the composite method uses Runnable when the parent step has no parameters

    Scenario: composite step groups sub-steps into a lambda
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(enableCompositeSteps = true)
        public abstract class CheckoutProcess {

        }
        """
      And the following feature file:
        """
        Feature: Checkout Process
          Scenario: Complete checkout
            Given user initiates checkout
            * navigate to checkout page
            * verify cart is not empty
            * click on proceed button
            When payment is processed
            Then order is confirmed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Runnable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Checkout Process
         */
        @DisplayName("CheckoutProcess")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/CheckoutProcess.feature")
        public class CheckoutProcessTest extends CheckoutProcess {
            protected void userInitiatesCheckout(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void navigateToCheckoutPage() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyCartIsNotEmpty() {
                Assertions.fail("Step is not yet implemented");
            }

            public void clickOnProceedButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void paymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void orderIsConfirmed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Complete checkout")
            public void scenario_1() {
                /*
                 * Given user initiates checkout
                 */
                userInitiatesCheckout(() -> {
                    navigateToCheckoutPage();
                    verifyCartIsNotEmpty();
                    clickOnProceedButton();
                });
                /*
                 * When payment is processed
                 */
                paymentIsProcessed();
                /*
                 * Then order is confirmed
                 */
                orderIsConfirmed();
            }
        }
        """

  Rule: when enableCompositeSteps is disabled (default), * steps are treated as regular steps inheriting the preceding keyword
  - the * steps inherit the keyword of the preceding Given/When/Then step
  - no composite method or lambda is generated
  - each * step becomes a standalone method call in the scenario body

    Scenario: * steps are treated as regular steps when option is disabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(enableCompositeSteps = false)
        public abstract class CheckoutProcess {

        }
        """
      And the following feature file:
        """
        Feature: Checkout Process
          Scenario: Complete checkout
            Given user initiates checkout
            * navigate to checkout page
            * verify cart is not empty
            * click on proceed button
            When payment is processed
            Then order is confirmed
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Checkout Process
         */
        @DisplayName("CheckoutProcess")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/CheckoutProcess.feature")
        public class CheckoutProcessTest extends CheckoutProcess {
            public void userInitiatesCheckout() {
                Assertions.fail("Step is not yet implemented");
            }

            public void navigateToCheckoutPage() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyCartIsNotEmpty() {
                Assertions.fail("Step is not yet implemented");
            }

            public void clickOnProceedButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void paymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void orderIsConfirmed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Complete checkout")
            public void scenario_1() {
                /*
                 * Given user initiates checkout
                 */
                userInitiatesCheckout();
                /*
                 * * navigate to checkout page
                 */
                navigateToCheckoutPage();
                /*
                 * * verify cart is not empty
                 */
                verifyCartIsNotEmpty();
                /*
                 * * click on proceed button
                 */
                clickOnProceedButton();
                /*
                 * When payment is processed
                 */
                paymentIsProcessed();
                /*
                 * Then order is confirmed
                 */
                orderIsConfirmed();
            }
        }
        """
