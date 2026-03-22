Feature: AddSourceLineNumbers
  As a developer navigating generated test code
  I want source line numbers embedded in @DisplayName annotations and step block comments
  So that I can see at a glance where each element is defined in the feature file when viewing test results

  Rule: when addSourceLineNumbers is enabled, source line numbers are embedded in @DisplayName annotations on scenario methods and in step block comments

    Scenario: source line numbers appear in @DisplayName and step comments
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Source Line Numbers
          Scenario: Test
            Given user exists
            When user clicks button
            Then result is displayed
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
         * Feature: Source Line Numbers
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
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
            @DisplayName("Scenario [2]: Test")
            public void scenario_1() {
                /*
                 * [3] Given user exists
                 */
                userExists();
                /*
                 * [4] When user clicks button
                 */
                userClicksButton();
                /*
                 * [5] Then result is displayed
                 */
                resultIsDisplayed();
            }
        }
        """

    Scenario: source line numbers with multiple steps including And keyword
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
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
            @DisplayName("Scenario [2]: Test")
            public void scenario_1() {
                /*
                 * [3] Given user exists
                 */
                userExists();
                /*
                 * [4] And user is active
                 */
                userIsActive();
                /*
                 * [5] When user clicks button
                 */
                userClicksButton();
                /*
                 * [6] Then result is displayed
                 */
                resultIsDisplayed();
            }
        }
        """

  Rule: when addSourceLineNumbers is enabled, source line numbers are also embedded in @DisplayName annotations on Rule @Nested inner classes

    Scenario: source line number is embedded in Rule's @DisplayName
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Rules With Source Lines
          Rule: user management
            Scenario: Test
              Given user exists
              When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Rules With Source Lines
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Nested
            @Order(1)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule [2]: user management")
            public class Rule_1 {
                @Test
                @Order(1)
                @DisplayName("Scenario [3]: Test")
                public void scenario_1() {
                    /*
                     * [4] Given user exists
                     */
                    userExists();
                    /*
                     * [5] When user clicks button
                     */
                    userClicksButton();
                }
            }
        }
        """

    Scenario: source line numbers are embedded in @DisplayName of multiple Rules with correct line numbers
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Multiple Rules With Source Lines
          Rule: first rule
            Scenario: First test
              Given user exists
          Rule: second rule
            Scenario: Second test
              When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Rules With Source Lines
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Nested
            @Order(1)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule [2]: first rule")
            public class Rule_1 {
                @Test
                @Order(1)
                @DisplayName("Scenario [3]: First test")
                public void scenario_1() {
                    /*
                     * [4] Given user exists
                     */
                    userExists();
                }
            }

            @Nested
            @Order(2)
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule [5]: second rule")
            public class Rule_2 {
                @Test
                @Order(1)
                @DisplayName("Scenario [6]: Second test")
                public void scenario_1() {
                    /*
                     * [7] When user clicks button
                     */
                    userClicksButton();
                }
            }
        }
        """

  Rule: when addSourceLineNumbers is enabled, source line numbers are embedded in @DisplayName annotations on Background @BeforeEach methods

    Scenario: source line number in Background @DisplayName without a name
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Background Without Name
          Background:
            Given setup is complete
          Scenario: Test
            When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.BeforeEach;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestInfo;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Background Without Name
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsComplete() {
                Assertions.fail("Step is not yet implemented");
            }

            @BeforeEach
            @DisplayName("Background [2]:")
            public void featureBackground(TestInfo testInfo) {
                /*
                 * [3] Given setup is complete
                 */
                setupIsComplete();
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario [4]: Test")
            public void scenario_1() {
                /*
                 * [5] When user clicks button
                 */
                userClicksButton();
            }
        }
        """

    Scenario: source line number in Background @DisplayName with a name
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addSourceLineNumbers = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Background With Name
          Background: setup test data
            Given user exists
            And database is initialized
          Scenario: Test
            When user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.BeforeEach;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestInfo;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Background With Name
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void databaseIsInitialized() {
                Assertions.fail("Step is not yet implemented");
            }

            @BeforeEach
            @DisplayName("Background [2]: setup test data")
            public void featureBackground(TestInfo testInfo) {
                /*
                 * [3] Given user exists
                 */
                userExists();
                /*
                 * [4] And database is initialized
                 */
                databaseIsInitialized();
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario [5]: Test")
            public void scenario_1() {
                /*
                 * [6] When user clicks button
                 */
                userClicksButton();
            }
        }
        """

  Rule: when addSourceLineNumbers is disabled (default), no source line numbers appear anywhere
  - @DisplayName annotations contain only the element keyword and name
  - step block comments contain only the step text
  - this is the default behavior to keep generated code clean

    Scenario: no source line numbers when option is disabled (default)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
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

  Rule: source line numbers work with composite steps when addSourceLineNumbers is enabled
  - the source line refers to where the composite step is called in the feature file
  - individual steps within composite steps do not get additional source line comments

    Scenario: composite step with no parameters and source line numbers
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineNumbers = true)
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
            @DisplayName("Scenario [2]: Complete checkout")
            public void scenario_1() {
                /*
                 * [3] Given user initiates checkout
                 */
                userInitiatesCheckout(() -> {
                    navigateToCheckoutPage();
                    verifyCartIsNotEmpty();
                    clickOnProceedButton();
                });
                /*
                 * [7] When payment is processed
                 */
                paymentIsProcessed();
                /*
                 * [8] Then order is confirmed
                 */
                orderIsConfirmed();
            }
        }
        """

    Scenario: composite step with one parameter and source line numbers
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineNumbers = true)
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
            @DisplayName("Scenario [2]: Update account")
            public void scenario_1() {
                /*
                 * [3] Given user "Alice" updates account details
                 */
                user$p1UpdatesAccountDetails("Alice", (p1) -> {
                    loginAsUser$p1(p1);
                    navigateToAccountSettings();
                    modifyProfileInformation();
                    saveChangesForUser$p1(p1);
                });
                /*
                 * [8] When update is submitted
                 */
                updateIsSubmitted();
                /*
                 * [9] Then account should be updated for "Alice"
                 */
                accountShouldBeUpdatedFor$p1("Alice");
            }
        }
        """

    Scenario: composite step with two parameters and source line numbers
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineNumbers = true)
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
            @DisplayName("Scenario [2]: Add stock")
            public void scenario_1() {
                /*
                 * [3] Given warehouse "WH-01" receives product "Widget"
                 */
                warehouse$p1ReceivesProduct$p2("WH-01", "Widget", (p1, p2) -> {
                    verifyWarehouse$p1IsOperational(p1);
                    checkProduct$p1ExistsInCatalog(p2);
                    updateStockLevelFor$p1In$p2(p2, p1);
                    sendNotificationAbout$p1To$p2(p2, p1);
                });
                /*
                 * [8] When stock is updated
                 */
                stockIsUpdated();
                /*
                 * [9] Then inventory should reflect changes for "WH-01"
                 */
                inventoryShouldReflectChangesFor$p1("WH-01");
            }
        }
        """

    Scenario: multiple composite steps with source line numbers
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true, addSourceLineNumbers = true)
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
            @DisplayName("Scenario [2]: Execute multiple composite steps")
            public void scenario_1() {
                /*
                 * [3] Given system is initialized
                 */
                systemIsInitialized(() -> {
                    startServices();
                    loadConfiguration();
                });
                /*
                 * [6] When user "Bob" performs action
                 */
                user$p1PerformsAction("Bob", (p1) -> {
                    authenticateUser$p1(p1);
                    executeOperationFor$p1(p1);
                });
                /*
                 * [9] Then result is successful for "Bob"
                 */
                resultIsSuccessfulFor$p1("Bob");
            }
        }
        """
