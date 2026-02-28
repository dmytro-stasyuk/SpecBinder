Feature: DataTableParameterType
  As a developer controlling how Gherkin data tables are represented in generated step method parameters
  I want to choose between List<Map<String, String>>, Cucumber DataTable, or generated type-safe object parameters
  So that I can select the data table representation that best fits my testing style and provides the right level of type safety

  Rule: the default data table parameter type is LIST_OF_MAPS when no dataTableParameterType option is specified
  - data tables are mapped to List<Map<String, String>> parameters named "data"
  - a createListOfMaps() helper method is generated to convert the text block table data

    Scenario: data tables default to List<Map<String, String>> when no option is specified
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
        public abstract class UserManagement {

        }
        """
      And the following feature file:
        """
        Feature: User Management
          Scenario: Create users
            Given the following users:
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
         * Feature: User Management
         */
        @DisplayName("UserManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserManagement.feature")
        public class UserManagementTest extends UserManagement {
            public void givenTheFollowingUsers(List<Map<String, String>> data) {
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

  Rule: when dataTableParameterType is set to CUCUMBER_DATA_TABLE, data tables are mapped to io.cucumber.datatable.DataTable parameters
  - the step method parameter is of type DataTable named "dataTable"
  - a createDataTable() helper method is generated to convert the text block table data

    Scenario: data tables are mapped to DataTable when CUCUMBER_DATA_TABLE option is set
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
        import io.cucumber.datatable.DataTable;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
        public abstract class UserManagement {

            protected DataTable.TableConverter getTableConverter() {
                // todo - provide real implementation for returning a DataTable.TableConverter that can convert text block tables into DataTable instances
                return null;
            }

        }
        """
      And the following feature file:
        """
        Feature: User Management
          Scenario: Create users
            Given the following users:
              | name  | role  |
              | Alice | Admin |
              | Bob   | User  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.datatable.DataTable;
        import java.lang.String;
        import java.util.ArrayList;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: User Management
         */
        @DisplayName("UserManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserManagement.feature")
        public class UserManagementTest extends UserManagement {
            public void givenTheFollowingUsers(DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create users")
            public void scenario_1() {
                /*
                 * Given the following users:
                 */
                givenTheFollowingUsers(createDataTable(\"\"\"
                        | name  | role  |
                        | Alice | Admin |
                        | Bob   | User  |
                        \"\"\"));
            }

            protected DataTable createDataTable(String tableLines) {

                String[] tableRows = tableLines.split("\\n");
                List<List<String>> rawDataTable = new ArrayList<>(tableRows.length);

                for (String tableRow : tableRows) {
                    String trimmedLine = tableRow.trim();
                    if (!trimmedLine.isEmpty()) {
                        String[] columns = trimmedLine.split("\\|");
                        List<String> rowColumns = new ArrayList<>(columns.length);
                        for (int i = 1; i < columns.length; i++) {
                            String column = columns[i].trim();
                            rowColumns.add(column);
                        }
                        rawDataTable.add(rowColumns);
                    }
                }

                DataTable dataTable = DataTable.create(rawDataTable, getTableConverter());
                return dataTable;
            }
        }
        """

  Rule: when dataTableParameterType is set to LIST_OF_OBJECT_PARAMS, data tables are mapped to generated type-safe object parameters
  - a static inner class is generated with fields matching the data table column headers
  - the step method parameter is of type List<XxxParam> where Xxx is derived from the last word of the step text
  - data is passed inline using List.of() with constructor calls

    Scenario: data tables are mapped to generated object types when LIST_OF_OBJECT_PARAMS option is set
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
        public abstract class UserManagement {

        }
        """
      And the following feature file:
        """
        Feature: User Management
          Scenario: Create users
            Given the following users:
              | name  | role  |
              | Alice | Admin |
              | Bob   | User  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

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
         * Feature: User Management
         */
        @DisplayName("UserManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserManagement.feature")
        public class UserManagementTest extends UserManagement {
            public void givenTheFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create users")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | role  |
                 *   | Alice | Admin |
                 *   | Bob   | User  |
                 */
                givenTheFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        "Admin"
                                ),
                                new UsersParam(
                                        "Bob",
                                        "User"
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
