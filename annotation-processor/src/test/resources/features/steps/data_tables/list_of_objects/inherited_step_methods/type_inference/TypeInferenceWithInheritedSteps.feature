Feature: TypeInferenceWithInheritedSteps
  As a BDD test developer working with strongly-typed parameter objects
  I want Gherkin data table values automatically converted to match field types (primitives, wrappers, enums)
  So that I get compile-time type safety without writing manual conversion code, catching invalid test data before runtime

  Rule: when field type is integer then value is passed in as primitive integer

    Scenario: int type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ScoresFeature {

          public static class ScoresParam {

              private final String playerName;
              private final int score;

              public ScoresParam(String playerName, int score) {
                  this.playerName = playerName;
                  this.score = score;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Scores Management
          Scenario: Record player scores
            Given the following scores:
              | player name | score |
              | Alice       | 100   |
              | Bob         | 250   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Scores Management
       */
      @DisplayName("ScoresFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ScoresFeature.feature")
      public class ScoresFeatureTest extends ScoresFeature {
          public void theFollowingScores(List<ScoresParam> scores) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record player scores")
          public void scenario_1() {
              /*
               * Given the following scores:
               *   | player name | score |
               *   | Alice       | 100   |
               *   | Bob         | 250   |
               */
              theFollowingScores(
                      List.of(
                              new ScoresParam(
                                      "Alice",
                                      100
                              ),
                              new ScoresParam(
                                      "Bob",
                                      250
                              )
                      ));
          }
      }
      """

    Scenario: Integer wrapper type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class InventoryFeature {

          public static class InventoryParam {

              private final String itemName;
              private final Integer quantity;

              public InventoryParam(String itemName, Integer quantity) {
                  this.itemName = itemName;
                  this.quantity = quantity;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Inventory Management
          Scenario: Update inventory quantities
            Given the following inventory:
              | item name | quantity |
              | Laptop    | 50       |
              | Mouse     | 200      |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
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
      @DisplayName("InventoryFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/InventoryFeature.feature")
      public class InventoryFeatureTest extends InventoryFeature {
          public void theFollowingInventory(List<InventoryParam> inventory) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Update inventory quantities")
          public void scenario_1() {
              /*
               * Given the following inventory:
               *   | item name | quantity |
               *   | Laptop    | 50       |
               *   | Mouse     | 200      |
               */
              theFollowingInventory(
                      List.of(
                              new InventoryParam(
                                      "Laptop",
                                      50
                              ),
                              new InventoryParam(
                                      "Mouse",
                                      200
                              )
                      ));
          }
      }
      """

    Scenario: Empty cells in Integer wrapper type column do not affect type inference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class InventoryFeature {

          public static class InventoryParam {

              private final String itemName;
              private final Integer quantity;

              public InventoryParam(String itemName, Integer quantity) {
                  this.itemName = itemName;
                  this.quantity = quantity;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Inventory Management
          Scenario: Update inventory with some unknown quantities
            Given the following inventory:
              | item name | quantity |
              | Laptop    | 50       |
              | Mouse     |          |
              | Keyboard  | 200      |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
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
      @DisplayName("InventoryFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/InventoryFeature.feature")
      public class InventoryFeatureTest extends InventoryFeature {
          public void theFollowingInventory(List<InventoryParam> inventory) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Update inventory with some unknown quantities")
          public void scenario_1() {
              /*
               * Given the following inventory:
               *   | item name | quantity |
               *   | Laptop    | 50       |
               *   | Mouse     |          |
               *   | Keyboard  | 200      |
               */
              theFollowingInventory(
                      List.of(
                              new InventoryParam(
                                      "Laptop",
                                      50
                              ),
                              new InventoryParam(
                                      "Mouse",
                                      null
                              ),
                              new InventoryParam(
                                      "Keyboard",
                                      200
                              )
                      ));
          }
      }
      """

  Rule: when field type is integer and value cannot be parsed to it then it is provided as string leading to compilation error

    Example: [counter example] Invalid string value for int field results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ScoresFeature {

          public void theFollowingScores(List<ScoresParam> scores) {
          }

          public static class ScoresParam {

              private final String playerName;

              private final int score;

              public ScoresParam(String playerName, int score) {
                  this.playerName = playerName;
                  this.score = score;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Scores Management
          Scenario: Record invalid score
            Given the following scores:
              | player name | score   |
              | Alice       | hundred |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Scores Management
       */
      @DisplayName("ScoresFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ScoresFeature.feature")
      public class ScoresFeatureTest extends ScoresFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Record invalid score")
          public void scenario_1() {
              /*
               * Given the following scores:
               *   | player name | score   |
               *   | Alice       | hundred |
               */
              theFollowingScores(
                      List.of(
                              new ScoresParam(
                                      "Alice",
                                      "hundred"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to int
        """

    Example: [counter example] Invalid string value for Integer wrapper type results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class InventoryFeature {

          public void theFollowingInventory(List<InventoryParam> inventory) {
          }

          public static class InventoryParam {

              private final String itemName;
              private final Integer quantity;

              public InventoryParam(String itemName, Integer quantity) {
                  this.itemName = itemName;
                  this.quantity = quantity;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Inventory Management
          Scenario: Update inventory with invalid quantity
            Given the following inventory:
              | item name | quantity |
              | Laptop    | many     |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Inventory Management
       */
      @DisplayName("InventoryFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/InventoryFeature.feature")
      public class InventoryFeatureTest extends InventoryFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Update inventory with invalid quantity")
          public void scenario_1() {
              /*
               * Given the following inventory:
               *   | item name | quantity |
               *   | Laptop    | many     |
               */
              theFollowingInventory(
                      List.of(
                              new InventoryParam(
                                      "Laptop",
                                      "many"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.String cannot be converted to java.lang.Integer
        """

  Rule: when field type is long then value is passed in as primitive long

    Scenario: long type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TransactionsFeature {

          public static class TransactionsParam {

              private final String transactionId;
              private final long timestamp;

              public TransactionsParam(String transactionId, long timestamp) {
                  this.transactionId = transactionId;
                  this.timestamp = timestamp;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario: Record transactions with timestamps
            Given the following transactions:
              | transaction id | timestamp    |
              | TXN-001        | 1609459200000|
              | TXN-002        | 1609545600000|
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          public void theFollowingTransactions(List<TransactionsParam> transactions) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record transactions with timestamps")
          public void scenario_1() {
              /*
               * Given the following transactions:
               *   | transaction id | timestamp     |
               *   | TXN-001        | 1609459200000 |
               *   | TXN-002        | 1609545600000 |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      "TXN-001",
                                      1609459200000L
                              ),
                              new TransactionsParam(
                                      "TXN-002",
                                      1609545600000L
                              )
                      ));
          }
      }
      """

    Scenario: Long wrapper type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class AccountsFeature {

          public static class AccountsParam {

              private final String accountName;
              private final Long accountNumber;

              public AccountsParam(String accountName, Long accountNumber) {
                  this.accountName = accountName;
                  this.accountNumber = accountNumber;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Accounts Management
          Scenario: Create accounts with account numbers
            Given the following accounts:
              | account name | account number |
              | Savings      | 9876543210     |
              | Checking     | 1234567890     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Accounts Management
       */
      @DisplayName("AccountsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/AccountsFeature.feature")
      public class AccountsFeatureTest extends AccountsFeature {
          public void theFollowingAccounts(List<AccountsParam> accounts) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create accounts with account numbers")
          public void scenario_1() {
              /*
               * Given the following accounts:
               *   | account name | account number |
               *   | Savings      | 9876543210     |
               *   | Checking     | 1234567890     |
               */
              theFollowingAccounts(
                      List.of(
                              new AccountsParam(
                                      "Savings",
                                      9876543210L
                              ),
                              new AccountsParam(
                                      "Checking",
                                      1234567890L
                              )
                      ));
          }
      }
      """

    Scenario: Empty cells in Long wrapper type column do not affect type inference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class AccountsFeature {

          public static class AccountsParam {

              private final String accountName;
              private final Long accountNumber;

              public AccountsParam(String accountName, Long accountNumber) {
                  this.accountName = accountName;
                  this.accountNumber = accountNumber;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Accounts Management
          Scenario: Create accounts with some pending account numbers
            Given the following accounts:
              | account name | account number |
              | Savings      | 9876543210     |
              | Pending      |                |
              | Checking     | 1234567890     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Accounts Management
       */
      @DisplayName("AccountsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/AccountsFeature.feature")
      public class AccountsFeatureTest extends AccountsFeature {
          public void theFollowingAccounts(List<AccountsParam> accounts) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create accounts with some pending account numbers")
          public void scenario_1() {
              /*
               * Given the following accounts:
               *   | account name | account number |
               *   | Savings      | 9876543210     |
               *   | Pending      |                |
               *   | Checking     | 1234567890     |
               */
              theFollowingAccounts(
                      List.of(
                              new AccountsParam(
                                      "Savings",
                                      9876543210L
                              ),
                              new AccountsParam(
                                      "Pending",
                                      null
                              ),
                              new AccountsParam(
                                      "Checking",
                                      1234567890L
                              )
                      ));
          }
      }
      """

  Rule: when field type is long and value cannot be parsed to it then it is provided as string leading to compilation error

    Example: [counter example] Invalid string value for long field results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TransactionsFeature {

          public void theFollowingTransactions(List<TransactionsParam> transactions) {
          }

          public static class TransactionsParam {

              private final String transactionId;
              private final long timestamp;

              public TransactionsParam(String transactionId, long timestamp) {
                  this.transactionId = transactionId;
                  this.timestamp = timestamp;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario: Record transaction with invalid timestamp
            Given the following transactions:
              | transaction id | timestamp |
              | TXN-001        | yesterday |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Record transaction with invalid timestamp")
          public void scenario_1() {
              /*
               * Given the following transactions:
               *   | transaction id | timestamp |
               *   | TXN-001        | yesterday |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      "TXN-001",
                                      "yesterday"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to long
        """

    Example: [counter example] Invalid string value for Long wrapper type results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class AccountsFeature {

          public void theFollowingAccounts(List<AccountsParam> accounts) {
          }

          public static class AccountsParam {

              private final String accountName;
              private final Long accountNumber;

              public AccountsParam(String accountName, Long accountNumber) {
                  this.accountName = accountName;
                  this.accountNumber = accountNumber;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Accounts Management
          Scenario: Create account with invalid account number
            Given the following accounts:
              | account name | account number |
              | Savings      | ACCOUNT-123    |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Accounts Management
       */
      @DisplayName("AccountsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/AccountsFeature.feature")
      public class AccountsFeatureTest extends AccountsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create account with invalid account number")
          public void scenario_1() {
              /*
               * Given the following accounts:
               *   | account name | account number |
               *   | Savings      | ACCOUNT-123    |
               */
              theFollowingAccounts(
                      List.of(
                              new AccountsParam(
                                      "Savings",
                                      "ACCOUNT-123"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.String cannot be converted to java.lang.Long
        """

  Rule: when field type is double then value is passed in as primitive double

    Scenario: double type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MeasurementsFeature {

          public static class MeasurementsParam {

              private final String sampleId;
              private final double temperature;

              public MeasurementsParam(String sampleId, double temperature) {
                  this.sampleId = sampleId;
                  this.temperature = temperature;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Measurements Management
          Scenario: Record temperature measurements
            Given the following measurements:
              | sample id | temperature |
              | SAMPLE-01 | 36.6        |
              | SAMPLE-02 | 98.4        |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Measurements Management
       */
      @DisplayName("MeasurementsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MeasurementsFeature.feature")
      public class MeasurementsFeatureTest extends MeasurementsFeature {
          public void theFollowingMeasurements(List<MeasurementsParam> measurements) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record temperature measurements")
          public void scenario_1() {
              /*
               * Given the following measurements:
               *   | sample id | temperature |
               *   | SAMPLE-01 | 36.6        |
               *   | SAMPLE-02 | 98.4        |
               */
              theFollowingMeasurements(
                      List.of(
                              new MeasurementsParam(
                                      "SAMPLE-01",
                                      36.6
                              ),
                              new MeasurementsParam(
                                      "SAMPLE-02",
                                      98.4
                              )
                      ));
          }
      }
      """

    Scenario: Double wrapper type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class RatingsFeature {

          public static class RatingsParam {

              private final String productName;
              private final Double rating;

              public RatingsParam(String productName, Double rating) {
                  this.productName = productName;
                  this.rating = rating;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Ratings Management
          Scenario: Record product ratings
            Given the following ratings:
              | product name | rating |
              | Laptop       | 4.5    |
              | Mouse        | 3.8    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Ratings Management
       */
      @DisplayName("RatingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/RatingsFeature.feature")
      public class RatingsFeatureTest extends RatingsFeature {
          public void theFollowingRatings(List<RatingsParam> ratings) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record product ratings")
          public void scenario_1() {
              /*
               * Given the following ratings:
               *   | product name | rating |
               *   | Laptop       | 4.5    |
               *   | Mouse        | 3.8    |
               */
              theFollowingRatings(
                      List.of(
                              new RatingsParam(
                                      "Laptop",
                                      4.5
                              ),
                              new RatingsParam(
                                      "Mouse",
                                      3.8
                              )
                      ));
          }
      }
      """

    Scenario: Empty cells in Double wrapper type column do not affect type inference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class RatingsFeature {

          public static class RatingsParam {

              private final String productName;
              private final Double rating;

              public RatingsParam(String productName, Double rating) {
                  this.productName = productName;
                  this.rating = rating;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Ratings Management
          Scenario: Record product ratings with some unrated products
            Given the following ratings:
              | product name | rating |
              | Laptop       | 4.5    |
              | Tablet       |        |
              | Mouse        | 3.8    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Ratings Management
       */
      @DisplayName("RatingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/RatingsFeature.feature")
      public class RatingsFeatureTest extends RatingsFeature {
          public void theFollowingRatings(List<RatingsParam> ratings) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record product ratings with some unrated products")
          public void scenario_1() {
              /*
               * Given the following ratings:
               *   | product name | rating |
               *   | Laptop       | 4.5    |
               *   | Tablet       |        |
               *   | Mouse        | 3.8    |
               */
              theFollowingRatings(
                      List.of(
                              new RatingsParam(
                                      "Laptop",
                                      4.5
                              ),
                              new RatingsParam(
                                      "Tablet",
                                      null
                              ),
                              new RatingsParam(
                                      "Mouse",
                                      3.8
                              )
                      ));
          }
      }
      """

  Rule: when field type is double and value cannot be parsed to it then it is provided as string leading to compilation error

    Example: [counter example] Invalid string value for double field results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MeasurementsFeature {

          public void theFollowingMeasurements(List<MeasurementsParam> measurements) {
          }

          public static class MeasurementsParam {

              private final String sampleId;
              private final double temperature;

              public MeasurementsParam(String sampleId, double temperature) {
                  this.sampleId = sampleId;
                  this.temperature = temperature;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Measurements Management
          Scenario: Record measurement with invalid temperature
            Given the following measurements:
              | sample id | temperature |
              | SAMPLE-01 | hot         |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Measurements Management
       */
      @DisplayName("MeasurementsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MeasurementsFeature.feature")
      public class MeasurementsFeatureTest extends MeasurementsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Record measurement with invalid temperature")
          public void scenario_1() {
              /*
               * Given the following measurements:
               *   | sample id | temperature |
               *   | SAMPLE-01 | hot         |
               */
              theFollowingMeasurements(
                      List.of(
                              new MeasurementsParam(
                                      "SAMPLE-01",
                                      "hot"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to double
        """

    Example: [counter example] Invalid string value for Double wrapper type results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class RatingsFeature {

          public void theFollowingRatings(List<RatingsParam> ratings) {
          }

          public static class RatingsParam {

              private final String productName;
              private final Double rating;

              public RatingsParam(String productName, Double rating) {
                  this.productName = productName;
                  this.rating = rating;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Ratings Management
          Scenario: Record product with invalid rating
            Given the following ratings:
              | product name | rating    |
              | Laptop       | excellent |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Ratings Management
       */
      @DisplayName("RatingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/RatingsFeature.feature")
      public class RatingsFeatureTest extends RatingsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Record product with invalid rating")
          public void scenario_1() {
              /*
               * Given the following ratings:
               *   | product name | rating    |
               *   | Laptop       | excellent |
               */
              theFollowingRatings(
                      List.of(
                              new RatingsParam(
                                      "Laptop",
                                      "excellent"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.String cannot be converted to java.lang.Double
        """

  Rule: when field type is boolean then value is passed in as primitive boolean

    Scenario: boolean type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class FlagsFeature {

          public static class FlagsParam {

              private final String featureName;
              private final boolean enabled;

              public FlagsParam(String featureName, boolean enabled) {
                  this.featureName = featureName;
                  this.enabled = enabled;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Feature Flags Management
          Scenario: Set feature flags
            Given the following flags:
              | feature name | enabled |
              | dark-mode    | true    |
              | beta-access  | false   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Feature Flags Management
       */
      @DisplayName("FlagsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/FlagsFeature.feature")
      public class FlagsFeatureTest extends FlagsFeature {
          public void theFollowingFlags(List<FlagsParam> flags) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Set feature flags")
          public void scenario_1() {
              /*
               * Given the following flags:
               *   | feature name | enabled |
               *   | dark-mode    | true    |
               *   | beta-access  | false   |
               */
              theFollowingFlags(
                      List.of(
                              new FlagsParam(
                                      "dark-mode",
                                      true
                              ),
                              new FlagsParam(
                                      "beta-access",
                                      false
                              )
                      ));
          }
      }
      """

    Scenario: Boolean wrapper type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class SettingsFeature {

          public static class SettingsParam {

              private final String settingName;
              private final Boolean value;

              public SettingsParam(String settingName, Boolean value) {
                  this.settingName = settingName;
                  this.value = value;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Settings Management
          Scenario: Configure settings
            Given the following settings:
              | setting name      | value |
              | notifications     | true  |
              | auto-save         | false |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Settings Management
       */
      @DisplayName("SettingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/SettingsFeature.feature")
      public class SettingsFeatureTest extends SettingsFeature {
          public void theFollowingSettings(List<SettingsParam> settings) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Configure settings")
          public void scenario_1() {
              /*
               * Given the following settings:
               *   | setting name  | value |
               *   | notifications | true  |
               *   | auto-save     | false |
               */
              theFollowingSettings(
                      List.of(
                              new SettingsParam(
                                      "notifications",
                                      true
                              ),
                              new SettingsParam(
                                      "auto-save",
                                      false
                              )
                      ));
          }
      }
      """

    Scenario: Empty cells in Boolean wrapper type column do not affect type inference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class SettingsFeature {

          public static class SettingsParam {

              private final String settingName;
              private final Boolean value;

              public SettingsParam(String settingName, Boolean value) {
                  this.settingName = settingName;
                  this.value = value;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Settings Management
          Scenario: Configure settings with some undefined values
            Given the following settings:
              | setting name      | value |
              | notifications     | true  |
              | theme             |       |
              | auto-save         | false |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Settings Management
       */
      @DisplayName("SettingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/SettingsFeature.feature")
      public class SettingsFeatureTest extends SettingsFeature {
          public void theFollowingSettings(List<SettingsParam> settings) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Configure settings with some undefined values")
          public void scenario_1() {
              /*
               * Given the following settings:
               *   | setting name  | value |
               *   | notifications | true  |
               *   | theme         |       |
               *   | auto-save     | false |
               */
              theFollowingSettings(
                      List.of(
                              new SettingsParam(
                                      "notifications",
                                      true
                              ),
                              new SettingsParam(
                                      "theme",
                                      null
                              ),
                              new SettingsParam(
                                      "auto-save",
                                      false
                              )
                      ));
          }
      }
      """

  Rule: when field type is boolean and value cannot be parsed to it then it is provided as string leading to compilation error

    Example: [counter example] Invalid string value for boolean field results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class FlagsFeature {

          public void theFollowingFlags(List<FlagsParam> flags) {
          }

          public static class FlagsParam {

              private final String featureName;
              private final boolean enabled;

              public FlagsParam(String featureName, boolean enabled) {
                  this.featureName = featureName;
                  this.enabled = enabled;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Feature Flags Management
          Scenario: Set flag with invalid enabled value
            Given the following flags:
              | feature name | enabled |
              | dark-mode    | yes     |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Feature Flags Management
       */
      @DisplayName("FlagsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/FlagsFeature.feature")
      public class FlagsFeatureTest extends FlagsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Set flag with invalid enabled value")
          public void scenario_1() {
              /*
               * Given the following flags:
               *   | feature name | enabled |
               *   | dark-mode    | yes     |
               */
              theFollowingFlags(
                      List.of(
                              new FlagsParam(
                                      "dark-mode",
                                      "yes"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to boolean
        """

    Example: [counter example] Invalid string value for Boolean wrapper type results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class SettingsFeature {

          public void theFollowingSettings(List<SettingsParam> settings) {
          }

          public static class SettingsParam {

              private final String settingName;
              private final Boolean value;

              public SettingsParam(String settingName, Boolean value) {
                  this.settingName = settingName;
                  this.value = value;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Settings Management
          Scenario: Configure setting with invalid value
            Given the following settings:
              | setting name  | value   |
              | notifications | enabled |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Settings Management
       */
      @DisplayName("SettingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/SettingsFeature.feature")
      public class SettingsFeatureTest extends SettingsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Configure setting with invalid value")
          public void scenario_1() {
              /*
               * Given the following settings:
               *   | setting name  | value   |
               *   | notifications | enabled |
               */
              theFollowingSettings(
                      List.of(
                              new SettingsParam(
                                      "notifications",
                                      "enabled"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.String cannot be converted to java.lang.Boolean
        """

  Rule: when field type is character then value is passed in as primitive character type

    Scenario: char type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CodesFeature {

          public static class CodesParam {

              private final String code;
              private final char grade;

              public CodesParam(String code, char grade) {
                  this.code = code;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Codes Management
          Scenario: Record student codes
            Given the following codes:
              | code    | grade |
              | MATH101 | A     |
              | PHYS201 | B     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Codes Management
       */
      @DisplayName("CodesFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/CodesFeature.feature")
      public class CodesFeatureTest extends CodesFeature {
          public void theFollowingCodes(List<CodesParam> codes) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Record student codes")
          public void scenario_1() {
              /*
               * Given the following codes:
               *   | code    | grade |
               *   | MATH101 | A     |
               *   | PHYS201 | B     |
               */
              theFollowingCodes(
                      List.of(
                              new CodesParam(
                                      "MATH101",
                                      'A'
                              ),
                              new CodesParam(
                                      "PHYS201",
                                      'B'
                              )
                      ));
          }
      }
      """

    Scenario: Character wrapper type field conversion
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LabelsFeature {

          public static class LabelsParam {

              private final String name;
              private final Character label;

              public LabelsParam(String name, Character label) {
                  this.name = name;
                  this.label = label;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Labels Management
          Scenario: Create labels
            Given the following labels:
              | name     | label |
              | Priority | A     |
              | Status   | X     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Labels Management
       */
      @DisplayName("LabelsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/LabelsFeature.feature")
      public class LabelsFeatureTest extends LabelsFeature {
          public void theFollowingLabels(List<LabelsParam> labels) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create labels")
          public void scenario_1() {
              /*
               * Given the following labels:
               *   | name     | label |
               *   | Priority | A     |
               *   | Status   | X     |
               */
              theFollowingLabels(
                      List.of(
                              new LabelsParam(
                                      "Priority",
                                      'A'
                              ),
                              new LabelsParam(
                                      "Status",
                                      'X'
                              )
                      ));
          }
      }
      """

    Scenario: Empty cells in Character wrapper type column do not affect type inference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LabelsFeature {

          public static class LabelsParam {

              private final String name;
              private final Character label;

              public LabelsParam(String name, Character label) {
                  this.name = name;
                  this.label = label;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Labels Management
          Scenario: Create labels with some unlabeled items
            Given the following labels:
              | name     | label |
              | Priority | A     |
              | Draft    |       |
              | Status   | X     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Labels Management
       */
      @DisplayName("LabelsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/LabelsFeature.feature")
      public class LabelsFeatureTest extends LabelsFeature {
          public void theFollowingLabels(List<LabelsParam> labels) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create labels with some unlabeled items")
          public void scenario_1() {
              /*
               * Given the following labels:
               *   | name     | label |
               *   | Priority | A     |
               *   | Draft    |       |
               *   | Status   | X     |
               */
              theFollowingLabels(
                      List.of(
                              new LabelsParam(
                                      "Priority",
                                      'A'
                              ),
                              new LabelsParam(
                                      "Draft",
                                      null
                              ),
                              new LabelsParam(
                                      "Status",
                                      'X'
                              )
                      ));
          }
      }
      """

  Rule: when field type is character and value cannot be parsed to it then it is provided as string leading to compilation error

    Example: [counter example] Invalid string value for char field results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class GradesFeature {

          public void theFollowingGrades(List<GradesParam> grades) {
          }

          public static class GradesParam {

              private final String studentName;

              private final char grade;

              public GradesParam(String studentName, char grade) {
                  this.studentName = studentName;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario: Record invalid grade
            Given the following grades:
              | student name | grade |
              | Alice        | AB    |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Record invalid grade")
          public void scenario_1() {
              /*
               * Given the following grades:
               *   | student name | grade |
               *   | Alice        | AB    |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      "Alice",
                                      "AB"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to char
        """

    Example: [counter example] Invalid string value for Character wrapper type results in compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class RatingsFeature {

          public void theFollowingRatings(List<RatingsParam> ratings) {
          }

          public static class RatingsParam {

              private final String productName;
              private final Character rating;

              public RatingsParam(String productName, Character rating) {
                  this.productName = productName;
                  this.rating = rating;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Ratings Management
          Scenario: Update rating with invalid value
            Given the following ratings:
              | product name | rating    |
              | Laptop       | excellent |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Ratings Management
       */
      @DisplayName("RatingsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/RatingsFeature.feature")
      public class RatingsFeatureTest extends RatingsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Update rating with invalid value")
          public void scenario_1() {
              /*
               * Given the following ratings:
               *   | product name | rating    |
               *   | Laptop       | excellent |
               */
              theFollowingRatings(
                      List.of(
                              new RatingsParam(
                                      "Laptop",
                                      "excellent"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to java.lang.Character
        """

  Rule: custom object type can have primitive, wrapper or a mix of different types

    Scenario: Existing inner class has fields with different primitive types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public static class UsersParam {

              private final String name;
              private final int age;
              private final long yearBorn;
              private final double height;
              private final boolean active;

              public UsersParam(String name, int age, long yearBorn, double height, boolean active) {
                  this.name = name;
                  this.age = age;
                  this.yearBorn = yearBorn;
                  this.height = height;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age | year born | height | active |
              | Alice | 30  | 1993      | 5.7    | true   |
              | Bob   | 25  | 1998      | 6.0    | false  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void theFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | year born | height | active |
               *   | Alice | 30  | 1993      | 5.7    | true   |
               *   | Bob   | 25  | 1998      | 6.0    | false  |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      "Alice",
                                      30,
                                      1993L,
                                      5.7,
                                      true
                              ),
                              new UsersParam(
                                      "Bob",
                                      25,
                                      1998L,
                                      6.0,
                                      false
                              )
                      ));
          }
      }
      """

    Scenario: Existing inner class has fields with wrapper types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public static class ProductsParam {

              private final String name;
              private final Integer stock;
              private final Long productId;
              private final Double price;
              private final Boolean inStock;

              public ProductsParam(String name, Integer stock, Long productId, Double price, Boolean inStock) {
                  this.name = name;
                  this.stock = stock;
                  this.productId = productId;
                  this.price = price;
                  this.inStock = inStock;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario: Create products
            Given the following products:
              | name   | stock | product id | price | in stock |
              | Laptop | 10    | 1001       | 999.99| true     |
              | Mouse  | 50    | 1002       | 19.99 | false    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          public void theFollowingProducts(List<ProductsParam> products) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create products")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | stock | product id | price  | in stock |
               *   | Laptop | 10    | 1001       | 999.99 | true     |
               *   | Mouse  | 50    | 1002       | 19.99  | false    |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      10,
                                      1001L,
                                      999.99,
                                      true
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      50,
                                      1002L,
                                      19.99,
                                      false
                              )
                      ));
          }
      }
      """

    Scenario: Existing inner class has mixed primitive and wrapper types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class EmployeesFeature {

          public static class EmployeesParam {

              private final String name;
              private final int departmentId;
              private final Long employeeId;
              private final double salary;
              private final Boolean isManager;

              public EmployeesParam(String name, int departmentId, Long employeeId, double salary, Boolean isManager) {
                  this.name = name;
                  this.departmentId = departmentId;
                  this.employeeId = employeeId;
                  this.salary = salary;
                  this.isManager = isManager;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Employees Management
          Scenario: Register employees
            Given the following employees:
              | name    | department id | employee id | salary  | is manager |
              | Alice   | 5             | 1001        | 75000.50| true       |
              | Bob     | 3             | 1002        | 55000.00| false      |
              | Charlie | 5             | 1003        | 82000.75| true       |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Employees Management
       */
      @DisplayName("EmployeesFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/EmployeesFeature.feature")
      public class EmployeesFeatureTest extends EmployeesFeature {
          public void theFollowingEmployees(List<EmployeesParam> employees) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Register employees")
          public void scenario_1() {
              /*
               * Given the following employees:
               *   | name    | department id | employee id | salary   | is manager |
               *   | Alice   | 5             | 1001        | 75000.50 | true       |
               *   | Bob     | 3             | 1002        | 55000.00 | false      |
               *   | Charlie | 5             | 1003        | 82000.75 | true       |
               */
              theFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      "Alice",
                                      5,
                                      1001L,
                                      75000.50,
                                      true
                              ),
                              new EmployeesParam(
                                      "Bob",
                                      3,
                                      1002L,
                                      55000.00,
                                      false
                              ),
                              new EmployeesParam(
                                      "Charlie",
                                      5,
                                      1003L,
                                      82000.75,
                                      true
                              )
                      ));
          }
      }
      """

