Ability: InheritedStepMethodsAndCustomObjectTypes
  As a developer writing BDD tests with parameterized data tables
  I want the generator to intelligently reuse existing inner parameter classes from my base class hierarchy
  So that I can maintain consistent type definitions across tests and avoid code duplication when evolving my test data structures

  Rule: step is considered a match if all of step's data table columns can be mapped to the fields of custom object/record type

    Scenario: data table columns can be matched to fields of custom object type
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
                              new BaseUserParam(
                                      "Alice",
                                      "30",
                                      "alice@gmail.com"
                              ),
                              new BaseUserParam(
                                      "Bob",
                                      "25",
                                      "bob@gmail.com"
                              )
                      ));
          }
      }
      """

    Scenario: data table columns can be matched to fields of custom object type but in in different order
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
                              new BaseUserParam(
                                      "alice@gmail.com",
                                      "30",
                                      "Alice"
                              ),
                              new BaseUserParam(
                                      "bob@gmail.com",
                                      "25",
                                      "Bob"
                              )
                      ));
          }
      }
      """

    Scenario: data table columns can be matched to fields of custom record type
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

          public record BaseUserParam(String name, String age, String email) {
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
                              new BaseUserParam(
                                      "Alice",
                                      "30",
                                      "alice@gmail.com"
                              ),
                              new BaseUserParam(
                                      "Bob",
                                      "25",
                                      "bob@gmail.com"
                              )
                      ));
          }
      }
      """

    Scenario: data table columns can be matched to fields of custom record type but in in different order
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

          public record BaseUserParam(String email, String age, String name) {
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
                              new BaseUserParam(
                                      "alice@gmail.com",
                                      "30",
                                      "Alice"
                              ),
                              new BaseUserParam(
                                      "bob@gmail.com",
                                      "25",
                                      "Bob"
                              )
                      ));
          }
      }
      """

  Rule: if not all columns from the step's data table can be matched to fields then it is not used and a new inner object type is generated instead

    Example: not all data table columns can be matched to fields of custom object type
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
      import java.lang.Integer;
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
                              new UsersParam(
                                      "Alice",
                                      30,
                                      "alice@gmail.com"
                              ),
                              new UsersParam(
                                      "Bob",
                                      25,
                                      "bob@gmail.com"
                              )
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final Integer age;

              private final String email;

              public UsersParam(String name, Integer age, String email) {
                  this.name = name;
                  this.age = age;
                  this.email = email;
              }

              public String name() {
                  return this.name;
              }

              public Integer age() {
                  return this.age;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """
      And the compilation error should contain the following text:
        """
        name clash: givenTheFollowingUsers(java.util.List<features.UsersFeatureTest.UsersParam>) in features.UsersFeatureTest and givenTheFollowingUsers(java.util.List<features.UsersFeature.BaseUserParam>) in features.UsersFeature have the same erasure, yet neither overrides the other
        """

    Example: not all data table columns can be matched to fields of custom record type
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

          public record BaseUserParam(String name, String age) {
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
      import java.lang.Integer;
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
                              new UsersParam(
                                      "Alice",
                                      30,
                                      "alice@gmail.com"
                              ),
                              new UsersParam(
                                      "Bob",
                                      25,
                                      "bob@gmail.com"
                              )
                      ));
          }

          public static class UsersParam {
              private final String name;

              private final Integer age;

              private final String email;

              public UsersParam(String name, Integer age, String email) {
                  this.name = name;
                  this.age = age;
                  this.email = email;
              }

              public String name() {
                  return this.name;
              }

              public Integer age() {
                  return this.age;
              }

              public String email() {
                  return this.email;
              }
          }
      }
      """
      And the compilation error should contain the following text:
        """
        name clash: givenTheFollowingUsers(java.util.List<features.UsersFeatureTest.UsersParam>) in features.UsersFeatureTest and givenTheFollowingUsers(java.util.List<features.UsersFeature.BaseUserParam>) in features.UsersFeature have the same erasure, yet neither overrides the other
        """

  Rule: custom object/record type can have more fields than the specified data table columns

    Example: custom object type has extra fields beyond data table columns
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
                              new UsersParam(
                                      "Alice",
                                      "30",
                                      null,
                                      null
                              ),
                              new UsersParam(
                                      "Bob",
                                      "25",
                                      null,
                                      null
                              )
                      ));
          }
      }
      """

    Example: custom object type has extra fields beyond data table columns, that are specified in different order in the constructor
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
                              new UsersParam(
                                      null,
                                      "Alice",
                                      null,
                                      "30"
                              ),
                              new UsersParam(
                                      null,
                                      "Bob",
                                      null,
                                      "25"
                              )
                      ));
          }
      }
      """

    Example: custom record type has extra fields beyond data table columns
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
                              new UsersParam(
                                      "Alice",
                                      "30",
                                      null,
                                      null
                              ),
                              new UsersParam(
                                      "Bob",
                                      "25",
                                      null,
                                      null
                              )
                      ));
          }
      }
      """

    Example: custom record type has extra fields beyond data table columns, that are specified in different order in the constructor
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
                              new UsersParam(
                                      null,
                                      "Alice",
                                      null,
                                      "30"
                              ),
                              new UsersParam(
                                      null,
                                      "Bob",
                                      null,
                                      "25"
                              )
                      ));
          }
      }
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
                              new UsersParam(
                                      "Alice",
                                      "30",
                                      null
                              ),
                              new UsersParam(
                                      "Bob",
                                      "25",
                                      null
                              )
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
                              new UsersParam(
                                      "Alice",
                                      "30",
                                      "alice@gmail.com"
                              ),
                              new UsersParam(
                                      "Bob",
                                      "25",
                                      "bob@gmail.com"
                              )
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
                              new BaseUsersFeature(
                                      "Alice",
                                      "30",
                                      "alice@gmail.com"
                              ),
                              new BaseUsersFeature(
                                      "Bob",
                                      "25",
                                      "bob@gmail.com"
                              )
                      ));
          }
      }
      """




