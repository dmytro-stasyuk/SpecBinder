Feature: AddSourceLineBeforeStepCalls
  As a developer
  I want to optionally include source line numbers in block comments at step method call sites
  So that I can easily trace generated code back to the original feature file lines

  Rule: When addSourceLineBeforeStepCalls is enabled, source line numbers are added to block comments
  - each step call block comment includes the line number where the step appears in the feature file
  - format is "(source line - X)" on a separate line in the comment
  - this helps developers navigate from generated code back to feature file

    Scenario: Source line comments are added when option is enabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Source Line Comments
          Scenario: Test
            Given user exists
            When user clicks button
            Then result is displayed
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Source Line Comments
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                userExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                userClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 5)
                 */
                resultIsDisplayed();
            }
        }
        """

  Rule: addSourceLineBeforeStepCalls works independently of addSourceLineAnnotations
  - addSourceLineBeforeStepCalls only affects block comments, not @SourceLine annotations
  - addSourceLineAnnotations only affects @SourceLine annotations, not block comments
  - both options can be enabled or disabled independently

    Scenario: Only source line comments are added, not @SourceLine annotations
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true, addSourceLineAnnotations = false)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Independent Options
          Scenario: Test
            Given user exists
            When user clicks button
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Independent Options
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                userExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                userClicksButton();
            }
        }
        """

    Scenario: Source line comments work with multiple steps
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineBeforeStepCalls = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Multiple Steps
          Scenario: Test
            Given user exists
            And user is active
            When user clicks button
            Then result is displayed
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 * (source line - 3)
                 */
                userExists();
                /*
                 * And user is active
                 * (source line - 4)
                 */
                userIsActive();
                /*
                 * When user clicks button
                 * (source line - 5)
                 */
                userClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 6)
                 */
                resultIsDisplayed();
            }
        }
        """

  Rule: When addSourceLineBeforeStepCalls is disabled (default), no source line information appears in block comments
  - block comments above step calls contain only the step text
  - no line numbers are included in the comments
  - this is the default behavior to keep generated code clean

    Scenario: Source line comments are not added when option is disabled (default)
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Default Behavior
          Scenario: Test
            Given user exists
            When user clicks button
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Default Behavior
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When user clicks button
                 */
                userClicksButton();
                /*
                 * Then result is displayed
                 */
                resultIsDisplayed();
            }
        }
        """
  Rule: Source line comments are added to composite step calls when addSourceLineBeforeStepCalls is enabled
  - the source line refers to where the composite step is called in the feature file
  - individual steps within composite steps do not get additional source line comments

    Scenario: Composite step with no parameters and source line comments
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineBeforeStepCalls = true)
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
                 * (source line - 3)
                 */
                userInitiatesCheckout(() -> {
                    navigateToCheckoutPage();
                    verifyCartIsNotEmpty();
                    clickOnProceedButton();
                });
                /*
                 * When payment is processed
                 * (source line - 7)
                 */
                paymentIsProcessed();
                /*
                 * Then order is confirmed
                 * (source line - 8)
                 */
                orderIsConfirmed();
            }
        }
        """

    Scenario: Composite step with one parameter and source line comments
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineBeforeStepCalls = true)
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
            protected void user$p1UpdatesAccountDetails(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void loginAsUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void navigateToAccountSettings() {
                Assertions.fail("Step is not yet implemented");
            }

            public void modifyProfileInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            public void saveChangesForUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void updateIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            public void accountShouldBeUpdatedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Update account")
            public void scenario_1() {
                /*
                 * Given user "Alice" updates account details
                 * (source line - 3)
                 */
                user$p1UpdatesAccountDetails("Alice", (p1) -> {
                    loginAsUser$p1(p1);
                    navigateToAccountSettings();
                    modifyProfileInformation();
                    saveChangesForUser$p1(p1);
                });
                /*
                 * When update is submitted
                 * (source line - 8)
                 */
                updateIsSubmitted();
                /*
                 * Then account should be updated for "Alice"
                 * (source line - 9)
                 */
                accountShouldBeUpdatedFor$p1("Alice");
            }
        }
        """

    Scenario: Composite step with two parameters and source line comments
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineBeforeStepCalls = true)
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
            protected void warehouse$p1ReceivesProduct$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyWarehouse$p1IsOperational(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkProduct$p1ExistsInCatalog(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void updateStockLevelFor$p1In$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendNotificationAbout$p1To$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void stockIsUpdated() {
                Assertions.fail("Step is not yet implemented");
            }

            public void inventoryShouldReflectChangesFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Add stock")
            public void scenario_1() {
                /*
                 * Given warehouse "WH-01" receives product "Widget"
                 * (source line - 3)
                 */
                warehouse$p1ReceivesProduct$p2("WH-01", "Widget", (p1, p2) -> {
                    verifyWarehouse$p1IsOperational(p1);
                    checkProduct$p1ExistsInCatalog(p2);
                    updateStockLevelFor$p1In$p2(p2, p1);
                    sendNotificationAbout$p1To$p2(p2, p1);
                });
                /*
                 * When stock is updated
                 * (source line - 8)
                 */
                stockIsUpdated();
                /*
                 * Then inventory should reflect changes for "WH-01"
                 * (source line - 9)
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
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineBeforeStepCalls = true)
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
            protected void systemIsInitialized(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void startServices() {
                Assertions.fail("Step is not yet implemented");
            }

            public void loadConfiguration() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void user$p1PerformsAction(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void authenticateUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void executeOperationFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsSuccessfulFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Execute multiple composite steps")
            public void scenario_1() {
                /*
                 * Given system is initialized
                 * (source line - 3)
                 */
                systemIsInitialized(() -> {
                    startServices();
                    loadConfiguration();
                });
                /*
                 * When user "Bob" performs action
                 * (source line - 6)
                 */
                user$p1PerformsAction("Bob", (p1) -> {
                    authenticateUser$p1(p1);
                    executeOperationFor$p1(p1);
                });
                /*
                 * Then result is successful for "Bob"
                 * (source line - 9)
                 */
                resultIsSuccessfulFor$p1("Bob");
            }
        }
        """