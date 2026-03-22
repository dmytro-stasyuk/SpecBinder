Feature: DataTableInScenarioOutlines
  As a BDD test developer writing parameterized tests
  I want data tables within scenario outlines to dynamically reference example table values using <parameter> syntax
  So that I can write flexible, data-driven test scenarios where table content adapts to each example row without duplicating step definitions

  Rule: data tables may contain references to the values from the examples table via the <param> syntax
  - angle bracket parameters <param> in data tables are replaced with actual values which are passed to the scenario method as parameters
  - the replacement happens at the method call site with .replaceAll calls for each parameter that is present in the data table

    Scenario: DataTable with single parameter reference from Examples
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {

      }
      """
      And the following feature file:
        """
        Feature: Product Inventory
          Scenario Outline: Check product availability
            When checking inventory for product:
              | name           | status         |
              | <Product Name> | <Stock Status> |
            Examples:
              | Product Name   | Stock Status |
              | Laptop         | Available    |
              | Mouse          | Out of Stock |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Product Inventory
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void checkingInventoryForProduct(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            Product Name | Stock Status
                            Laptop       | Available
                            Mouse        | Out of Stock
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Check product availability")
            public void scenario_1(String productName, String stockStatus) {
                /*
                 * When checking inventory for product:
                 */
                checkingInventoryForProduct(createListOfMaps(\"\"\"
                        | name           | status         |
                        | <Product Name> | <Stock Status> |
                        \"\"\"
                        .replaceAll("<Product Name>", productName)
                        .replaceAll("<Stock Status>", stockStatus)));
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

    Scenario: DataTable with mixed static values and parameter references
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
        Feature: Order Processing
          Scenario Outline: Process order with items
            Then order "<orderId>" contains items:
              | product   | quantity | status    |
              | <product> | <qty>    | pending   |
              | Keyboard  | 1        | <status>  |
            Examples:
              | orderId | product | qty | status    |
              | ORD-001 | Monitor | 2   | confirmed |
              | ORD-002 | Mouse   | 5   | shipped   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Integer;
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Order Processing
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          public void order$p1ContainsItems(String p1, List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          orderId | product | qty | status
                          ORD-001 | Monitor | 2   | confirmed
                          ORD-002 | Mouse   | 5   | shipped
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Process order with items")
          public void scenario_1(String orderId, String product, Integer qty, String status) {
              /*
               * Then order "<orderId>" contains items:
               */
              order$p1ContainsItems(orderId, createListOfMaps(\"\"\"
                      | product   | quantity | status   |
                      | <product> | <qty>    | pending  |
                      | Keyboard  | 1        | <status> |
                      \"\"\"
                      .replaceAll("<product>", product)
                      .replaceAll("<qty>", qty.toString())
                      .replaceAll("<status>", status)));
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

  Rule: when a Scenario Outline has some steps that make use of values from examples table while
  a step with a data table parameter doesn't use any example value, then the replacement at call site for the step
  with data table is not necessary and should not be added in generated class, i.e. no need to call replaceAll
  for examples table column values where data table doesn't contain any references to them

    Scenario: DataTable with no parameter references while other step uses example values
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Static Configuration
          Scenario Outline: Configure system and process
            Given system configuration:
              | setting    | value       |
              | timeout    | 30          |
              | retries    | 3           |
            When user "<username>" performs action "<action>"

          Examples:
            | username | action |
            | Alice    | login  |
            | Bob      | logout |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Static Configuration
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void systemConfiguration(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            public void user$p1PerformsAction$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | action
                            Alice    | login
                            Bob      | logout
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Configure system and process")
            public void scenario_1(String username, String action) {
                /*
                 * Given system configuration:
                 */
                systemConfiguration(createListOfMaps(\"\"\"
                        | setting | value |
                        | timeout | 30    |
                        | retries | 3     |
                        \"\"\"));
                /*
                 * When user "<username>" performs action "<action>"
                 */
                user$p1PerformsAction$p2(username, action);
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

    Scenario: DataTable references only some of the example parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class TestFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Partial Parameter Usage
          Scenario Outline: Create notification
            Given notification settings:
              | recipient  | template     |
              | <username> | welcome-user |
            When action "<action>" is triggered with priority "<priority>"

          Examples:
            | username | action | priority |
            | Alice    | signup | high     |
            | Bob      | login  | low      |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Partial Parameter Usage
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void notificationSettings(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            public void action$p1IsTriggeredWithPriority$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | action | priority
                            Alice    | signup | high
                            Bob      | login  | low
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Create notification")
            public void scenario_1(String username, String action, String priority) {
                /*
                 * Given notification settings:
                 */
                notificationSettings(createListOfMaps(\"\"\"
                        | recipient  | template     |
                        | <username> | welcome-user |
                        \"\"\"
                        .replaceAll("<username>", username)));
                /*
                 * When action "<action>" is triggered with priority "<priority>"
                 */
                action$p1IsTriggeredWithPriority$p2(action, priority);
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
