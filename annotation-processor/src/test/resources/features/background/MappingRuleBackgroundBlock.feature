Feature: MappingRuleBackgroundBlock
  As a test developer using Gherkin
  I want Rule Background sections to be mapped to @BeforeEach methods in the nested Rule class
  So that setup logic executes before each scenario in that Rule without affecting other scenarios

  Rule: Rule-level Background should be mapped to @BeforeEach in the nested Rule class

    Scenario: Rule with its own Background
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: payment processing

        Rule: payment validation

          Background:
            Given payment gateway is configured

          Scenario: valid payment
            When user submits valid payment
            Then payment should be processed
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: payment processing
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void paymentGatewayIsConfigured() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userSubmitsValidPayment() {
              Assertions.fail("Step is not yet implemented");
          }

          public void paymentShouldBeProcessed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: payment validation")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background:")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given payment gateway is configured
                   */
                  paymentGatewayIsConfigured();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: valid payment")
              public void scenario_1() {
                  /*
                   * When user submits valid payment
                   */
                  userSubmitsValidPayment();
                  /*
                   * Then payment should be processed
                   */
                  paymentShouldBeProcessed();
              }
          }
      }
      """

    Scenario: Multiple steps in Rule Background
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: authentication

        Rule: login validation

          Background:
            Given authentication service is started
            And user database is connected
            And session manager is initialized

          Scenario: successful login
            When user logs in with valid credentials
            Then user should be authenticated
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: authentication
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void authenticationServiceIsStarted() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userDatabaseIsConnected() {
              Assertions.fail("Step is not yet implemented");
          }

          public void sessionManagerIsInitialized() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userLogsInWithValidCredentials() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userShouldBeAuthenticated() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: login validation")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background:")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given authentication service is started
                   */
                  authenticationServiceIsStarted();
                  /*
                   * And user database is connected
                   */
                  userDatabaseIsConnected();
                  /*
                   * And session manager is initialized
                   */
                  sessionManagerIsInitialized();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: successful login")
              public void scenario_1() {
                  /*
                   * When user logs in with valid credentials
                   */
                  userLogsInWithValidCredentials();
                  /*
                   * Then user should be authenticated
                   */
                  userShouldBeAuthenticated();
              }
          }
      }
      """

    Scenario: Rule Background with description
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: notification system

        Rule: email notification

          Background: Setup email infrastructure
            This ensures the email service is properly configured
            before sending notifications
            Given email server is configured
            And email templates are loaded

          Scenario: send welcome email
            When new user registers
            Then welcome email should be sent
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: notification system
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void emailServerIsConfigured() {
              Assertions.fail("Step is not yet implemented");
          }

          public void emailTemplatesAreLoaded() {
              Assertions.fail("Step is not yet implemented");
          }

          public void newUserRegisters() {
              Assertions.fail("Step is not yet implemented");
          }

          public void welcomeEmailShouldBeSent() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: email notification")
          public class Rule_1 {
              /**
               * This ensures the email service is properly configured
               * before sending notifications
               */
              @BeforeEach
              @DisplayName("Background: Setup email infrastructure")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given email server is configured
                   */
                  emailServerIsConfigured();
                  /*
                   * And email templates are loaded
                   */
                  emailTemplatesAreLoaded();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: send welcome email")
              public void scenario_1() {
                  /*
                   * When new user registers
                   */
                  newUserRegisters();
                  /*
                   * Then welcome email should be sent
                   */
                  welcomeEmailShouldBeSent();
              }
          }
      }
      """

    Scenario: Scenario Outline in Rule with Background
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: data validation

        Rule: input validation

          Background:
            Given validation rules are loaded

          Scenario Outline: validate input values
            When user enters "<input>"
            Then validation result should be "<result>"
            Examples:
              | input | result  |
              | valid | pass    |
              | bad   | fail    |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: data validation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void validationRulesAreLoaded() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userEnters$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void validationResultShouldBe$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: input validation")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background:")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given validation rules are loaded
                   */
                  validationRulesAreLoaded();
              }

              @ParameterizedTest(
                      name = "Example {index}: [{arguments}]"
              )
              @CsvSource(
                      useHeadersInDisplayName = true,
                      delimiter = '|',
                      textBlock = \"\"\"
                              input | result
                              valid | pass
                              bad   | fail
                              \"\"\"
              )
              @Order(1)
              @DisplayName("Scenario Outline: validate input values")
              public void scenario_1(String input, String result) {
                  /*
                   * When user enters "<input>"
                   */
                  userEnters$p1(input);
                  /*
                   * Then validation result should be "<result>"
                   */
                  validationResultShouldBe$p1(result);
              }
          }
      }
      """

    Scenario: Rule with Background containing DataTable
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: configuration management

        Rule: service configuration

          Background:
            Given the following services are configured:
              | service   | port |
              | api       | 8080 |
              | database  | 5432 |

          Scenario: check configuration
            When configuration is validated
            Then all services should be ready
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: configuration management
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void theFollowingServicesAreConfigured(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          public void configurationIsValidated() {
              Assertions.fail("Step is not yet implemented");
          }

          public void allServicesShouldBeReady() {
              Assertions.fail("Step is not yet implemented");
          }

          protected List<Map<String, String>> createListOfMaps(String tableLines) {

              String[] tableRows = tableLines.split("\\n");
              List<Map<String, String>> listOfMaps = new ArrayList<>();

              if (tableRows.length < 2) {
                  return listOfMaps;
              }

              String[] headers = null;
              for (int i = 0; i < tableRows.length; i++) {
                  String trimmedLine = tableRows[i].trim();
                  if (!trimmedLine.isEmpty()) {
                      String[] columns = trimmedLine.split("\\|");
                      List<String> rowColumns = new ArrayList<>(columns.length);
                      for (int j = 1; j < columns.length; j++) {
                          String column = columns[j].trim();
                          rowColumns.add(column);
                      }

                      if (headers == null) {
                          headers = rowColumns.toArray(new String[0]);
                      } else {
                          Map<String, String> rowMap = new HashMap<>();
                          for (int j = 0; j < Math.min(headers.length, rowColumns.size()); j++) {
                              rowMap.put(headers[j], rowColumns.get(j));
                          }
                          listOfMaps.add(rowMap);
                      }
                  }
              }

              return listOfMaps;
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: service configuration")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background:")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given the following services are configured:
                   */
                  theFollowingServicesAreConfigured(createListOfMaps(\"\"\"
                          | service  | port |
                          | api      | 8080 |
                          | database | 5432 |
                          \"\"\"));
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: check configuration")
              public void scenario_1() {
                  /*
                   * When configuration is validated
                   */
                  configurationIsValidated();
                  /*
                   * Then all services should be ready
                   */
                  allServicesShouldBeReady();
              }
          }
      }
      """

  Rule: rule Background doesn't have to have any steps

    Scenario: Rule with empty Background
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: logging system

        Rule: log rotation

          Background: and empty rule background

          Scenario: rotate logs
            When log rotation is triggered
            Then old logs should be archived
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: logging system
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void logRotationIsTriggered() {
              Assertions.fail("Step is not yet implemented");
          }

          public void oldLogsShouldBeArchived() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: log rotation")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background: and empty rule background")
              public void ruleBackground(TestInfo testInfo) {
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: rotate logs")
              public void scenario_1() {
                  /*
                   * When log rotation is triggered
                   */
                  logRotationIsTriggered();
                  /*
                   * Then old logs should be archived
                   */
                  oldLogsShouldBeArchived();
              }
          }
      }
      """

  Rule: Feature and Rule Background interaction - both @BeforeEach methods coexist
  - Feature Background generates featureBackground() @BeforeEach at the outer class level
  - Rule Background generates ruleBackground() @BeforeEach in the nested Rule class
  - JUnit's @BeforeEach execution order ensures proper setup layering

    Scenario: Feature-level Background and Rule-level Background both present
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: inventory management

        Background:
          Given system is initialized

        Rule: stock validation

          Background:
            Given inventory database is connected

          Scenario: check stock
            When user checks stock for product
            Then stock level should be displayed
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: inventory management
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void systemIsInitialized() {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given system is initialized
               */
              systemIsInitialized();
          }

          public void inventoryDatabaseIsConnected() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userChecksStockForProduct() {
              Assertions.fail("Step is not yet implemented");
          }

          public void stockLevelShouldBeDisplayed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: stock validation")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background:")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given inventory database is connected
                   */
                  inventoryDatabaseIsConnected();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: check stock")
              public void scenario_1() {
                  /*
                   * When user checks stock for product
                   */
                  userChecksStockForProduct();
                  /*
                   * Then stock level should be displayed
                   */
                  stockLevelShouldBeDisplayed();
              }
          }
      }
      """

  Rule: Multiple Rules with different Backgrounds should each have isolated @BeforeEach methods

    Scenario: Multiple Rules each with different Backgrounds
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: e-commerce platform

        Rule: cart management

          Background: rule 1 background
            Given shopping cart service is initialized

          Scenario: add to cart
            When user adds item to cart
            Then item should be in cart

        Rule: checkout process

          Background: rule 2 background
            Given payment processor is initialized

          Scenario: complete checkout
            When user completes checkout
            Then order should be confirmed
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: e-commerce platform
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void shoppingCartServiceIsInitialized() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userAddsItemToCart() {
              Assertions.fail("Step is not yet implemented");
          }

          public void itemShouldBeInCart() {
              Assertions.fail("Step is not yet implemented");
          }

          public void paymentProcessorIsInitialized() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userCompletesCheckout() {
              Assertions.fail("Step is not yet implemented");
          }

          public void orderShouldBeConfirmed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: cart management")
          public class Rule_1 {
              @BeforeEach
              @DisplayName("Background: rule 1 background")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given shopping cart service is initialized
                   */
                  shoppingCartServiceIsInitialized();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: add to cart")
              public void scenario_1() {
                  /*
                   * When user adds item to cart
                   */
                  userAddsItemToCart();
                  /*
                   * Then item should be in cart
                   */
                  itemShouldBeInCart();
              }
          }

          @Nested
          @Order(2)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: checkout process")
          public class Rule_2 {
              @BeforeEach
              @DisplayName("Background: rule 2 background")
              public void ruleBackground(TestInfo testInfo) {
                  /*
                   * Given payment processor is initialized
                   */
                  paymentProcessorIsInitialized();
              }

              @Test
              @Order(1)
              @DisplayName("Scenario: complete checkout")
              public void scenario_1() {
                  /*
                   * When user completes checkout
                   */
                  userCompletesCheckout();
                  /*
                   * Then order should be confirmed
                   */
                  orderShouldBeConfirmed();
              }
          }
      }
      """

