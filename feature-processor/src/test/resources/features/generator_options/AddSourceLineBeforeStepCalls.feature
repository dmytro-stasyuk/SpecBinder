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
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenResultIsDisplayed() {
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
                givenUserExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 5)
                 */
                thenResultIsDisplayed();
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
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
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
                givenUserExists();
                /*
                 * When user clicks button
                 * (source line - 4)
                 */
                whenUserClicksButton();
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
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenUserIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenResultIsDisplayed() {
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
                givenUserExists();
                /*
                 * And user is active
                 * (source line - 4)
                 */
                givenUserIsActive();
                /*
                 * When user clicks button
                 * (source line - 5)
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 * (source line - 6)
                 */
                thenResultIsDisplayed();
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
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenResultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * When user clicks button
                 */
                whenUserClicksButton();
                /*
                 * Then result is displayed
                 */
                thenResultIsDisplayed();
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
            protected void givenUserInitiatesCheckout(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenNavigateToCheckoutPage() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenVerifyCartIsNotEmpty() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenClickOnProceedButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenPaymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenOrderIsConfirmed() {
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
                givenUserInitiatesCheckout(() -> {
                    givenNavigateToCheckoutPage();
                    givenVerifyCartIsNotEmpty();
                    givenClickOnProceedButton();
                });
                /*
                 * When payment is processed
                 * (source line - 7)
                 */
                whenPaymentIsProcessed();
                /*
                 * Then order is confirmed
                 * (source line - 8)
                 */
                thenOrderIsConfirmed();
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
            protected void givenUser$p1UpdatesAccountDetails(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenLoginAsUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenNavigateToAccountSettings() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenModifyProfileInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSaveChangesForUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUpdateIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenAccountShouldBeUpdatedFor$p1(String p1) {
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
                givenUser$p1UpdatesAccountDetails("Alice", (p1) -> {
                    givenLoginAsUser$p1(p1);
                    givenNavigateToAccountSettings();
                    givenModifyProfileInformation();
                    givenSaveChangesForUser$p1(p1);
                });
                /*
                 * When update is submitted
                 * (source line - 8)
                 */
                whenUpdateIsSubmitted();
                /*
                 * Then account should be updated for "Alice"
                 * (source line - 9)
                 */
                thenAccountShouldBeUpdatedFor$p1("Alice");
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
            protected void givenWarehouse$p1ReceivesProduct$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenVerifyWarehouse$p1IsOperational(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCheckProduct$p1ExistsInCatalog(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenUpdateStockLevelFor$p1In$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendNotificationAbout$p1To$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenStockIsUpdated() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenInventoryShouldReflectChangesFor$p1(String p1) {
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
                givenWarehouse$p1ReceivesProduct$p2("WH-01", "Widget", (p1, p2) -> {
                    givenVerifyWarehouse$p1IsOperational(p1);
                    givenCheckProduct$p1ExistsInCatalog(p2);
                    givenUpdateStockLevelFor$p1In$p2(p2, p1);
                    givenSendNotificationAbout$p1To$p2(p2, p1);
                });
                /*
                 * When stock is updated
                 * (source line - 8)
                 */
                whenStockIsUpdated();
                /*
                 * Then inventory should reflect changes for "WH-01"
                 * (source line - 9)
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
            protected void givenSystemIsInitialized(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenStartServices() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenLoadConfiguration() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void whenUser$p1PerformsAction(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void whenAuthenticateUser$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenExecuteOperationFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenResultIsSuccessfulFor$p1(String p1) {
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
                givenSystemIsInitialized(() -> {
                    givenStartServices();
                    givenLoadConfiguration();
                });
                /*
                 * When user "Bob" performs action
                 * (source line - 6)
                 */
                whenUser$p1PerformsAction("Bob", (p1) -> {
                    whenAuthenticateUser$p1(p1);
                    whenExecuteOperationFor$p1(p1);
                });
                /*
                 * Then result is successful for "Bob"
                 * (source line - 9)
                 */
                thenResultIsSuccessfulFor$p1("Bob");
            }
        }
        """