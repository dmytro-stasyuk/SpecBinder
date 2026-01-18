Ability: InnerParamTypeInheritance
  As a developer writing BDD tests with parameterized data tables
  I want the generator to intelligently reuse existing inner parameter classes from my base class hierarchy
  So that I can maintain consistent type definitions across tests and avoid code duplication when evolving my test data structures

  Rule: for inherited methods that take in as argument a list of custom object types can be reused with step data tables if data table columns can be mapped to its fields

    Scenario: base class has inner type with fields that match data table columns
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
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUserParam("Alice", "30", "alice@gmail.com"),
                              new BaseUserParam("Bob", "25", "bob@gmail.com")
                      ));
          }
      }
      """

    Scenario: base class has inner type with fields that match data table columns but in in different order
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
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUserParam("alice@gmail.com", "30", "Alice"),
                              new BaseUserParam("bob@gmail.com", "25", "Bob")
                      ));
          }
      }
      """

    Example: [counter example] base class with inner type with fields that do not have all the required step data columns
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

              public BaseUserParam(String name, String age) {
                  this.name = name;
                  this.age = age;
              }

              public String name() {
                  return this.name;
              }

              public String age() {
                  return this.age;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", "alice@gmail.com"),
                              new UsersParam("Bob", "25", "bob@gmail.com")
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final String age;

              private final String email;

              public UsersParam(String name, String age, String email) {
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
      And the generator error should contain the following text:
        """
        name clash: givenTheFollowingUsers(java.util.List<features.UsersFeatureTest.UsersParam>) in features.UsersFeatureTest and givenTheFollowingUsers(java.util.List<features.UsersFeature.BaseUserParam>) in features.UsersFeature have the same erasure, yet neither overrides the other
        """

  Rule: for inherited methods that that take in as argument a list of custom record types can be reused if the data table columns can be mapped to its fields

    Scenario: base class has a matching step with a list parameter where generic type has fields that match data table columns
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
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", "alice@gmail.com"),
                              new UsersParam("Bob", "25", "bob@gmail.com")
                      ));
          }
      }
      """

    Scenario: base class has a matching step with a list parameter where generic type has fields that match data table columns but in different order
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

          public record UsersParam(String email, String age, String name) {}

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("alice@gmail.com", "30", "Alice"),
                              new UsersParam("bob@gmail.com", "25", "Bob")
                      ));
          }
      }
      """

    Example: [counter example] base class has a matching step with a list parameter where generic type has fields that do not have all the required step data columns
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

          public record BaseUsersParam(String name, String age) {}

          public void givenTheFollowingUsers(List<BaseUsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age | email           |
              | Alice | 30  | alice@gmail.com |
              | Bob   | 25  | bob@gmail.com   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email           |
               *   | Alice | 30  | alice@gmail.com |
               *   | Bob   | 25  | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", "alice@gmail.com"),
                              new UsersParam("Bob", "25", "bob@gmail.com")
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final String age;

              private final String email;

              public UsersParam(String name, String age, String email) {
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
  And the generator error should contain the following text:
  """
  name clash: givenTheFollowingUsers(java.util.List<features.UsersFeatureTest.UsersParam>) in features.UsersFeatureTest and givenTheFollowingUsers(java.util.List<features.UsersFeature.BaseUsersParam>) in features.UsersFeature have the same erasure, yet neither overrides the other
  """

  Rule: existing inner class can have more fields than the specified data table columns

    Example: base class has a matching step with a list parameter type where generic type has extra fields beyond data table columns
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

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UsersParam {

              private final String name;
              private final String age;
              private final String email;
              private final String phone;

              public UsersParam(String name, String age, String email, String phone) {
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
          Scenario: Create users
            Given the following users:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age |
               *   | Alice | 30  |
               *   | Bob   | 25  |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", null, null),
                              new UsersParam("Bob", "25", null, null)
                      ));
          }
      }
      """

    Example: base class has inner record with required name and extra fields beyond data table columns
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

          public record UsersParam(String name, String age, String email, String phone) {
          }

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age |
               *   | Alice | 30  |
               *   | Bob   | 25  |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", null, null),
                              new UsersParam("Bob", "25", null, null)
                      ));
          }
      }
      """

    Example: base class has inner type has extra fields beyond data table columns, that are specified in different order in the constructor
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

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UsersParam {

              private final String email;
              private final String name;
              private final String phone;
              private final String age;

              public UsersParam(String email, String name,  String phone, String age) {
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
          Scenario: Create users
            Given the following users:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age |
               *   | Alice | 30  |
               *   | Bob   | 25  |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam(null, "Alice", null, "30"),
                              new UsersParam(null, "Bob", null, "25")
                      ));
          }
      }
      """

    Example: base class has inner record that has extra fields beyond data table columns, that are specified in different order in the constructor
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public record UsersParam(String email, String name,  String phone, String age) {
          }

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | age |
              | Alice | 30  |
              | Bob   | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age |
               *   | Alice | 30  |
               *   | Bob   | 25  |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam(null, "Alice", null, "30"),
                              new UsersParam(null, "Bob", null, "25")
                      ));
          }
      }
      """

  Rule: if the existing inner type doesn't have a constructor matching all step data table columns (in any order) it is not used and a new inner class is generated instead

    Scenario: Existing inner class missing constructor for data table columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<BaseUsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class BaseUsersParam {

              private final String name;
              private final String age;
              private final String email;

              public BaseUsersParam(String name, String age) {
                  this.name = name;
                  this.age = age;
                  this.email = null;
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
          Scenario: Create users
            Given the following users:
              | name  | age | email          |
              | Alice | 30  | alice@test.com |
              | Bob   | 25  | bob@test.com   |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | name  | age | email          |
               *   | Alice | 30  | alice@test.com |
               *   | Bob   | 25  | bob@test.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", "alice@test.com"),
                              new UsersParam("Bob", "25", "bob@test.com")
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final String age;

              private final String email;

              public UsersParam(String name, String age, String email) {
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
      And the generator error should contain the following text:
        """
        name clash: givenTheFollowingUsers(java.util.List<features.UsersFeatureTest.UsersParam>) in features.UsersFeatureTest and givenTheFollowingUsers(java.util.List<features.UsersFeature.BaseUsersParam>) in features.UsersFeature have the same erasure, yet neither overrides the other
        """

  Rule: all data table columns must be mappable to fields (for classes) or components (for records) in the existing type using the current field naming logic

    Scenario: Data table column headers have spaces
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UsersParam {

              private final String firstName;
              private final String age;
              private final String emailAddress;

              public UsersParam(String firstName, String age, String emailAddress) {
                  this.firstName = firstName;
                  this.age = age;
                  this.emailAddress = emailAddress;
              }

              public String firstName() {
                  return this.firstName;
              }

              public String age() {
                  return this.age;
              }

              public String emailAddress() {
                  return this.emailAddress;
              }
          }

          protected List<Map<String, String>> createListOfMaps(String tableLines) {
              return null;
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | first name | age |
              | Alice      | 30  |
              | Bob        | 25  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | first name | age |
               *   | Alice      | 30  |
               *   | Bob        | 25  |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", null),
                              new UsersParam("Bob", "25", null)
                      ));
          }
      }
      """

    Example: Data table column headers have several words, and capital letters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<UsersParam> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class UsersParam {

              private final String firstName;
              private final String userAge;
              private final String emailAddress;

              public UsersParam(String firstName, String userAge, String emailAddress) {
                  this.firstName = firstName;
                  this.userAge = userAge;
                  this.emailAddress = emailAddress;
              }

              public String firstName() {
                  return this.firstName;
              }

              public String userAge() {
                  return this.userAge;
              }

              public String emailAddress() {
                  return this.emailAddress;
              }
          }

          protected List<Map<String, String>> createListOfMaps(String tableLines) {
              return null;
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | First Name | User Age | Email Address   |
              | Alice      | 30       | alice@gmail.com |
              | Bob        | 25       | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | First Name | User Age | Email Address   |
               *   | Alice      | 30       | alice@gmail.com |
               *   | Bob        | 25       | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "30", "alice@gmail.com"),
                              new UsersParam("Bob", "25", "bob@gmail.com")
                      ));
          }
      }
      """

    Example: Data table column headers have illegal java identifier characters in them
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

          public void givenTheFollowingUsers(List<BaseUsersFeature> users) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class BaseUsersFeature {

              private final String username;

              private final String userage;

              private final String emailaddress;

              public BaseUsersFeature(String username, String userage, String emailaddress) {
                  this.username = username;
                  this.userage = userage;
                  this.emailaddress = emailaddress;
              }

              public String username() {
                  return this.username;
              }

              public String userage() {
                  return this.userage;
              }

              public String emailaddress() {
                  return this.emailaddress;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | user-name | user&age | email@address   |
              | Alice     | 30       | alice@gmail.com |
              | Bob       | 25       | bob@gmail.com   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Users Management
       */
      @DisplayName("UsersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UsersFeature.feature")
      public class UsersFeatureTest extends UsersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create users")
          public void scenario_1() {
              /*
               * Given the following users:
               *   | user-name | user&age | email@address   |
               *   | Alice     | 30       | alice@gmail.com |
               *   | Bob       | 25       | bob@gmail.com   |
               */
              givenTheFollowingUsers(
                      List.of(
                              new BaseUsersFeature("Alice", "30", "alice@gmail.com"),
                              new BaseUsersFeature("Bob", "25", "bob@gmail.com")
                      ));
          }
      }
      """




