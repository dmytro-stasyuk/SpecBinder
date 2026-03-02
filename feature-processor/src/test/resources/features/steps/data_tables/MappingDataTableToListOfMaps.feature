Feature: MappingDataTableToListOfMaps
  As a developer using the Feature2JUnit generator
  I want the generator to optionally map data tables to List<Map<String, String>> parameters
  So that I can handle tabular data in my step definitions as a list of maps with header-based field access

  Rule: when "dataTableParameterType" option is set to "LIST_OF_MAPS", data tables are mapped to List<Map<String, String>> parameters
  - if a step has a DataTable, a parameter of type List<Map<String, String>> named "data" is added
  - the data is formatted with pipe delimiters and passed via createListOfMaps() helper method
  - columns properly aligned with spaces for readability
  - dataTables with only headers (i.e. empty) return an empty list when using LIST_OF_MAPS

    Scenario: Step with DataTable and no quoted parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {

      }
      """
      And the following feature file:
        """
        Feature: Users Management
          Scenario: Create users
            Given the following users exist:
              | name  | role  |
              | Alice | Admin |
              | Bob   | User  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

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
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void theFollowingUsersExist(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create users")
            public void scenario_1() {
                /*
                 * Given the following users exist:
                 */
                theFollowingUsersExist(createListOfMaps(\"\"\"
                        | name  | role  |
                        | Alice | Admin |
                        | Bob   | User  |
                        \"\"\"));
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
        }
        """

    Scenario: Step with DataTable and one quoted parameter
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/Users.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
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
            public void user$p1HasPermissions(String p1, List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Set permissions")
            public void scenario_1() {
                /*
                 * When user "Alice" has permissions:
                 */
                user$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                        | permission | enabled |
                        | read       | true    |
                        | write      | false   |
                        \"\"\"));
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
        }
        """

  Rule: a helper method is used conversion from string to list of maps creation

    Scenario: Multiple steps with DataTables share the same helper method
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;
        import io.cucumber.datatable.DataTable;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
        public abstract class TestFeature {

        }
        """
      And the following feature file:
      """
      Feature: Team Management
      Scenario: Add team members
          Given the following team members exist:
          | name   | role    |
          | Charlie| Manager |
          | Dana   | Developer |
          When the following team members are assigned tasks:
          | name   | task         |
          | Charlie| Project Lead |
          | Dana   | Coding       |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

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
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          public void theFollowingTeamMembersExist(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          public void theFollowingTeamMembersAreAssignedTasks(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Add team members")
          public void scenario_1() {
              /*
               * Given the following team members exist:
               */
              theFollowingTeamMembersExist(createListOfMaps(\"\"\"
                      | name    | role      |
                      | Charlie | Manager   |
                      | Dana    | Developer |
                      \"\"\"));
              /*
               * When the following team members are assigned tasks:
               */
              theFollowingTeamMembersAreAssignedTasks(createListOfMaps(\"\"\"
                      | name    | task         |
                      | Charlie | Project Lead |
                      | Dana    | Coding       |
                      \"\"\"));
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
      }
      """

  Rule: Helper methods are generated when not present in class hierarchy

    Scenario: No helper methods in base class
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {

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
      @DisplayName("Permissions")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Permissions.feature")
      public class PermissionsTest extends TestFeature {
          public void user$p1HasPermissions(String p1, List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Set permissions")
          public void scenario_1() {
              /*
               * When user "Alice" has permissions:
               */
              user$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                      | permission | enabled |
                      | read       | true    |
                      | write      | false   |
                      \"\"\"));
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
      }
      """

    Scenario: helper is present in base class
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {
          protected List<Map<String, String>> createListOfMaps(String tableLines) {
              // Custom implementation provided by user
              return new ArrayList<>();
          }
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
        @DisplayName("Permissions")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/Permissions.feature")
        public class PermissionsTest extends TestFeature {
            public void user$p1HasPermissions(String p1, List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Set permissions")
            public void scenario_1() {
                /*
                 * When user "Alice" has permissions:
                 */
                user$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                        | permission | enabled |
                        | read       | true    |
                        | write      | false   |
                        \"\"\"));
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
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
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
      @DisplayName("Permissions")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Permissions.feature")
      public class PermissionsTest extends TestFeature {
          public void user$p1HasPermissions(String p1, List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Set permissions")
          public void scenario_1() {
              /*
               * When user "Alice" has permissions:
               */
              user$p1HasPermissions("Alice", createListOfMaps(\"\"\"
                      | permission | enabled |
                      | read       | true    |
                      | write      | false   |
                      \"\"\"));
          }
      }
      """

