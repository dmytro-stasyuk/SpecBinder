Feature: MappingDataTableDefaultBehavior
  As a developer
  I want data tables to be mapped to List<Map<String, String>> by default
  So that I can work with data tables without needing to explicitly configure the option

  Rule: DataTable works with all step keywords - Given, When, Then, And, But, and *

    Scenario: DataTable in And step
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
        Feature: And Step
          Scenario: Test
            Given initial state
            And an And step has a DataTable:
              | col |
              | val |
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
         * Feature: And Step
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void initialState() {
                Assertions.fail("Step is not yet implemented");
            }

            public void anAndStepHasADatatable(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given initial state
                 */
                initialState();
                /*
                 * And an And step has a DataTable:
                 */
                anAndStepHasADatatable(createListOfMaps(\"\"\"
                        | col |
                        | val |
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

    Scenario: DataTable in But step
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
        Feature: But Step
          Scenario: Test
            Given initial state
            When action is performed
            Then result is verified
            But exceptions exist:
              | exception | reason     |
              | error1    | invalid    |
              | error2    | not found  |
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
         * Feature: But Step
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void initialState() {
                Assertions.fail("Step is not yet implemented");
            }

            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void resultIsVerified() {
                Assertions.fail("Step is not yet implemented");
            }

            public void exceptionsExist(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given initial state
                 */
                initialState();
                /*
                 * When action is performed
                 */
                actionIsPerformed();
                /*
                 * Then result is verified
                 */
                resultIsVerified();
                /*
                 * But exceptions exist:
                 */
                exceptionsExist(createListOfMaps(\"\"\"
                        | exception | reason    |
                        | error1    | invalid   |
                        | error2    | not found |
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

    Scenario: DataTable in * step
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
        Feature: Asterisk Step
          Scenario: Test
            Given initial context
            * a wildcard step has a DataTable:
              | item  | value |
              | key1  | val1  |
              | key2  | val2  |
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
         * Feature: Asterisk Step
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void initialContext() {
                Assertions.fail("Step is not yet implemented");
            }

            public void aWildcardStepHasADatatable(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given initial context
                 */
                initialContext();
                /*
                 * * a wildcard step has a DataTable:
                 */
                aWildcardStepHasADatatable(createListOfMaps(\"\"\"
                        | item | value |
                        | key1 | val1  |
                        | key2 | val2  |
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

  Rule: DataTable is formatted with pipe delimiters and aligned columns

    Scenario: DataTable with single column
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
        Feature: Permissions
          Scenario: List permissions
            Given available permissions:
              | permission |
              | read       |
              | write      |
              | delete     |
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
         * Feature: Permissions
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void availablePermissions(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: List permissions")
            public void scenario_1() {
                /*
                 * Given available permissions:
                 */
                availablePermissions(createListOfMaps(\"\"\"
                        | permission |
                        | read       |
                        | write      |
                        | delete     |
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

    Scenario: DataTable with misaligned columns
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
        Feature: Column Alignment
          Scenario: Test alignment
            Given data with varying widths:
              | short | very long column name | mid    |
              | x    | value                    | abc    |
              | y        | another value     | defghi |
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
         * Feature: Column Alignment
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void dataWithVaryingWidths(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test alignment")
            public void scenario_1() {
                /*
                 * Given data with varying widths:
                 */
                dataWithVaryingWidths(createListOfMaps(\"\"\"
                        | short | very long column name | mid    |
                        | x     | value                 | abc    |
                        | y     | another value         | defghi |
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

  Rule: DataTables with only headers (i.e. empty) are still passed as parameters.
  - these are converted to an empty list when using the default LIST_OF_MAPS parameter type

    Scenario: DataTable with headers only
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
        Feature: Header Only
          Scenario: Test
            Given a DataTable:
              | name | email |
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
         * Feature: Header Only
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void aDatatable(List<Map<String, String>> data) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a DataTable:
                 */
                aDatatable(createListOfMaps(\"\"\"
                        | name | email |
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