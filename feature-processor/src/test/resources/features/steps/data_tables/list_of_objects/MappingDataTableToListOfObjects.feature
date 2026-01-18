Feature: MappingDataTableToListOfObjects
  As a developer writing BDD step definitions with tabular test data
  I want data tables automatically mapped to type-safe object classes with named fields matching column headers
  So that I get compile-time safety, IDE autocomplete, and refactoring support

  Rule: when "dataTableParameterType" option is set to "LIST_OF_OBJECT_PARAMS", data tables are mapped to List<ObjectParam> parameters
  - if a step has a DataTable, a generated record type is created with fields matching column headers
  - the record name is derived from the last word of the step's text (capitalised and converted to camel case if necessary) with "Param" suffix added
  - a parameter of type List<ObjectParam> is added to the step method, with the name derived from the last word of the step's text (lowercased)
  - the data is formatted with pipe delimiters and passed via createListOf<RecordName>() helper method
  - if another step with a data table has the same last word, the existing record type is reused, but importantly
  --the other step (or more than one) doesn't have to specify the complete list of columns for the record, so long
  --as all columns used across all steps are compatible with the same record type

    Scenario: Step with DataTable and no quoted parameters
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

      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users:
              | name  | role  |
              | Alice | Admin |
              | Bob   | User  |
              | John  | Client|
        """
      When the generator is run
      Then the following class should be generated:
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
               *   | name  | role   |
               *   | Alice | Admin  |
               *   | Bob   | User   |
               *   | John  | Client |
               */
              givenTheFollowingUsers(
                      List.of(
                              new UsersParam("Alice", "Admin"),
                              new UsersParam("Bob", "User"),
                              new UsersParam("John", "Client")
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

    Scenario: Step with DataTable and one quoted parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class PermissionsFeature {

      }
      """
      And the following feature file:
        """
        Feature: Permissions Management
          Scenario: Set permissions
            When user "Alice" has permissions:
              | permission | enabled |
              | read       | yes     |
              | write      | no      |
        """
      When the generator is run
      Then the following class should be generated:
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
         * Feature: Permissions Management
         */
        @DisplayName("PermissionsFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/PermissionsFeature.feature")
        public class PermissionsFeatureTest extends PermissionsFeature {
            public void whenUser$p1HasPermissions(String p1, List<PermissionsParam> permissions) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Set permissions")
            public void scenario_1() {
                /*
                 * When user "Alice" has permissions:
                 *   | permission | enabled |
                 *   | read       | yes     |
                 *   | write      | no      |
                 */
                whenUser$p1HasPermissions("Alice",
                        List.of(
                                new PermissionsParam("read", "yes"),
                                new PermissionsParam("write", "no")
                        ));
            }

            public static class PermissionsParam {
                private final String permission;

                private final String enabled;

                public PermissionsParam(String permission, String enabled) {
                    this.permission = permission;
                    this.enabled = enabled;
                }

                public String permission() {
                    return this.permission;
                }

                public String enabled() {
                    return this.enabled;
                }
            }
        }
        """

  Rule: different steps that use the same last word for their DataTable result in reusing the same generated record type

    Scenario: Multiple steps ending with same word share record type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class AccountsFeature {

      }
      """
      And the following feature file:
        """
        Feature: Account Management
          Scenario: Create accounts
            Given the following accounts:
              | name    | email           |
              | Alice   | alice@test.com  |
              | Bob     | bob@test.com    |
            When Update accounts:
              | name    | email           |
              | Alice   | alice@test.com  |
        """
      When the generator is run
      Then the following class should be generated:
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
         * Feature: Account Management
         */
        @DisplayName("AccountsFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/AccountsFeature.feature")
        public class AccountsFeatureTest extends AccountsFeature {
            public void givenTheFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUpdateAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create accounts")
            public void scenario_1() {
                /*
                 * Given the following accounts:
                 *   | name  | email          |
                 *   | Alice | alice@test.com |
                 *   | Bob   | bob@test.com   |
                 */
                givenTheFollowingAccounts(
                        List.of(
                                new AccountsParam("Alice", "alice@test.com"),
                                new AccountsParam("Bob", "bob@test.com")
                        ));
                /*
                 * When Update accounts:
                 *   | name  | email          |
                 *   | Alice | alice@test.com |
                 */
                whenUpdateAccounts(
                        List.of(
                                new AccountsParam("Alice", "alice@test.com")
                        ));
            }

            public static class AccountsParam {
                private final String name;

                private final String email;

                public AccountsParam(String name, String email) {
                    this.name = name;
                    this.email = email;
                }

                public String name() {
                    return this.name;
                }

                public String email() {
                    return this.email;
                }
            }
        }
        """

    Scenario: Multiple steps ending with same word share record type even if different set of columns are used
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class UsersFeature {

      }
      """
      And the following feature file:
        """
        Feature: Account Management
          Scenario: Create accounts
            Given the following accounts:
              | name    | email           |
              | Alice   | alice@test.com  |
              | Bob     | bob@test.com    |
            When Update accounts:
              | id  | name    | status  |
              | 10  | Alice   | active  |
        """
      When the generator is run
      Then the following class should be generated:
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
         * Feature: Account Management
         */
        @DisplayName("UsersFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/UsersFeature.feature")
        public class UsersFeatureTest extends UsersFeature {
            public void givenTheFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUpdateAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create accounts")
            public void scenario_1() {
                /*
                 * Given the following accounts:
                 *   | name  | email          |
                 *   | Alice | alice@test.com |
                 *   | Bob   | bob@test.com   |
                 */
                givenTheFollowingAccounts(
                        List.of(
                                new AccountsParam("Alice", "alice@test.com", "", ""),
                                new AccountsParam("Bob", "bob@test.com", "", "")
                        ));
                /*
                 * When Update accounts:
                 *   | id | name  | status |
                 *   | 10 | Alice | active |
                 */
                whenUpdateAccounts(
                        List.of(
                                new AccountsParam("Alice", "", "10", "active")
                        ));
            }

            public static class AccountsParam {
                private final String name;

                private final String email;

                private final String id;

                private final String status;

                public AccountsParam(String name, String email, String id, String status) {
                    this.name = name;
                    this.email = email;
                    this.id = id;
                    this.status = status;
                }

                public String name() {
                    return this.name;
                }

                public String email() {
                    return this.email;
                }

                public String id() {
                    return this.id;
                }

                public String status() {
                    return this.status;
                }
            }
        }
        """


