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
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
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
               */
              givenTheFollowingUsers(createListOfMaps(\"\"\"
                      | name  | role  |
                      | Alice | Admin |
                      | Bob   | User  |
                      \"\"\")
                      .stream().map(row ->
                              new UsersParam(
                                      row.get("name"),
                                      row.get("role")
                              )
                      ).toList());
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
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit("features/Users.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature {

      }
      """
      And a feature file under path "features/Users.feature" with the following content:
        """
        Feature: Permissions Management
          Scenario: Set permissions
            When user "Alice" has permissions:
              | permission | enabled |
              | read       | true    |
              | write      | false   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import com.example.TestFeature;
        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Math;
        import java.lang.String;
        import java.util.ArrayList;
        import java.util.HashMap;
        import java.util.List;
        import java.util.Map;
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
        @DisplayName("Users")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/Users.feature")
        public class UsersTest extends TestFeature {
            public void whenUser$p1HasPermissions(String p1, List<PermissionsParam> permissions) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Set permissions")
            public void scenario_1() {
                /*
                 * When user "Alice" has permissions:
                 */
                whenUser$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                        | permission | enabled |
                        | read       | true    |
                        | write      | false   |
                        \"\"\")
                        .stream().map(row ->
                                new PermissionsParam(
                                        row.get("permission"),
                                        row.get("enabled")
                                )
                        ).toList());
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
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit("features/Users.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature {

      }
      """
      And a feature file under path "features/Users.feature" with the following content:
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

        import com.example.TestFeature;
        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Math;
        import java.lang.String;
        import java.util.ArrayList;
        import java.util.HashMap;
        import java.util.List;
        import java.util.Map;
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
        @DisplayName("Users")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/Users.feature")
        public class UsersTest extends TestFeature {
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
                 */
                givenTheFollowingAccounts(createListOfMaps(\"\"\"
                        | name  | email          |
                        | Alice | alice@test.com |
                        | Bob   | bob@test.com   |
                        \"\"\")
                        .stream().map(row ->
                                new AccountsParam(
                                        row.get("name"),
                                        row.get("email")
                                )
                        ).toList());
                /*
                 * When Update accounts:
                 */
                whenUpdateAccounts(createListOfMaps(\"\"\"
                        | name  | email          |
                        | Alice | alice@test.com |
                        \"\"\")
                        .stream().map(row ->
                                new AccountsParam(
                                        row.get("name"),
                                        row.get("email")
                                )
                        ).toList());
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
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit("features/Users.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature {

      }
      """
      And a feature file under path "features/Users.feature" with the following content:
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

        import com.example.TestFeature;
        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Math;
        import java.lang.String;
        import java.util.ArrayList;
        import java.util.HashMap;
        import java.util.List;
        import java.util.Map;
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
        @DisplayName("Users")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/Users.feature")
        public class UsersTest extends TestFeature {
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
                 */
                givenTheFollowingAccounts(createListOfMaps(\"\"\"
                        | name  | email          |
                        | Alice | alice@test.com |
                        | Bob   | bob@test.com   |
                        \"\"\")
                        .stream().map(row ->
                                new AccountsParam(
                                        row.get("name"),
                                        row.get("email"),
                                        row.get("id"),
                                        row.get("status")
                                )
                        ).toList());
                /*
                 * When Update accounts:
                 */
                whenUpdateAccounts(createListOfMaps(\"\"\"
                        | id | name  | status |
                        | 10 | Alice | active |
                        \"\"\")
                        .stream().map(row ->
                                new AccountsParam(
                                        row.get("name"),
                                        row.get("email"),
                                        row.get("id"),
                                        row.get("status")
                                )
                        ).toList());
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

  Rule: a helper method "createListOfMaps" is used for conversion from string to list of maps and is created only once per generated class

    Scenario: multiple steps with DataTables share the same helper method
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit("features/Users.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature {

      }
      """
      And a feature file under path "features/Users.feature" with the following content:
        """
        Feature: Team Management
          Scenario: Add team members
            Given the following team members:
              | name   | role    |
              | Charlie| Manager |
              | Dana   | Developer|
            When assigning tasks:
              | task        | assignee |
              | Design Doc  | Charlie  |
              | Code Review | Dana     |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.TestFeature;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Team Management
       */
      @DisplayName("Users")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Users.feature")
      public class UsersTest extends TestFeature {
          public void givenTheFollowingTeamMembers(List<MembersParam> members) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenAssigningTasks(List<TasksParam> tasks) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Add team members")
          public void scenario_1() {
              /*
               * Given the following team members:
               */
              givenTheFollowingTeamMembers(createListOfMaps(\"\"\"
                      | name    | role      |
                      | Charlie | Manager   |
                      | Dana    | Developer |
                      \"\"\")
                      .stream().map(row ->
                              new MembersParam(
                                      row.get("name"),
                                      row.get("role")
                              )
                      ).toList());
              /*
               * When assigning tasks:
               */
              whenAssigningTasks(createListOfMaps(\"\"\"
                      | task        | assignee |
                      | Design Doc  | Charlie  |
                      | Code Review | Dana     |
                      \"\"\")
                      .stream().map(row ->
                              new TasksParam(
                                      row.get("task"),
                                      row.get("assignee")
                              )
                      ).toList());
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

          public static class MembersParam {
              private final String name;

              private final String role;

              public MembersParam(String name, String role) {
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

          public static class TasksParam {
              private final String task;

              private final String assignee;

              public TasksParam(String task, String assignee) {
                  this.task = task;
                  this.assignee = assignee;
              }

              public String task() {
                  return this.task;
              }

              public String assignee() {
                  return this.assignee;
              }
          }
      }
      """

  Rule: helper method "createListOfMaps" is generated when not present in class hierarchy

    Scenario: helper is present in base class
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;


      @Feature2JUnit("features/Projects.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature {
          protected List<Map<String, String>> createListOfMaps(String tableLines) {
              // Custom implementation provided by user
              return new ArrayList<>();
          }
      }
      """
      And a feature file under path "features/Projects.feature" with the following content:
      """
      Feature: Project Management
      Scenario: Create projects
          Given the following projects:
          | title       | owner   |
          | Project A   | Alice   |
          | Project B   | Bob     |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.TestFeature;
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
       * Feature: Project Management
       */
      @DisplayName("Projects")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Projects.feature")
      public class ProjectsTest extends TestFeature {
          public void givenTheFollowingProjects(List<ProjectsParam> projects) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Create projects")
          public void scenario_1() {
              /*
               * Given the following projects:
               */
              givenTheFollowingProjects(createListOfMaps(\"\"\"
                      | title     | owner |
                      | Project A | Alice |
                      | Project B | Bob   |
                      \"\"\")
                      .stream().map(row ->
                              new ProjectsParam(
                                      row.get("title"),
                                      row.get("owner")
                              )
                      ).toList());
          }

          public static class ProjectsParam {
              private final String title;

              private final String owner;

              public ProjectsParam(String title, String owner) {
                  this.title = title;
                  this.owner = owner;
              }

              public String title() {
                  return this.title;
              }

              public String owner() {
                  return this.owner;
              }
          }
      }
      """

    Scenario: helper is present in ancestor class
      Given the following base class:
      """
      package com.example;

      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;

      public abstract class BaseFeature {
          protected List<Map<String, String>> createListOfMaps(String tableLines) {
              // Custom implementation provided by user
              return new ArrayList<>();
          }
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class TestFeature extends BaseFeature {
      }
      """
      And a feature file under path "features/Permissions.feature" with the following content:
      """
      Feature: Permissions Management
        Scenario: Set permissions
          When user "Alice" has permissions:
            | permission | enabled |
            | read       | true    |
            | write      | false   |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.TestFeature;
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
      @DisplayName("Permissions")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Permissions.feature")
      public class PermissionsTest extends TestFeature {
          public void whenUser$p1HasPermissions(String p1, List<PermissionsParam> permissions) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Set permissions")
          public void scenario_1() {
              /*
               * When user "Alice" has permissions:
               */
              whenUser$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                      | permission | enabled |
                      | read       | true    |
                      | write      | false   |
                      \"\"\")
                      .stream().map(row ->
                              new PermissionsParam(
                                      row.get("permission"),
                                      row.get("enabled")
                              )
                      ).toList());
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

