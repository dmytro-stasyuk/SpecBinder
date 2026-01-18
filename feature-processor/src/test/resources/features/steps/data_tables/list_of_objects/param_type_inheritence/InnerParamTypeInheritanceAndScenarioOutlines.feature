Ability: InnerParamTypeInheritanceAndScenarioOutlines
  As a developer writing BDD tests with Scenario Outlines and parameterized data tables
  I want the generator to reuse inherited parameter types while properly substituting Example placeholders in data table cells
  So that I can combine inherited type reuse with parameterized test data in a single cohesive pattern

  Rule: when an inherited parameter type matches data table columns, placeholders in cell values are substituted using the inherited type's constructor
  - the inherited type (class or record) is reused instead of generating a new inner class
  - single placeholders like <name> are replaced with the corresponding method parameter
  - the constructor arguments are ordered according to the inherited type's constructor parameter order
  - literal values remain as string literals in the generated code

    Scenario: Inherited inner class with single placeholder per cell in Scenario Outline
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<BaseUserParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class BaseUserParam {

              private final String name;
              private final String age;
              private final String email;

              public BaseUserParam(String name, String age, String email) {
                  this.name = name;
                  this.age = age;
                  this.email = email;
              }

              public String name() {
                  return this.name;
              }

              public String age() {
                  return this.age;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
            Given the following users:
              | name   | age   | email   |
              | <name> | <age> | <email> |
            Examples:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
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
                          name  | age | email
                          Alice | 30  | alice@gmail.com
                          Bob   | 25  | bob@gmail.com
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age, String email) {
              /*
               * Given the following users:
               *   | name   | age   | email   |
               *   | <name> | <age> | <email> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUserParam(name, age, email)
                      ));
          }
      }
      """

    Scenario: Inherited inner class with constructor parameters in different order than data table columns
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<BaseUserParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class BaseUserParam {

              private final String email;
              private final String age;
              private final String name;

              public BaseUserParam(String email, String age, String name) {
                  this.email = email;
                  this.age = age;
                  this.name = name;
              }

              public String name() {
                  return this.name;
              }

              public String age() {
                  return this.age;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
            Given the following users:
              | name   | age   | email   |
              | <name> | <age> | <email> |
            Examples:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
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
                          name  | age | email
                          Alice | 30  | alice@gmail.com
                          Bob   | 25  | bob@gmail.com
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age, String email) {
              /*
               * Given the following users:
               *   | name   | age   | email   |
               *   | <name> | <age> | <email> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUserParam(email, age, name)
                      ));
          }
      }
      """

    Scenario: Inherited inner class with mix of placeholders and literal values in Scenario Outline
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<BaseUserParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class BaseUserParam {

              private final String name;
              private final String role;
              private final String email;

              public BaseUserParam(String name, String role, String email) {
                  this.name = name;
                  this.role = role;
                  this.email = email;
              }

              public String name() {
                  return this.name;
              }

              public String role() {
                  return this.role;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user with role
            Given the following users:
              | name   | role  | email   |
              | <name> | Admin | <email> |
            Examples:
              | name  | email           |
              | Alice | alice@gmail.com |
              | Bob   | bob@gmail.com   |
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
                          name  | email
                          Alice | alice@gmail.com
                          Bob   | bob@gmail.com
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user with role")
          public void scenario_1(String name, String email) {
              /*
               * Given the following users:
               *   | name   | role  | email   |
               *   | <name> | Admin | <email> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUserParam(name, "Admin", email)
                      ));
          }
      }
      """

  Rule: when an inherited parameter type is used with mixed content cells (literal + placeholder), string concatenation is applied
  - cells like "Hello <name>!" become "Hello " + name + "!" in the generated code
  - the inherited type's constructor is still used with concatenated expressions as arguments
  - constructor argument order follows the inherited type's parameter order

    Scenario: Inherited inner class with literal text and placeholder mixed in cell values
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MessagesFeature {

          public void givenTheFollowingMessages(List<MessageParam> messages) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class MessageParam {

              private final String recipient;
              private final String content;

              public MessageParam(String recipient, String content) {
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
      And the following feature file:
        """
        Feature: Messages
          Scenario Outline: Send greeting messages
            Given the following messages:
              | recipient | content       |
              | <name>    | Hello <name>! |
            Examples:
              | name  |
              | Alice |
              | Bob   |
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
       * Feature: Messages
       */
      @DisplayName("MessagesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MessagesFeature.feature")
      public class MessagesFeatureTest extends MessagesFeature {
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
              givenTheFollowingMessages(
                      List.of(
                              new MessageParam(name, "Hello " + name + "!")
                      ));
          }
      }
      """

  Rule: when an inherited parameter type is used with cells containing multiple placeholders, all placeholders are substituted
  - cells like "<firstName> <lastName>" become firstName + " " + lastName
  - each placeholder is replaced with its corresponding method parameter
  - concatenation follows the order of appearance in the cell value

    Scenario: Inherited inner class with multiple placeholders in a single cell
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ContactsFeature {

          public void givenTheFollowingContacts(List<ContactParam> contacts) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class ContactParam {

              private final String fullName;
              private final String email;

              public ContactParam(String fullName, String email) {
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
       * Feature: Contacts
       */
      @DisplayName("ContactsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ContactsFeature.feature")
      public class ContactsFeatureTest extends ContactsFeature {
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
              givenTheFollowingContacts(
                      List.of(
                              new ContactParam(firstName + " " + lastName, firstName + "." + lastName + "@test.com")
                      ));
          }
      }
      """

  Rule: when an inherited parameter type has more fields than the data table columns, nulls are passed for missing fields while placeholders are still substituted
  - columns present in the data table use values (with placeholder substitution where applicable)
  - columns not present in the data table receive null as constructor arguments
  - constructor argument order follows the inherited type's parameter order

    Scenario: Inherited inner class with extra fields beyond data table columns containing placeholders
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<UserParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UserParam {

              private final String name;
              private final String age;
              private final String email;
              private final String phone;

              public UserParam(String name, String age, String email, String phone) {
                  this.name = name;
                  this.age = age;
                  this.email = email;
                  this.phone = phone;
              }

              public String name() {
                  return this.name;
              }

              public String age() {
                  return this.age;
              }

              public String email() {
                  return this.email;
              }

              public String phone() {
                  return this.phone;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
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
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UserParam(name, age, null, null)
                      ));
          }
      }
      """

    Scenario: Inherited inner class with extra fields in different constructor order with placeholders
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<UserParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UserParam {

              private final String email;
              private final String name;
              private final String phone;
              private final String age;

              public UserParam(String email, String name, String phone, String age) {
                  this.email = email;
                  this.name = name;
                  this.phone = phone;
                  this.age = age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
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
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UserParam(null, name, null, age)
                      ));
          }
      }
      """

  Rule: inherited record types work identically to inherited inner classes with Scenario Outline placeholders
  - records with matching components are reused
  - placeholder substitution works the same way for records
  - constructor argument order follows the record's component order

    Scenario: Inherited record with single placeholder per cell in Scenario Outline
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public record UsersParam(String name, String age, String email) {}

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
            Given the following users:
              | name   | age   | email   |
              | <name> | <age> | <email> |
            Examples:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
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
                          name  | age | email
                          Alice | 30  | alice@gmail.com
                          Bob   | 25  | bob@gmail.com
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age, String email) {
              /*
               * Given the following users:
               *   | name   | age   | email   |
               *   | <name> | <age> | <email> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam(name, age, email)
                      ));
          }
      }
      """

    Scenario: Inherited record with extra fields and placeholders
      Given the following base class:
      """
      package features;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public record UsersParam(String email, String name, String phone, String age) {}

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario Outline: Create user
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
          @DisplayName("Scenario Outline: Create user")
          public void scenario_1(String name, String age) {
              /*
               * Given the following users:
               *   | name   | age   |
               *   | <name> | <age> |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam(null, name, null, age)
                      ));
          }
      }
      """

