Feature: CompositeStepsAndCucumberAnnotations
  As a developer using composite steps in my feature files
  I want for the cucumber steps to optionally be also annotated with Given/When/Then cucumber annotations containing
  the regular expression pattern of the composite step similar to regular steps
  So that I can maintain compatibility with Cucumber-based tools and frameworks that rely on these annotations for step definition mapping

  Rule: Cucumber step annotations are added to composite step methods when addCucumberStepAnnotations is true
    - the value for the step regular expression pattern is derived from the composite step text in the similar manner as for regular steps

    Scenario: Composite step with no parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
          enableCompositeSteps = true,
          addCucumberStepAnnotations = true
      )
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

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/CheckoutProcess.feature")
        public class CheckoutProcessTest extends CheckoutProcess {
            @Given("^user initiates checkout$")
            protected void givenUserInitiatesCheckout(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^navigate to checkout page$")
            public void givenNavigateToCheckoutPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^verify cart is not empty$")
            public void givenVerifyCartIsNotEmpty() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^click on proceed button$")
            public void givenClickOnProceedButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^payment is processed$")
            public void whenPaymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^order is confirmed$")
            public void thenOrderIsConfirmed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Complete checkout")
            public void scenario_1() {
                /*
                 * Given user initiates checkout
                 */
                givenUserInitiatesCheckout(() -> {
                    givenNavigateToCheckoutPage();
                    givenVerifyCartIsNotEmpty();
                    givenClickOnProceedButton();
                });
                /*
                 * When payment is processed
                 */
                whenPaymentIsProcessed();
                /*
                 * Then order is confirmed
                 */
                thenOrderIsConfirmed();
            }
        }
        """

    Scenario: Composite step with one parameter
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
          enableCompositeSteps = true,
          addCucumberStepAnnotations = true
      )
      public abstract class AccountManagement {

      }
      """
      And the following feature file:
      """
      Feature: Account Management
        Scenario: Update account
          Given user "Alice" updates account details
          * login as user $p1
          * navigate to account settings
          * modify profile information
          * save changes for user $p1
          When update is submitted
          Then account should be updated for "Alice"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
        import java.lang.String;
        import java.util.function.Consumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Account Management
         */
        @DisplayName("AccountManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/AccountManagement.feature")
        public class AccountManagementTest extends AccountManagement {
            @Given("^user (?<p1>.*) updates account details$")
            protected void givenUser$p1UpdatesAccountDetails(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^login as user (?<p1>.*)$")
            public void givenLoginAsUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^navigate to account settings$")
            public void givenNavigateToAccountSettings() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^modify profile information$")
            public void givenModifyProfileInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^save changes for user (?<p1>.*)$")
            public void givenSaveChangesForUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^update is submitted$")
            public void whenUpdateIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^account should be updated for (?<p1>.*)$")
            public void thenAccountShouldBeUpdatedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Update account")
            public void scenario_1() {
                /*
                 * Given user "Alice" updates account details
                 */
                givenUser$p1UpdatesAccountDetails("Alice", (p1) -> {
                    givenLoginAsUser$p1(p1);
                    givenNavigateToAccountSettings();
                    givenModifyProfileInformation();
                    givenSaveChangesForUser$p1(p1);
                });
                /*
                 * When update is submitted
                 */
                whenUpdateIsSubmitted();
                /*
                 * Then account should be updated for "Alice"
                 */
                thenAccountShouldBeUpdatedFor$p1("Alice");
            }
        }
        """

    Scenario: Composite step with two parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
          enableCompositeSteps = true,
          addCucumberStepAnnotations = true
      )
      public abstract class InventoryManagement {

      }
      """
      And the following feature file:
      """
      Feature: Inventory Management
        Scenario: Add stock
          Given warehouse "WH-01" receives product "Widget"
          * verify warehouse $p1 is operational
          * check product $p2 exists in catalog
          * update stock level for $p2 in $p1
          * send notification about $p2 to $p1
          When stock is updated
          Then inventory should reflect changes for "WH-01"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
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
         * Feature: Inventory Management
         */
        @DisplayName("InventoryManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/InventoryManagement.feature")
        public class InventoryManagementTest extends InventoryManagement {
            @Given("^warehouse (?<p1>.*) receives product (?<p2>.*)$")
            protected void givenWarehouse$p1ReceivesProduct$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^verify warehouse (?<p1>.*) is operational$")
            public void givenVerifyWarehouse$p1IsOperational(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^check product (?<p1>.*) exists in catalog$")
            public void givenCheckProduct$p1ExistsInCatalog(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^update stock level for (?<p1>.*) in (?<p2>.*)$")
            public void givenUpdateStockLevelFor$p1In$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^send notification about (?<p1>.*) to (?<p2>.*)$")
            public void givenSendNotificationAbout$p1To$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^stock is updated$")
            public void whenStockIsUpdated() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^inventory should reflect changes for (?<p1>.*)$")
            public void thenInventoryShouldReflectChangesFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Add stock")
            public void scenario_1() {
                /*
                 * Given warehouse "WH-01" receives product "Widget"
                 */
                givenWarehouse$p1ReceivesProduct$p2("WH-01", "Widget", (p1, p2) -> {
                    givenVerifyWarehouse$p1IsOperational(p1);
                    givenCheckProduct$p1ExistsInCatalog(p2);
                    givenUpdateStockLevelFor$p1In$p2(p2, p1);
                    givenSendNotificationAbout$p1To$p2(p2, p1);
                });
                /*
                 * When stock is updated
                 */
                whenStockIsUpdated();
                /*
                 * Then inventory should reflect changes for "WH-01"
                 */
                thenInventoryShouldReflectChangesFor$p1("WH-01");
            }
        }
        """

    Scenario: Multiple composite steps with source line comments
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
          enableCompositeSteps = true,
          addCucumberStepAnnotations = true
      )
      public abstract class MultiStepProcess {

      }
      """
      And the following feature file:
      """
      Feature: Multi Step Process
        Scenario: Execute multiple composite steps
          Given system is initialized
          * start services
          * load configuration
          When user "Bob" performs action
          * authenticate user $p1
          * execute operation for $p1
          Then result is successful for "Bob"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
        import java.lang.Runnable;
        import java.lang.String;
        import java.util.function.Consumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multi Step Process
         */
        @DisplayName("MultiStepProcess")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/MultiStepProcess.feature")
        public class MultiStepProcessTest extends MultiStepProcess {
            @Given("^system is initialized$")
            protected void givenSystemIsInitialized(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^start services$")
            public void givenStartServices() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^load configuration$")
            public void givenLoadConfiguration() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user (?<p1>.*) performs action$")
            protected void whenUser$p1PerformsAction(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @When("^authenticate user (?<p1>.*)$")
            public void whenAuthenticateUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^execute operation for (?<p1>.*)$")
            public void whenExecuteOperationFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^result is successful for (?<p1>.*)$")
            public void thenResultIsSuccessfulFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Execute multiple composite steps")
            public void scenario_1() {
                /*
                 * Given system is initialized
                 */
                givenSystemIsInitialized(() -> {
                    givenStartServices();
                    givenLoadConfiguration();
                });
                /*
                 * When user "Bob" performs action
                 */
                whenUser$p1PerformsAction("Bob", (p1) -> {
                    whenAuthenticateUser$p1(p1);
                    whenExecuteOperationFor$p1(p1);
                });
                /*
                 * Then result is successful for "Bob"
                 */
                thenResultIsSuccessfulFor$p1("Bob");
            }
        }
        """


