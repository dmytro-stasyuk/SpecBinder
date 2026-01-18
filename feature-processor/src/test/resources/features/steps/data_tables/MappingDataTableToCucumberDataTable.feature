Feature: MappingDataTableToCucumberDataTable
  As a developer
  I want to explicitly configure Gherkin data tables to be mapped to DataTable parameters
  So that when I set the option to CUCUMBER_DATA_TABLE, I can work with io.cucumber.datatable.DataTable objects

  Rule: When the option is explicitly set to CUCUMBER_DATA_TABLE, DataTable parameters are added as the last parameter
  - if a step has a DataTable, a parameter of type io.cucumber.datatable.DataTable named "dataTable" is added
  - the DataTable is formatted with pipe delimiters and passed via createDataTable() helper method
  - columns properly aligned with spaces for readability
  - this requires explicit configuration via @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)

    Scenario: Step with DataTable and no quoted parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/users.feature")
      @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
      public abstract class TestFeature {

          protected DataTable.TableConverter getTableConverter() {
              return null;
          }
      }
      """
      And a feature file under path "features/users.feature" with the following content:
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
        package features;

        import com.example.TestFeature;
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
         * Feature: Users Management
         */
        @DisplayName("users")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/users.feature")
        public class UsersTest extends TestFeature {
            public void givenTheFollowingUsersExist(DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create users")
            public void scenario_1() {
                /*
                 * Given the following users exist:
                 */
                givenTheFollowingUsersExist(createDataTable(\"\"\"
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

    Scenario: Step with DataTable and one quoted parameter
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
      public abstract class TestFeature {

          protected DataTable.TableConverter getTableConverter() {
              return null;
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
       * Feature: Permissions Management
       */
      @DisplayName("Permissions")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Permissions.feature")
      public class PermissionsTest extends TestFeature {
          public void whenUser$p1HasPermissions(String p1, DataTable dataTable) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Set permissions")
          public void scenario_1() {
              /*
               * When user "Alice" has permissions:
               */
              whenUser$p1HasPermissions("Alice", createDataTable(\"\"\"
                      | permission | enabled |
                      | read       | true    |
                      | write      | false   |
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

    Scenario: Step with DataTable and multiple quoted parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/Products.feature")
      @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
      public abstract class TestFeature {

          protected DataTable.TableConverter getTableConverter() {
              return null;
          }
      }
      """
      And a feature file under path "features/Products.feature" with the following content:
      """
      Feature: Order Management
        Scenario: View order details
          Then order "12345" for customer "Bob" contains:
            | product | quantity |
            | Laptop  | 1        |
            | Mouse   | 2        |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.TestFeature;
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
       * Feature: Order Management
       */
      @DisplayName("Products")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Products.feature")
      public class ProductsTest extends TestFeature {
          public void thenOrder$p1ForCustomer$p2Contains(String p1, String p2, DataTable dataTable) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: View order details")
          public void scenario_1() {
              /*
               * Then order "12345" for customer "Bob" contains:
               */
              thenOrder$p1ForCustomer$p2Contains("12345", "Bob", createDataTable(\"\"\"
                      | product | quantity |
                      | Laptop  | 1        |
                      | Mouse   | 2        |
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

  Rule: helper method is used for list of maps creation

    Scenario: Multiple steps with DataTables share the same helper method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Shared Helper
          Scenario: Multiple tables
            Given scenario has step 1 with a DataTable:
              | col1 | col2 |
              | a    | b    |
            And scenario has step 2 with a DataTable:
              | col3 | col4 |
              | c    | d    |
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
         * Feature: Shared Helper
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenScenarioHasStep1WithADatatable(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenScenarioHasStep2WithADatatable(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Multiple tables")
            public void scenario_1() {
                /*
                 * Given scenario has step 1 with a DataTable:
                 */
                givenScenarioHasStep1WithADatatable(createListOfMaps(\"\"\"
                        | col1 | col2 |
                        | a    | b    |
                        \"\"\"));
                /*
                 * And scenario has step 2 with a DataTable:
                 */
                givenScenarioHasStep2WithADatatable(createListOfMaps(\"\"\"
                        | col3 | col4 |
                        | c    | d    |
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
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
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
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenTheFollowingUsersExist(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create users")
            public void scenario_1() {
                /*
                 * Given the following users exist:
                 */
                givenTheFollowingUsersExist(createListOfMaps(\"\"\"
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

  Rule: Helper methods are not duplicated when explicitly configured with CUCUMBER_DATA_TABLE option

    Scenario: Both helper methods already in base class
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
      import io.cucumber.datatable.DataTable;

      @Feature2JUnit("features/Permissions.feature")
      @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
      public abstract class TestFeature {
          public DataTable.TableConverter getTableConverter() {
              return null;
          }

          public DataTable createDataTable(String tableLines) {
              return null;
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
        import io.cucumber.datatable.DataTable;
        import java.lang.String;
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
            public void whenUser$p1HasPermissions(String p1, DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Set permissions")
            public void scenario_1() {
                /*
                 * When user "Alice" has permissions:
                 */
                whenUser$p1HasPermissions("Alice", createDataTable(\"\"\"
                        | permission | enabled |
                        | read       | true    |
                        | write      | false   |
                        \"\"\"));
            }
        }
        """

    Scenario: Only getTableConverter in base class
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
        import io.cucumber.datatable.DataTable;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
        public abstract class TestFeature {
            protected DataTable.TableConverter getTableConverter() {
                return null;
            }
        }
        """
      And the following feature file:
        """
        Feature: Order Management
          Scenario: View order details
            Then order "12345" contains:
              | product | quantity |
              | Laptop  | 1        |
              | Mouse   | 2        |
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
         * Feature: Order Management
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void thenOrder$p1Contains(String p1, DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: View order details")
            public void scenario_1() {
                /*
                 * Then order "12345" contains:
                 */
                thenOrder$p1Contains("12345", createDataTable(\"\"\"
                        | product | quantity |
                        | Laptop  | 1        |
                        | Mouse   | 2        |
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

  Rule: Helper methods are not duplicated when present in ancestor classes with CUCUMBER_DATA_TABLE option

    Scenario: Both helper methods in ancestor class
      Given the following base class:
        """
        package com.example;

        import io.cucumber.datatable.DataTable;

        public abstract class BaseTestSupport {
            protected DataTable.TableConverter getTableConverter() {
                return null;
            }

            protected DataTable createDataTable(String tableLines) {
                return null;
            }
        }
        """
      And the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;

        @Feature2JUnit("features/Inventory.feature")
        @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
        public abstract class TestFeature extends BaseTestSupport {
        }
        """
      And a feature file under path "features/Inventory.feature" with the following content:
        """
        Feature: Inventory Management
          Scenario: Track inventory
            Given inventory items:
              | item    | quantity |
              | Widget  | 100      |
              | Gadget  | 50       |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import com.example.TestFeature;
        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.datatable.DataTable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Inventory Management
         */
        @DisplayName("Inventory")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/Inventory.feature")
        public class InventoryTest extends TestFeature {
            public void givenInventoryItems(DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Track inventory")
            public void scenario_1() {
                /*
                 * Given inventory items:
                 */
                givenInventoryItems(createDataTable(\"\"\"
                        | item   | quantity |
                        | Widget | 100      |
                        | Gadget | 50       |
                        \"\"\"));
            }
        }
        """

    Scenario: getTableConverter in base, createDataTable in ancestor
      Given the following base class:
        """
        package com.example;

        import io.cucumber.datatable.DataTable;

        public abstract class DataTableSupport {
            protected DataTable createDataTable(String tableLines) {
                return null;
            }
        }
        """
      And the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
        import io.cucumber.datatable.DataTable;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
        public abstract class TestFeature extends DataTableSupport {
            protected DataTable.TableConverter getTableConverter() {
                return null;
            }
        }
        """
      And the following feature file:
        """
        Feature: Customer Orders
          Scenario: Create order
            When customer orders:
              | product | quantity |
              | Book    | 3        |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.datatable.DataTable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Customer Orders
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void whenCustomerOrders(DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create order")
            public void scenario_1() {
                /*
                 * When customer orders:
                 */
                whenCustomerOrders(createDataTable(\"\"\"
                        | product | quantity |
                        | Book    | 3        |
                        \"\"\"));
            }
        }
        """

    Scenario: createDataTable in base, getTableConverter in ancestor
      Given the following base class:
        """
        package com.example;

        import io.cucumber.datatable.DataTable;

        public abstract class TableConverterSupport {
            protected DataTable.TableConverter getTableConverter() {
                return null;
            }
        }
        """
      And the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.CUCUMBER_DATA_TABLE;
        import io.cucumber.datatable.DataTable;

        @Feature2JUnit
        @Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)
        public abstract class TestFeature extends TableConverterSupport {
            protected DataTable createDataTable(String tableLines) {
                return null;
            }
        }
        """
      And the following feature file:
        """
        Feature: Employee Directory
          Scenario: Add employees
            Given employees in system:
              | name  | department |
              | Alice | Engineering |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.datatable.DataTable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Employee Directory
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void givenEmployeesInSystem(DataTable dataTable) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Add employees")
            public void scenario_1() {
                /*
                 * Given employees in system:
                 */
                givenEmployeesInSystem(createDataTable(\"\"\"
                        | name  | department  |
                        | Alice | Engineering |
                        \"\"\"));
            }
        }
        """
