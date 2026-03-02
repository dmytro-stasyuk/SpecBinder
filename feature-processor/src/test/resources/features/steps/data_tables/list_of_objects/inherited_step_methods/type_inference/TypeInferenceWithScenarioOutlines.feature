Feature: TypeInferenceWithScenarioOutlines
  As a BDD test developer writing parameterized tests with Scenario Outlines
  I want Example placeholder values in data tables dynamically substituted and type-converted to match field types
  So that I can reuse test data patterns across multiple Examples while maintaining compile-time type safety

  # Integer type inference rules
  #####################################################################################################################

  Rule: example table values that are numeric and within integer range can be passed directly for integer type fields

    Example: field type is primitive int
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final int age;

              public UsersParam(String name, int age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with age
            Given the following users:
              | name   | age   |
              | <name> | <age> |

            Examples:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age
                          Alice | 30
                          Bob   | 25
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with age")
          public void scenario_1(String name, Integer age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      age
                              )
                      ));
          }
      }
      """

    Example: field type is Integer wrapper type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final Integer age;

              public UsersParam(String name, Integer age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with wrapper age
            Given the following users:
              | name   | age   |
              | <name> | <age> |

            Examples:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age
                          Alice | 30
                          Bob   | 25
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with wrapper age")
          public void scenario_1(String name, Integer age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      age
                              )
                      ));
          }
      }
      """

  Rule: example table values that are number values but larger than what can fit in an integer type result in compilation error

    Example: with number values in examples tables that are larger than integer range
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final int age;

              public UsersParam(String name, int age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with large age value
            Given the following users:
              | name   | age   |
              | <name> | <age> |

            Examples:
              | name  | age          |
              | Alice | 3000000000   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Long;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age
                          Alice | 3000000000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with large age value")
          public void scenario_1(String name, Long age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      age
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.Long cannot be converted to int
      """

  Rule: example table values that are non-numeric for integer type fields are passed as string and produce compilation error

    Example: with non numeric value in examples table
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final Integer age;

              public UsersParam(String name, Integer age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with invalid age from Examples
            Given the following users:
              | name   | age   |
              | <name> | <age> |

            Examples:
              | name  | age    |
              | Alice | thirty |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age
                          Alice | thirty
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with invalid age from Examples")
          public void scenario_1(String name, String age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      age
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to java.lang.Integer
      """

  Rule: example table values that are numeric but are then used in mixed usage style (literal + reference) are treated as Strings and result in compilation error

    Example: with mixed usage style - literal + reference in same cell
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final int age;

              public UsersParam(String name, int age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with prefixed age
            Given the following users:
              | name   | age       |
              | <name> | age-<age> |

            Examples:
              | name  | age |
              | Alice | 30  |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age
                          Alice | 30
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with prefixed age")
          public void scenario_1(String name, Integer age) {
              /*
               * Given the following users:
               *   | name   | age       |
               *   | <name> | age-<age> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      "age-<age>".replaceAll("<age>", age.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to int
      """

  Rule: multiple placeholders for numeric field in one cell are treated as Strings and result in compilation error

    Example: with multiple references inside the same cell
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class OrdersFeature {

          public void theFollowingOrders(List<OrdersParam> orders) {
          }

          public static class OrdersParam {

              private final String orderId;
              private final int quantity;

              public OrdersParam(String orderId, int quantity) {
                  this.orderId = orderId;
                  this.quantity = quantity;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Orders Management
          Scenario Outline: Create order with concatenated quantity
            Given the following orders:
              | order id | quantity     |
              | ORD-001  | <tens><ones> |

            Examples:
              | tens | ones |
              | 1    | 5    |
              | 2    | 0    |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Orders Management
       */
      @DisplayName("OrdersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/OrdersFeature.feature")
      public class OrdersFeatureTest extends OrdersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          tens | ones
                          1    | 5
                          2    | 0
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create order with concatenated quantity")
          public void scenario_1(Integer tens, Integer ones) {
              /*
               * Given the following orders:
               *   | order id | quantity     |
               *   | ORD-001  | <tens><ones> |
               */
              theFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      "ORD-001",
                                      "<tens><ones>".replaceAll("<tens>", tens.toString()).replaceAll("<ones>", ones.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to int
      """

  # Long type inference rules
  #####################################################################################################################

  Rule: example table values that are numeric and larger than integer but within long range can be passed directly for long type fields

    Example: with examples values that are larger than integer
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

              private final long amount;

              public TransactionsParam(String transactionId, long amount) {
                  this.transactionId = transactionId;
                  this.amount = amount;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario Outline: Create transaction with large amount
            Given the following transactions:
              | transaction id   | amount   |
              | <transactionId>  | <amount> |

            Examples:
              | transactionId | amount       |
              | TXN-001       | 3000000000   |
              | TXN-002       | 5000000000   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Long;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          transactionId | amount
                          TXN-001       | 3000000000
                          TXN-002       | 5000000000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create transaction with large amount")
          public void scenario_1(String transactionId, Long amount) {
              /*
               * Given the following transactions:
               *   | transaction id  | amount   |
               *   | <transactionId> | <amount> |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      transactionId,
                                      amount
                              )
                      ));
          }
      }
      """

    Example: with examples values that are larger than integer and field type wrapper Long type
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

              private final String accountNumber;
              private final Long balance;

              public AccountsParam(String accountNumber, Long balance) {
                  this.accountNumber = accountNumber;
                  this.balance = balance;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Accounts Management
          Scenario Outline: Create account with large balance
            Given the following accounts:
              | account number   | balance   |
              | <accountNumber>  | <balance> |

            Examples:
              | accountNumber | balance      |
              | ACC-001       | 3000000000   |
              | ACC-002       | 5000000000   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Long;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Accounts Management
       */
      @DisplayName("AccountsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/AccountsFeature.feature")
      public class AccountsFeatureTest extends AccountsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          accountNumber | balance
                          ACC-001       | 3000000000
                          ACC-002       | 5000000000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create account with large balance")
          public void scenario_1(String accountNumber, Long balance) {
              /*
               * Given the following accounts:
               *   | account number  | balance   |
               *   | <accountNumber> | <balance> |
               */
              theFollowingAccounts(
                      List.of(
                              new AccountsParam(
                                      accountNumber,
                                      balance
                              )
                      ));
          }
      }
      """

  Rule: example table values that are numeric but are also within the range of Integer can still be passed directly due to primitive widening

    Example: with examples values that are numeric and can fit into integer
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

              private final long amount;

              public TransactionsParam(String transactionId, long amount) {
                  this.transactionId = transactionId;
                  this.amount = amount;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario Outline: Create transaction with amount
            Given the following transactions:
              | transaction id   | amount   |
              | <transactionId>  | <amount> |

            Examples:
              | transactionId | amount |
              | TXN-001       | 500    |
              | TXN-002       | 1000   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          transactionId | amount
                          TXN-001       | 500
                          TXN-002       | 1000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create transaction with amount")
          public void scenario_1(String transactionId, Integer amount) {
              /*
               * Given the following transactions:
               *   | transaction id  | amount   |
               *   | <transactionId> | <amount> |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      transactionId,
                                      amount
                              )
                      ));
          }
      }
      """

  Rule: example table values that are number values but larger than what can fit in an long type result in compilation error

    Example: with number values in examples tables that are larger than long range
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

              private final long amount;

              public TransactionsParam(String transactionId, long amount) {
                  this.transactionId = transactionId;
                  this.amount = amount;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario Outline: Create transaction with huge amount
            Given the following transactions:
              | transaction id   | amount   |
              | <transactionId>  | <amount> |

            Examples:
              | transactionId | amount              |
              | TXN-001       | 9999999999999999999 |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          transactionId | amount
                          TXN-001       | 9999999999999999999
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create transaction with huge amount")
          public void scenario_1(String transactionId, Double amount) {
              /*
               * Given the following transactions:
               *   | transaction id  | amount   |
               *   | <transactionId> | <amount> |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      transactionId,
                                      amount
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      error: incompatible types: java.lang.Double cannot be converted to long
      """

  Rule: example table values that are non-numeric for Long type fields are passed as string and produce compilation error

    Example: with non-numeric value in examples table for Long field type
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

              private final String accountNumber;

              private final Long balance;

              public AccountsParam(String accountNumber, Long balance) {
                  this.accountNumber = accountNumber;
                  this.balance = balance;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Accounts Management
          Scenario Outline: Create account with invalid balance
            Given the following accounts:
              | account number   | balance   |
              | <accountNumber>  | <balance> |

            Examples:
              | accountNumber | balance     |
              | ACC-001       | one million |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Accounts Management
       */
      @DisplayName("AccountsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/AccountsFeature.feature")
      public class AccountsFeatureTest extends AccountsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          accountNumber | balance
                          ACC-001       | one million
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create account with invalid balance")
          public void scenario_1(String accountNumber, String balance) {
              /*
               * Given the following accounts:
               *   | account number  | balance   |
               *   | <accountNumber> | <balance> |
               */
              theFollowingAccounts(
                      List.of(
                              new AccountsParam(
                                      accountNumber,
                                      balance
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to java.lang.Long
      """

  Rule: example table values that are numeric but are then used in mixed usage style (literal + reference) for Long fields are treated as Strings and result in compilation error

    Example: with mixed usage style - literal + reference in same cell for Long field
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

              private final long amount;

              public TransactionsParam(String transactionId, long amount) {
                  this.transactionId = transactionId;
                  this.amount = amount;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario Outline: Create transaction with prefixed amount
            Given the following transactions:
              | transaction id   | amount         |
              | <transactionId>  | amount-<amount> |

            Examples:
              | transactionId | amount       |
              | TXN-001       | 3000000000   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Long;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          transactionId | amount
                          TXN-001       | 3000000000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create transaction with prefixed amount")
          public void scenario_1(String transactionId, Long amount) {
              /*
               * Given the following transactions:
               *   | transaction id  | amount          |
               *   | <transactionId> | amount-<amount> |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      transactionId,
                                      "amount-<amount>".replaceAll("<amount>", amount.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to long
      """

  Rule: multiple placeholders for Long field in one cell are treated as Strings and result in compilation error

    Example: with multiple references inside the same cell for Long field
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
              private final long amount;

              public TransactionsParam(String transactionId, long amount) {
                  this.transactionId = transactionId;
                  this.amount = amount;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Transactions Management
          Scenario Outline: Create transaction with concatenated amount
            Given the following transactions:
              | transaction id | amount               |
              | TXN-001        | <billions><millions> |

            Examples:
              | billions | millions |
              | 3        | 000000000 |
              | 5        | 000000000 |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Transactions Management
       */
      @DisplayName("TransactionsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/TransactionsFeature.feature")
      public class TransactionsFeatureTest extends TransactionsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          billions | millions
                          3        | 000000000
                          5        | 000000000
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create transaction with concatenated amount")
          public void scenario_1(Integer billions, Integer millions) {
              /*
               * Given the following transactions:
               *   | transaction id | amount               |
               *   | TXN-001        | <billions><millions> |
               */
              theFollowingTransactions(
                      List.of(
                              new TransactionsParam(
                                      "TXN-001",
                                      "<billions><millions>".replaceAll("<billions>", billions.toString()).replaceAll("<millions>", millions.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to long
      """

  # Double type inference rules
  #####################################################################################################################

  Rule: example table values that are decimal numbers can be passed directly for double type fields

    Example: field type is primitive double
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final double price;

              public ProductsParam(String name, double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with price
            Given the following products:
              | name          | price   |
              | <productName> | <price> |

            Examples:
              | productName | price  |
              | Laptop      | 999.99 |
              | Mouse       | 19.50  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | 999.99
                          Mouse       | 19.50
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with price")
          public void scenario_1(String productName, Double price) {
              /*
               * Given the following products:
               *   | name          | price   |
               *   | <productName> | <price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      price
                              )
                      ));
          }
      }
      """

    Example: field type is Double wrapper type
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final Double price;

              public ProductsParam(String name, Double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with wrapper price
            Given the following products:
              | name          | price   |
              | <productName> | <price> |

            Examples:
              | productName | price  |
              | Laptop      | 999.99 |
              | Mouse       | 19.50  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | 999.99
                          Mouse       | 19.50
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with wrapper price")
          public void scenario_1(String productName, Double price) {
              /*
               * Given the following products:
               *   | name          | price   |
               *   | <productName> | <price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      price
                              )
                      ));
          }
      }
      """

  Rule: example table values that are integer numbers can be passed for double type fields due to primitive widening

    Example: integer values passed to primitive double field
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final double price;

              public ProductsParam(String name, double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with integer price
            Given the following products:
              | name          | price   |
              | <productName> | <price> |

            Examples:
              | productName | price |
              | Laptop      | 1000  |
              | Mouse       | 20    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | 1000
                          Mouse       | 20
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with integer price")
          public void scenario_1(String productName, Integer price) {
              /*
               * Given the following products:
               *   | name          | price   |
               *   | <productName> | <price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      price
                              )
                      ));
          }
      }
      """

  Rule: example table values that are non-numeric for double type fields are passed as string and produce compilation error

    Example: with non-numeric value in examples table for Double field type
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final Double price;

              public ProductsParam(String name, Double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with invalid price
            Given the following products:
              | name          | price   |
              | <productName> | <price> |

            Examples:
              | productName | price       |
              | Laptop      | expensive   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | expensive
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with invalid price")
          public void scenario_1(String productName, String price) {
              /*
               * Given the following products:
               *   | name          | price   |
               *   | <productName> | <price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      price
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to java.lang.Double
      """

  Rule: example table values that are numeric but are then used in mixed usage style (literal + reference) for Double fields are treated as Strings and result in compilation error

    Example: with mixed usage style - literal + reference in same cell for Double field
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final double price;

              public ProductsParam(String name, double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with prefixed price
            Given the following products:
              | name          | price         |
              | <productName> | price-<price> |

            Examples:
              | productName | price  |
              | Laptop      | 999.99 |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | 999.99
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with prefixed price")
          public void scenario_1(String productName, Double price) {
              /*
               * Given the following products:
               *   | name          | price         |
               *   | <productName> | price-<price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      "price-<price>".replaceAll("<price>", price.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to double
      """

  Rule: multiple placeholders for Double field in one cell are treated as Strings and result in compilation error

    Example: with multiple references inside the same cell for Double field
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;
              private final double price;

              public ProductsParam(String name, double price) {
                  this.name = name;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with concatenated price
            Given the following products:
              | name    | price               |
              | Laptop  | <dollars>.<cents>   |

            Examples:
              | dollars | cents |
              | 999     | 99    |
              | 19      | 50    |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          dollars | cents
                          999     | 99
                          19      | 50
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with concatenated price")
          public void scenario_1(Integer dollars, Integer cents) {
              /*
               * Given the following products:
               *   | name   | price             |
               *   | Laptop | <dollars>.<cents> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      "<dollars>.<cents>".replaceAll("<dollars>", dollars.toString()).replaceAll("<cents>", cents.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to double
      """

  # Boolean type inference rules
  #####################################################################################################################

  Rule: example table values that are true or false can be passed directly for boolean type fields

    Example: field type is primitive boolean
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final boolean active;

              public UsersParam(String name, boolean active) {
                  this.name = name;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with active status
            Given the following users:
              | name   | active   |
              | <name> | <active> |

            Examples:
              | name  | active |
              | Alice | true   |
              | Bob   | false  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | active
                          Alice | true
                          Bob   | false
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with active status")
          public void scenario_1(String name, Boolean active) {
              /*
               * Given the following users:
               *   | name   | active   |
               *   | <name> | <active> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      active
                              )
                      ));
          }
      }
      """

    Example: field type is Boolean wrapper type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final Boolean active;

              public UsersParam(String name, Boolean active) {
                  this.name = name;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with wrapper active status
            Given the following users:
              | name   | active   |
              | <name> | <active> |

            Examples:
              | name  | active |
              | Alice | true   |
              | Bob   | false  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | active
                          Alice | true
                          Bob   | false
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with wrapper active status")
          public void scenario_1(String name, Boolean active) {
              /*
               * Given the following users:
               *   | name   | active   |
               *   | <name> | <active> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      active
                              )
                      ));
          }
      }
      """

  Rule: example table values that are not true or false for boolean type fields are passed as string and produce compilation error

    Example: with non-boolean value in examples table for Boolean field type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final Boolean active;

              public UsersParam(String name, Boolean active) {
                  this.name = name;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with invalid active status
            Given the following users:
              | name   | active   |
              | <name> | <active> |

            Examples:
              | name  | active |
              | Alice | yes    |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | active
                          Alice | yes
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with invalid active status")
          public void scenario_1(String name, String active) {
              /*
               * Given the following users:
               *   | name   | active   |
               *   | <name> | <active> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      active
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to java.lang.Boolean
      """

  Rule: example table values that are boolean but are then used in mixed usage style (literal + reference) for Boolean fields are treated as Strings and result in compilation error

    Example: with mixed usage style - literal + reference in same cell for Boolean field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;

              private final boolean active;

              public UsersParam(String name, boolean active) {
                  this.name = name;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with prefixed active status
            Given the following users:
              | name   | active           |
              | <name> | active-<active>  |

            Examples:
              | name  | active |
              | Alice | true   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | active
                          Alice | true
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with prefixed active status")
          public void scenario_1(String name, Boolean active) {
              /*
               * Given the following users:
               *   | name   | active          |
               *   | <name> | active-<active> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      "active-<active>".replaceAll("<active>", active.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to boolean
      """

  Rule: multiple placeholders for Boolean field in one cell are treated as Strings and result in compilation error

    Example: with multiple references inside the same cell for Boolean field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;
              private final boolean active;

              public UsersParam(String name, boolean active) {
                  this.name = name;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with concatenated active status
            Given the following users:
              | name  | active            |
              | Alice | <prefix><suffix>  |

            Examples:
              | prefix | suffix |
              | tr     | ue     |
              | fal    | se     |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          prefix | suffix
                          tr     | ue
                          fal    | se
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with concatenated active status")
          public void scenario_1(String prefix, String suffix) {
              /*
               * Given the following users:
               *   | name  | active           |
               *   | Alice | <prefix><suffix> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      "Alice",
                                      "<prefix><suffix>".replaceAll("<prefix>", prefix).replaceAll("<suffix>", suffix)
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to boolean
      """

  # Character type inference rules
  #####################################################################################################################

  Rule: example table values that are single characters can be passed directly for char type fields

    Example: field type is primitive char
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

              private final String student;

              private final char grade;

              public GradesParam(String student, char grade) {
                  this.student = student;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario Outline: Assign grade to student
            Given the following grades:
              | student   | grade   |
              | <student> | <grade> |

            Examples:
              | student | grade |
              | Alice   | A     |
              | Bob     | B     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Character;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          student | grade
                          Alice   | A
                          Bob     | B
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Assign grade to student")
          public void scenario_1(String student, Character grade) {
              /*
               * Given the following grades:
               *   | student   | grade   |
               *   | <student> | <grade> |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      student,
                                      grade
                              )
                      ));
          }
      }
      """

    Example: field type is Character wrapper type
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

              private final String student;

              private final Character grade;

              public GradesParam(String student, Character grade) {
                  this.student = student;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario Outline: Assign wrapper grade to student
            Given the following grades:
              | student   | grade   |
              | <student> | <grade> |

            Examples:
              | student | grade |
              | Alice   | A     |
              | Bob     | B     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Character;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          student | grade
                          Alice   | A
                          Bob     | B
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Assign wrapper grade to student")
          public void scenario_1(String student, Character grade) {
              /*
               * Given the following grades:
               *   | student   | grade   |
               *   | <student> | <grade> |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      student,
                                      grade
                              )
                      ));
          }
      }
      """

  Rule: example table values that are multiple characters for char type fields are passed as string and produce compilation error

    Example: with multi-character value in examples table for Character field type
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

              private final String student;

              private final Character grade;

              public GradesParam(String student, Character grade) {
                  this.student = student;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario Outline: Assign invalid grade to student
            Given the following grades:
              | student   | grade   |
              | <student> | <grade> |

            Examples:
              | student | grade     |
              | Alice   | Excellent |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          student | grade
                          Alice   | Excellent
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Assign invalid grade to student")
          public void scenario_1(String student, String grade) {
              /*
               * Given the following grades:
               *   | student   | grade   |
               *   | <student> | <grade> |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      student,
                                      grade
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to java.lang.Character
      """

  Rule: example table values that are single characters but are then used in mixed usage style (literal + reference) for Character fields are treated as Strings and result in compilation error

    Example: with mixed usage style - literal + reference in same cell for Character field
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

              private final String student;

              private final char grade;

              public GradesParam(String student, char grade) {
                  this.student = student;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario Outline: Assign grade with prefix to student
            Given the following grades:
              | student   | grade          |
              | <student> | grade-<grade>  |

            Examples:
              | student | grade |
              | Alice   | A     |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Character;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          student | grade
                          Alice   | A
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Assign grade with prefix to student")
          public void scenario_1(String student, Character grade) {
              /*
               * Given the following grades:
               *   | student   | grade         |
               *   | <student> | grade-<grade> |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      student,
                                      "grade-<grade>".replaceAll("<grade>", grade.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to char
      """

  Rule: multiple placeholders for Character field in one cell are treated as Strings and result in compilation error

    Example: with multiple references inside the same cell for Character field
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

              private final String student;
              private final char grade;

              public GradesParam(String student, char grade) {
                  this.student = student;
                  this.grade = grade;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Grades Management
          Scenario Outline: Assign concatenated grade to student
            Given the following grades:
              | student | grade           |
              | Alice   | <first><second> |

            Examples:
              | first | second |
              | A     | +      |
              | B     | -      |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Character;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Grades Management
       */
      @DisplayName("GradesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/GradesFeature.feature")
      public class GradesFeatureTest extends GradesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second
                          A     | +
                          B     | -
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Assign concatenated grade to student")
          public void scenario_1(Character first, Character second) {
              /*
               * Given the following grades:
               *   | student | grade           |
               *   | Alice   | <first><second> |
               */
              theFollowingGrades(
                      List.of(
                              new GradesParam(
                                      "Alice",
                                      "<first><second>".replaceAll("<first>", first.toString()).replaceAll("<second>", second.toString())
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
      """
      incompatible types: java.lang.String cannot be converted to char
      """

  # Other
  #####################################################################################################################

  Rule: mixed literal values and Example references in data table are infered each independently

    Example: Data table with mix of literal values and Example references
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

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;

              private final int stock;

              private final double price;

              public ProductsParam(String name, int stock, Double price) {
                  this.name = name;
                  this.stock = stock;
                  this.price = price;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with dynamic price
            Given the following products:
              | name          | stock | price   |
              | <productName> | 100   | <price> |

            Examples:
              | productName | price  |
              | Laptop      | 999.99 |
              | Mouse       | 19.99  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | price
                          Laptop      | 999.99
                          Mouse       | 19.99
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with dynamic price")
          public void scenario_1(String productName, Double price) {
              /*
               * Given the following products:
               *   | name          | stock | price   |
               *   | <productName> | 100   | <price> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      100,
                                      price
                              )
                      ));
          }
      }
      """

    Example: Data table with multiple rows where only some have Example references
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

          public void theFollowingEmployees(List<EmployeesParam> employees) {
          }

          public static class EmployeesParam {

              private final String name;
              private final Integer employeeId;
              private final boolean active;

              public EmployeesParam(String name, Integer employeeId, boolean active) {
                  this.name = name;
                  this.employeeId = employeeId;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Employees Management
          Scenario Outline: Register employees with dynamic data
            Given the following employees:
              | name       | employee id | active   |
              | <employee> | <empId>     | <status> |
              | Manager    | 9999        | true     |

            Examples:
              | employee | empId | status |
              | Alice    | 1001  | true   |
              | Bob      | 1002  | false  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Employees Management
       */
      @DisplayName("EmployeesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/EmployeesFeature.feature")
      public class EmployeesFeatureTest extends EmployeesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          employee | empId | status
                          Alice    | 1001  | true
                          Bob      | 1002  | false
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Register employees with dynamic data")
          public void scenario_1(String employee, Integer empId, Boolean status) {
              /*
               * Given the following employees:
               *   | name       | employee id | active   |
               *   | <employee> | <empId>     | <status> |
               *   | Manager    | 9999        | true     |
               */
              theFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      employee,
                                      empId,
                                      status
                              ),
                              new EmployeesParam(
                                      "Manager",
                                      9999,
                                      true
                              )
                      ));
          }
      }
      """

    Example: Data table cell with concatenated Example reference and literal text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String username;
              private final String email;

              public UsersParam(String username, String email) {
                  this.username = username;
                  this.email = email;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with generated email
            Given the following users:
              | username | email               |
              | <user>   | <user>@example.com  |

            Examples:
              | user  |
              | alice |
              | bob   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          user
                          alice
                          bob
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with generated email")
          public void scenario_1(String user) {
              /*
               * Given the following users:
               *   | username | email              |
               *   | <user>   | <user>@example.com |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      user,
                                      "<user>@example.com".replaceAll("<user>", user)
                              )
                      ));
          }
      }
      """

    Example: Data table cell with mixed literal and references for multiple typed columns
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

          public void theFollowingEmployees(List<EmployeesParam> employees) {
          }

          public static class EmployeesParam {

              private final String name;
              private final String identifier;
              private final String description;
              private final String statusText;

              public EmployeesParam(String name, String identifier, String description, String statusText) {
                  this.name = name;
                  this.identifier = identifier;
                  this.description = description;
                  this.statusText = statusText;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Employees Management
          Scenario Outline: Register employee with mixed references
            Given the following employees:
              | name   | identifier   | description                           | status text                   |
              | <name> | EMP-<empId>  | <name> (age: <age>, active: <active>) | Status: <active>, ID: <empId> |

            Examples:
              | name  | empId | age | active |
              | Alice | 1001  | 30  | true   |
              | Bob   | 1002  | 25  | false  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.Integer;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Employees Management
       */
      @DisplayName("EmployeesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/EmployeesFeature.feature")
      public class EmployeesFeatureTest extends EmployeesFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | empId | age | active
                          Alice | 1001  | 30  | true
                          Bob   | 1002  | 25  | false
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Register employee with mixed references")
          public void scenario_1(String name, Integer empId, Integer age, Boolean active) {
              /*
               * Given the following employees:
               *   | name   | identifier  | description                           | status text                   |
               *   | <name> | EMP-<empId> | <name> (age: <age>, active: <active>) | Status: <active>, ID: <empId> |
               */
              theFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      name,
                                      "EMP-<empId>".replaceAll("<empId>", empId.toString()),
                                      "<name> (age: <age>, active: <active>)".replaceAll("<name>", name).replaceAll("<age>", age.toString()).replaceAll("<active>", active.toString()),
                                      "Status: <active>, ID: <empId>".replaceAll("<empId>", empId.toString()).replaceAll("<active>", active.toString())
                              )
                      ));
          }
      }
      """


#      enums

    Example: Data table with Example reference for enum field uses valueOf conversion
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

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void theFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;
              private final Status status;

              public ProductsParam(String name, Status status) {
                  this.name = name;
                  this.status = status;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario Outline: Create product with dynamic status
            Given the following products:
              | name          | status   |
              | <productName> | <status> |

            Examples:
              | productName | status       |
              | Laptop      | AVAILABLE    |
              | Mouse       | OUT_OF_STOCK |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | status
                          Laptop      | AVAILABLE
                          Mouse       | OUT_OF_STOCK
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create product with dynamic status")
          public void scenario_1(String productName, ProductsFeature.Status status) {
              /*
               * Given the following products:
               *   | name          | status   |
               *   | <productName> | <status> |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      status
                              )
                      ));
          }
      }
      """




    Example: Data table with all literal values in Scenario Outline behaves like regular Scenario
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void theFollowingUsers(List<UsersParam> users) {
          }

          public static class UsersParam {

              private final String name;
              private final int age;

              public UsersParam(String name, int age) {
                  this.name = name;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with literal data table
            Given the following users:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |

            Examples:
              | scenario_variant |
              | variant_1        |
              | variant_2        |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          scenario_variant
                          variant_1
                          variant_2
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with literal data table")
          public void scenario_1(String scenario_variant) {
              /*
               * Given the following users:
               *   | name  | age |
               *   | Alice | 30  |
               *   | Bob   | 25  |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      "Alice",
                                      30
                              ),
                              new UsersParam(
                                      "Bob",
                                      25
                              )
                      ));
          }
      }
      """


