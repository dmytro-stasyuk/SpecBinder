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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/CheckoutProcess.feature")
        public class CheckoutProcessTest extends CheckoutProcess {
            @Given("^user initiates checkout$")
            protected void userInitiatesCheckout(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^navigate to checkout page$")
            public void navigateToCheckoutPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^verify cart is not empty$")
            public void verifyCartIsNotEmpty() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^click on proceed button$")
            public void clickOnProceedButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^payment is processed$")
            public void paymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^order is confirmed$")
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/AccountManagement.feature")
        public class AccountManagementTest extends AccountManagement {
            @Given("^user (?<p1>.*) updates account details$")
            protected void user$p1UpdatesAccountDetails(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^login as user (?<p1>.*)$")
            public void loginAsUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^navigate to account settings$")
            public void navigateToAccountSettings() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^modify profile information$")
            public void modifyProfileInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^save changes for user (?<p1>.*)$")
            public void saveChangesForUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^update is submitted$")
            public void updateIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^account should be updated for (?<p1>.*)$")
            public void accountShouldBeUpdatedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Update account")
            public void scenario_1() {
                /*
                 * Given user "Alice" updates account details
                 */
                user$p1UpdatesAccountDetails("Alice", (p1) -> {
                    loginAsUser$p1(p1);
                    navigateToAccountSettings();
                    modifyProfileInformation();
                    saveChangesForUser$p1(p1);
                });
                /*
                 * When update is submitted
                 */
                updateIsSubmitted();
                /*
                 * Then account should be updated for "Alice"
                 */
                accountShouldBeUpdatedFor$p1("Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/InventoryManagement.feature")
        public class InventoryManagementTest extends InventoryManagement {
            @Given("^warehouse (?<p1>.*) receives product (?<p2>.*)$")
            protected void warehouse$p1ReceivesProduct$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^verify warehouse (?<p1>.*) is operational$")
            public void verifyWarehouse$p1IsOperational(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^check product (?<p1>.*) exists in catalog$")
            public void checkProduct$p1ExistsInCatalog(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^update stock level for (?<p1>.*) in (?<p2>.*)$")
            public void updateStockLevelFor$p1In$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^send notification about (?<p1>.*) to (?<p2>.*)$")
            public void sendNotificationAbout$p1To$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^stock is updated$")
            public void stockIsUpdated() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^inventory should reflect changes for (?<p1>.*)$")
            public void inventoryShouldReflectChangesFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Add stock")
            public void scenario_1() {
                /*
                 * Given warehouse "WH-01" receives product "Widget"
                 */
                warehouse$p1ReceivesProduct$p2("WH-01", "Widget", (p1, p2) -> {
                    verifyWarehouse$p1IsOperational(p1);
                    checkProduct$p1ExistsInCatalog(p2);
                    updateStockLevelFor$p1In$p2(p2, p1);
                    sendNotificationAbout$p1To$p2(p2, p1);
                });
                /*
                 * When stock is updated
                 */
                stockIsUpdated();
                /*
                 * Then inventory should reflect changes for "WH-01"
                 */
                inventoryShouldReflectChangesFor$p1("WH-01");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/MultiStepProcess.feature")
        public class MultiStepProcessTest extends MultiStepProcess {
            @Given("^system is initialized$")
            protected void systemIsInitialized(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @Given("^start services$")
            public void startServices() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^load configuration$")
            public void loadConfiguration() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user (?<p1>.*) performs action$")
            protected void user$p1PerformsAction(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            @When("^authenticate user (?<p1>.*)$")
            public void authenticateUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^execute operation for (?<p1>.*)$")
            public void executeOperationFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^result is successful for (?<p1>.*)$")
            public void resultIsSuccessfulFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Execute multiple composite steps")
            public void scenario_1() {
                /*
                 * Given system is initialized
                 */
                systemIsInitialized(() -> {
                    startServices();
                    loadConfiguration();
                });
                /*
                 * When user "Bob" performs action
                 */
                user$p1PerformsAction("Bob", (p1) -> {
                    authenticateUser$p1(p1);
                    executeOperationFor$p1(p1);
                });
                /*
                 * Then result is successful for "Bob"
                 */
                resultIsSuccessfulFor$p1("Bob");
            }
        }
        """


