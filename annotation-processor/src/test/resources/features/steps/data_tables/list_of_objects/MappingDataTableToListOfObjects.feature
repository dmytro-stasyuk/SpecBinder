Feature: MappingDataTableToListOfObjects
  As a developer writing BDD step definitions with tabular test data
  I want data tables automatically mapped to type-safe object classes with named fields matching column headers
  So that I get compile-time safety, IDE autocomplete, and refactoring support

  Rule: when "dataTableParameterType" option is set to "LIST_OF_OBJECT_PARAMS", data tables are mapped to List<ObjectParam> step method parameter
  - a generated object type is created with fields matching column headers

    Scenario: Step with DataTable and no quoted parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import java.util.Map;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
               *   | name  | role   |
               *   | Alice | Admin  |
               *   | Bob   | User   |
               *   | John  | Client |
               */
              theFollowingUsers(
                      List.of(
                              new UsersParam(
                                      "Alice",
                                      "Admin"
                              ),
                              new UsersParam(
                                      "Bob",
                                      "User"
                              ),
                              new UsersParam(
                                      "John",
                                      "Client"
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

    Scenario: Step with DataTable and one quoted parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/PermissionsFeature.feature")
        public class PermissionsFeatureTest extends PermissionsFeature {
            public void user$p1HasPermissions(String p1, List<PermissionsParam> permissions) {
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
                user$p1HasPermissions("Alice",
                        List.of(
                                new PermissionsParam(
                                        "read",
                                        "yes"
                                ),
                                new PermissionsParam(
                                        "write",
                                        "no"
                                )
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

  Rule: the object type name is derived from the last word of the step's text (capitalised and converted to camel case if necessary) with "Param" suffix added

    Scenario: object type name from simple last word
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class SimpleWordFeature {

      }
      """
      And the following feature file:
        """
        Feature: Simple Word Test
          Scenario: Test naming
            Given the following users:
              | name  | age     |
              | Alice | thirty  |
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Simple Word Test
         */
        @DisplayName("SimpleWordFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/SimpleWordFeature.feature")
        public class SimpleWordFeatureTest extends SimpleWordFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test naming")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | age    |
                 *   | Alice | thirty |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        "thirty"
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final String age;

                public UsersParam(String name, String age) {
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

    Scenario: object type name from hyphenated last word converts to camel case
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class HyphenatedWordFeature {

      }
      """
      And the following feature file:
        """
        Feature: Hyphenated Word Test
          Scenario: Test naming
            Given the following user-settings:
              | theme | language |
              | dark  | en       |
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Hyphenated Word Test
         */
        @DisplayName("HyphenatedWordFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/HyphenatedWordFeature.feature")
        public class HyphenatedWordFeatureTest extends HyphenatedWordFeature {
            public void theFollowingUserSettings(List<UserSettingsParam> userSettings) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test naming")
            public void scenario_1() {
                /*
                 * Given the following user-settings:
                 *   | theme | language |
                 *   | dark  | en       |
                 */
                theFollowingUserSettings(
                        List.of(
                                new UserSettingsParam(
                                        "dark",
                                        "en"
                                )
                        ));
            }

            public static class UserSettingsParam {
                private final String theme;

                private final String language;

                public UserSettingsParam(String theme, String language) {
                    this.theme = theme;
                    this.language = language;
                }

                public String theme() {
                    return this.theme;
                }

                public String language() {
                    return this.language;
                }
            }
        }
        """

    Scenario: object type name from lowercase last word is capitalized
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LowercaseWordFeature {

      }
      """
      And the following feature file:
        """
        Feature: Lowercase Word Test
          Scenario: Test naming
            Given the following products:
              | name   | price |
              | Widget | high  |
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Lowercase Word Test
         */
        @DisplayName("LowercaseWordFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LowercaseWordFeature.feature")
        public class LowercaseWordFeatureTest extends LowercaseWordFeature {
            public void theFollowingProducts(List<ProductsParam> products) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test naming")
            public void scenario_1() {
                /*
                 * Given the following products:
                 *   | name   | price |
                 *   | Widget | high  |
                 */
                theFollowingProducts(
                        List.of(
                                new ProductsParam(
                                        "Widget",
                                        "high"
                                )
                        ));
            }

            public static class ProductsParam {
                private final String name;

                private final String price;

                public ProductsParam(String name, String price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public String price() {
                    return this.price;
                }
            }
        }
        """

    Scenario: object type name from all caps last word is converted to proper case
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class AllCapsWordFeature {

      }
      """
      And the following feature file:
        """
        Feature: All Caps Word Test
          Scenario: Test naming
            Given the following API:
              | endpoint | method |
              | /users   | GET    |
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
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: All Caps Word Test
         */
        @DisplayName("AllCapsWordFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/AllCapsWordFeature.feature")
        public class AllCapsWordFeatureTest extends AllCapsWordFeature {
            public void theFollowingApi(List<ApiParam> api) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test naming")
            public void scenario_1() {
                /*
                 * Given the following API:
                 *   | endpoint | method |
                 *   | /users   | GET    |
                 */
                theFollowingApi(
                        List.of(
                                new ApiParam(
                                        "/users",
                                        "GET"
                                )
                        ));
            }

            public static class ApiParam {
                private final String endpoint;

                private final String method;

                public ApiParam(String endpoint, String method) {
                    this.endpoint = endpoint;
                    this.method = method;
                }

                public String endpoint() {
                    return this.endpoint;
                }

                public String method() {
                    return this.method;
                }
            }
        }
        """

  Rule: different steps that use the same last word for their DataTable result in reusing the same generated record type

    Scenario: Multiple steps ending with same word share record type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/AccountsFeature.feature")
        public class AccountsFeatureTest extends AccountsFeature {
            public void theFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            public void updateAccounts(List<AccountsParam> accounts) {
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
                theFollowingAccounts(
                        List.of(
                                new AccountsParam(
                                        "Alice",
                                        "alice@test.com"
                                ),
                                new AccountsParam(
                                        "Bob",
                                        "bob@test.com"
                                )
                        ));
                /*
                 * When Update accounts:
                 *   | name  | email          |
                 *   | Alice | alice@test.com |
                 */
                updateAccounts(
                        List.of(
                                new AccountsParam(
                                        "Alice",
                                        "alice@test.com"
                                )
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

  Rule: the other step (or more than one) doesn't have to specify the complete list of columns for the custom object type
  so long as all columns used across all steps are compatible with the same object type

    Scenario: Multiple steps ending with same word share record type even if different set of columns are used
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
         * Feature: Account Management
         */
        @DisplayName("UsersFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/UsersFeature.feature")
        public class UsersFeatureTest extends UsersFeature {
            public void theFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            public void updateAccounts(List<AccountsParam> accounts) {
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
                theFollowingAccounts(
                        List.of(
                                new AccountsParam(
                                        "Alice",
                                        "alice@test.com",
                                        null,
                                        null
                                ),
                                new AccountsParam(
                                        "Bob",
                                        "bob@test.com",
                                        null,
                                        null
                                )
                        ));
                /*
                 * When Update accounts:
                 *   | id | name  | status |
                 *   | 10 | Alice | active |
                 */
                updateAccounts(
                        List.of(
                                new AccountsParam(
                                        "Alice",
                                        null,
                                        10,
                                        "active"
                                )
                        ));
            }

            public static class AccountsParam {
                private final String name;

                private final String email;

                private final Integer id;

                private final String status;

                public AccountsParam(String name, String email, Integer id, String status) {
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

                public Integer id() {
                    return this.id;
                }

                public String status() {
                    return this.status;
                }
            }
        }
        """

