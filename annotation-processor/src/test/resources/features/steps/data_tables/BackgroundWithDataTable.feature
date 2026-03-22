Feature: BackgroundWithDataTable
  As a test developer
  I want the generator to convert Background steps with DataTables into @BeforeEach methods
  So that I can declare complex tabular test data in feature files that runs before each scenario

  Rule: Background steps with DataTables should generate methods accepting List<Map<String, String>> parameter when LIST_OF_MAPS option is set

    Scenario: Background with a DataTable step
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: product catalog
        Background:
          Given the following products exist:
            | name    | price |
            | Apple   | 1.50  |
            | Orange  | 2.00  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.TestInfo;

      /**
       * Feature: product catalog
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void theFollowingProductsExist(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given the following products exist:
               */
              theFollowingProductsExist(createListOfMaps(\"\"\"
                      | name   | price |
                      | Apple  | 1.50  |
                      | Orange | 2.00  |
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

    Scenario: Background with multiple steps including DataTable
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_MAPS)
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: user permissions
        Background:
          Given the system is initialized
          And the following users are created:
            | username | role  |
            | alice    | admin |
            | bob      | user  |
          And permissions are loaded
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.TestInfo;

      /**
       * Feature: user permissions
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void theSystemIsInitialized() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theFollowingUsersAreCreated(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          public void permissionsAreLoaded() {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given the system is initialized
               */
              theSystemIsInitialized();
              /*
               * And the following users are created:
               */
              theFollowingUsersAreCreated(createListOfMaps(\"\"\"
                      | username | role  |
                      | alice    | admin |
                      | bob      | user  |
                      \"\"\"));
              /*
               * And permissions are loaded
               */
              permissionsAreLoaded();
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
