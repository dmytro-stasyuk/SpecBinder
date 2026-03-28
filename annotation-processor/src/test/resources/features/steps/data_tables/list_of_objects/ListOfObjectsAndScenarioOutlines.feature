Feature: MappingDataTableToListOfObjectsAndScenarioOutlines
  As a developer writing BDD step definitions with Scenario Outlines containing tabular test data
  I want data table placeholder references to Examples columns to be properly substituted in the generated parameterized test code
  So that I can combine the power of Scenario Outline parameterization with type-safe data table objects

  Rule: when a data table cell value is exactly a single placeholder like <exampleColumn>
  - the placeholder is replaced with the corresponding @ParameterizedTest method parameter
  - no string replacement is needed for single-placeholder cells

    Scenario: Data table with single placeholder per cell in Scenario Outline
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
            Given the following users:
              | name   | role   |
              | <name> | <role> |
              | John   | Smith  |
            Examples:
              | name  | role  |
              | Alice | Admin |
              | Bob   | User  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void theFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | role
                          Alice | Admin
                          Bob   | User
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String role) {
              /*
               * Given the following users:
               *   | name   | role   |
               *   | <name> | <role> |
               *   | John   | Smith  |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      role
                              ),
                              new UsersParam(
                                      "John",
                                      "Smith"
                              )
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final String role;

              public UsersParam(String name, String role) {
                  this.name = name;
                  this.role = role;
              }

              public String name() {
                  return this.name;
              }

              public String role() {
                  return this.role;
              }
          }
      }
      """

    Scenario: Data table with multiple rows mixing literal values and placeholders
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create users with mixed values
            Given the following users:
              | name   | role   |
              | <name> | Admin  |
              | Bob    | <role> |
            Examples:
              | name  | role  |
              | Alice | User  |
              | Carol | Guest |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void theFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | role
                          Alice | User
                          Carol | Guest
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create users with mixed values")
          public void scenario_1(String name, String role) {
              /*
               * Given the following users:
               *   | name   | role   |
               *   | <name> | Admin  |
               *   | Bob    | <role> |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      name,
                                      "Admin"
                              ),
                              new UsersParam(
                                      "Bob",
                                      role
                              )
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final String role;

              public UsersParam(String name, String role) {
                  this.name = name;
                  this.role = role;
              }

              public String name() {
                  return this.name;
              }

              public String role() {
                  return this.role;
              }
          }
      }
      """

  Rule: when a data table cell contains mixed content (literal text + placeholder) like "Hello <name>!", string replacement is used

    Scenario: Data table cell with literal text and placeholder mixed
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MessagesFeature {

      }
      """
      And the following feature file:
        """
        Feature: Messages
          Scenario Outline: Send greeting messages
            Given the following messages:
              | recipient | content         |
              | <name>    | Hello <name>!   |
            Examples:
              | name  |
              | Alice |
              | Bob   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Messages
       */
      @DisplayName("MessagesFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MessagesFeature.feature")
      public class MessagesFeatureTest extends MessagesFeature {
          public void theFollowingMessages(List<MessagesParam> messages) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name
                          Alice
                          Bob
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Send greeting messages")
          public void scenario_1(String name) {
              /*
               * Given the following messages:
               *   | recipient | content       |
               *   | <name>    | Hello <name>! |
               */
              theFollowingMessages(
                      List.of(
                              new MessagesParam(
                                      name,
                                      "Hello <name>!".replaceAll("<name>", name)
                              )
                      ));
          }

          public static class MessagesParam {
              private final String recipient;

              private final String content;

              public MessagesParam(String recipient, String content) {
                  this.recipient = recipient;
                  this.content = content;
              }

              public String recipient() {
                  return this.recipient;
              }

              public String content() {
                  return this.content;
              }
          }
      }
      """

    Scenario: Larger data table with mixed literal values and placeholder combinations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class NotificationsFeature {

      }
      """
      And the following feature file:
        """
        Feature: Notifications
          Scenario Outline: Send notifications to users
            Given the following notifications:
              | recipient | subject              | body                          | priority |
              | <name>    | Welcome <name>!      | Hello <name>, welcome to app! | high     |
              | admin     | New user: <name>     | User <name> (<email>) joined  | <level>  |
              | support   | Support notification | Standard support message      | low      |
            Examples:
              | name  | email           | level  |
              | Alice | alice@test.com  | medium |
              | Bob   | bob@test.com    | high   |
              | Carol | carol@test.com  | low    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Notifications
       */
      @DisplayName("NotificationsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/NotificationsFeature.feature")
      public class NotificationsFeatureTest extends NotificationsFeature {
          public void theFollowingNotifications(List<NotificationsParam> notifications) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | email          | level
                          Alice | alice@test.com | medium
                          Bob   | bob@test.com   | high
                          Carol | carol@test.com | low
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Send notifications to users")
          public void scenario_1(String name, String email, String level) {
              /*
               * Given the following notifications:
               *   | recipient | subject              | body                          | priority |
               *   | <name>    | Welcome <name>!      | Hello <name>, welcome to app! | high     |
               *   | admin     | New user: <name>     | User <name> (<email>) joined  | <level>  |
               *   | support   | Support notification | Standard support message      | low      |
               */
              theFollowingNotifications(
                      List.of(
                              new NotificationsParam(
                                      name,
                                      "Welcome <name>!".replaceAll("<name>", name),
                                      "Hello <name>, welcome to app!".replaceAll("<name>", name),
                                      "high"
                              ),
                              new NotificationsParam(
                                      "admin",
                                      "New user: <name>".replaceAll("<name>", name),
                                      "User <name> (<email>) joined".replaceAll("<name>", name).replaceAll("<email>", email),
                                      level
                              ),
                              new NotificationsParam(
                                      "support",
                                      "Support notification",
                                      "Standard support message",
                                      "low"
                              )
                      ));
          }

          public static class NotificationsParam {
              private final String recipient;

              private final String subject;

              private final String body;

              private final String priority;

              public NotificationsParam(String recipient, String subject, String body, String priority) {
                  this.recipient = recipient;
                  this.subject = subject;
                  this.body = body;
                  this.priority = priority;
              }

              public String recipient() {
                  return this.recipient;
              }

              public String subject() {
                  return this.subject;
              }

              public String body() {
                  return this.body;
              }

              public String priority() {
                  return this.priority;
              }
          }
      }
      """

  Rule: when a data table cell contains multiple placeholders like <firstName> <lastName>, all are replaced with corresponding parameter values

    Scenario: Data table cell with multiple placeholders
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ContactsFeature {

      }
      """
      And the following feature file:
        """
        Feature: Contacts
          Scenario Outline: Create contacts
            Given the following contacts:
              | fullName               | email                           |
              | <firstName> <lastName> | <firstName>.<lastName>@test.com |
            Examples:
              | firstName | lastName |
              | John      | Doe      |
              | Jane      | Smith    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Contacts
       */
      @DisplayName("ContactsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ContactsFeature.feature")
      public class ContactsFeatureTest extends ContactsFeature {
          public void theFollowingContacts(List<ContactsParam> contacts) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          firstName | lastName
                          John      | Doe
                          Jane      | Smith
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create contacts")
          public void scenario_1(String firstName, String lastName) {
              /*
               * Given the following contacts:
               *   | fullName               | email                           |
               *   | <firstName> <lastName> | <firstName>.<lastName>@test.com |
               */
              theFollowingContacts(
                      List.of(
                              new ContactsParam(
                                      "<firstName> <lastName>".replaceAll("<firstName>", firstName).replaceAll("<lastName>", lastName),
                                      "<firstName>.<lastName>@test.com".replaceAll("<firstName>", firstName).replaceAll("<lastName>", lastName)
                              )
                      ));
          }

          public static class ContactsParam {
              private final String fullName;

              private final String email;

              public ContactsParam(String fullName, String email) {
                  this.fullName = fullName;
                  this.email = email;
              }

              public String fullName() {
                  return this.fullName;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """

  Rule: different rows in the same data table may have different placeholder patterns or only literal values

    Scenario: Data table rows with varying placeholder patterns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class OrdersFeature {

      }
      """
      And the following feature file:
        """
        Feature: Orders
          Scenario Outline: Process orders
            Given the following orders:
              | customer   | product   | status    |
              | <customer> | <product> | pending   |
              | admin      | Widget    | completed |
              | <customer> | Gadget    | <status>  |
            Examples:
              | customer | product | status     |
              | Alice    | Phone   | processing |
              | Bob      | Laptop  | shipped    |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Orders
       */
      @DisplayName("OrdersFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/OrdersFeature.feature")
      public class OrdersFeatureTest extends OrdersFeature {
          public void theFollowingOrders(List<OrdersParam> orders) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          customer | product | status
                          Alice    | Phone   | processing
                          Bob      | Laptop  | shipped
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Process orders")
          public void scenario_1(String customer, String product, String status) {
              /*
               * Given the following orders:
               *   | customer   | product   | status    |
               *   | <customer> | <product> | pending   |
               *   | admin      | Widget    | completed |
               *   | <customer> | Gadget    | <status>  |
               */
              theFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      customer,
                                      product,
                                      "pending"
                              ),
                              new OrdersParam(
                                      "admin",
                                      "Widget",
                                      "completed"
                              ),
                              new OrdersParam(
                                      customer,
                                      "Gadget",
                                      status
                              )
                      ));
          }

          public static class OrdersParam {
              private final String customer;

              private final String product;

              private final String status;

              public OrdersParam(String customer, String product, String status) {
                  this.customer = customer;
                  this.product = product;
                  this.status = status;
              }

              public String customer() {
                  return this.customer;
              }

              public String product() {
                  return this.product;
              }

              public String status() {
                  return this.status;
              }
          }
      }
      """

  Rule: placeholders in step text and placeholders in data table values are handled together
  - step text placeholders like "<user>" become method parameters as usual
  - data table cell placeholders also use the same parameterized test arguments
  - both coexist in the generated @ParameterizedTest method

    Scenario: Placeholders in both step text and data table values
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CartFeature {

      }
      """
      And the following feature file:
        """
        Feature: Shopping Cart
          Scenario Outline: User adds items to cart
            Given user "<username>" has the following items:
              | item   | category   | status     |
              | <item> | <category> | active     |
              | Bonus  | gift       | <status>   |
            Examples:
              | username | item   | category    | status   |
              | Alice    | Phone  | electronics | pending  |
              | Bob      | Laptop | computers   | approved |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Shopping Cart
       */
      @DisplayName("CartFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/CartFeature.feature")
      public class CartFeatureTest extends CartFeature {
          public void user$p1HasTheFollowingItems(String p1, List<ItemsParam> items) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          username | item   | category    | status
                          Alice    | Phone  | electronics | pending
                          Bob      | Laptop | computers   | approved
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: User adds items to cart")
          public void scenario_1(String username, String item, String category, String status) {
              /*
               * Given user "<username>" has the following items:
               *   | item   | category   | status   |
               *   | <item> | <category> | active   |
               *   | Bonus  | gift       | <status> |
               */
              user$p1HasTheFollowingItems(username,
                      List.of(
                              new ItemsParam(
                                      item,
                                      category,
                                      "active"
                              ),
                              new ItemsParam(
                                      "Bonus",
                                      "gift",
                                      status
                              )
                      ));
          }

          public static class ItemsParam {
              private final String item;

              private final String category;

              private final String status;

              public ItemsParam(String item, String category, String status) {
                  this.item = item;
                  this.category = category;
                  this.status = status;
              }

              public String item() {
                  return this.item;
              }

              public String category() {
                  return this.category;
              }

              public String status() {
                  return this.status;
              }
          }
      }
      """
