Feature: InnerParamTypeInheritanceAutoconversion
  As a
  I want
  So that

#  Rule: step data column values can be converted to match existing inner class fields as long as every value can be converted
#    - to the primitive type's wrapper type (e.g., int to Integer, long or Long, double or Double, boolean or Boolean)
#    - the conversion simply happens at the call site by directly passing the value as require type, e.g. for int or Integer type field instead of passing say "42" we pass 42 as an int, similarly for long, double and and boolean field types
#
#    Scenario: Existing inner class has fields with different primitive types
#      Given the following base class:
#      """
#      package features;
#
#      import dev.specbinder.annotations.Feature2JUnit;
#      import dev.specbinder.annotations.Feature2JUnitOptions;
#      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;
#
#      @Feature2JUnit
#      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
#      public abstract class UsersFeature {
#
#          public static class UsersParam {
#
#              private final String name;
#              private final int age;
#              private final long yearBorn;
#              private final double height;
#              private final boolean active;
#
#              public UsersParam(String name, int age, long yearBorn, double height, boolean active) {
#                  this.name = name;
#                  this.age = age;
#                  this.yearBorn = yearBorn;
#                  this.height = height;
#                  this.active = active;
#              }
#          }
#      }
#      """
#      And the following feature file:
#        """
#        Feature: Users Management
#          Scenario: Create users
#            Given the following users:
#              | name  | age | year born | height | active |
#              | Alice | 30  | 1993      | 5.7    | true   |
#              | Bob   | 25  | 1998      | 6.0    | false  |
#        """
#      When the generator is run
#      Then the following class should be generated:
#      """
#      package features;
#
#      import dev.specbinder.annotations.output.FeatureFilePath;
#      import java.lang.Math;
#      import java.lang.String;
#      import java.util.ArrayList;
#      import java.util.HashMap;
#      import java.util.List;
#      import java.util.Map;
#      import javax.annotation.processing.Generated;
#      import org.junit.jupiter.api.Assertions;
#      import org.junit.jupiter.api.DisplayName;
#      import org.junit.jupiter.api.MethodOrderer;
#      import org.junit.jupiter.api.Order;
#      import org.junit.jupiter.api.Test;
#      import org.junit.jupiter.api.TestMethodOrder;
#
#      /**
#       * Feature: Users Management
#       */
#      @DisplayName("UsersFeature")
#      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
#      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
#      @FeatureFilePath("features/UsersFeature.feature")
#      public class UsersFeatureTest extends UsersFeature {
#          public void givenTheFollowingUsers(List<UsersParam> users) {
#              Assertions.fail("Step is not yet implemented");
#          }
#
#          @Test
#          @Order(1)
#          @DisplayName("Scenario: Create users")
#          public void scenario_1() {
#              /*
#               * Given the following users:
#               */
#              givenTheFollowingUsers(createListOfMaps(\"\"\"
#                      | name  | age | year born | height | active |
#                      | Alice | 30  | 1993      | 5.7    | true   |
#                      | Bob   | 25  | 1998      | 6.0    | false  |
#                      \"\"\")
#                      .stream().map(row ->
#                              new UsersParam(
#                                      row.get("name"),
#                                      row.get("age"),
#                                      row.get("year born"),
#                                      row.get("height"),
#                                      row.get("active")
#                              )
#                      ).toList());
#          }
#
#          protected List<Map<String, String>> createListOfMaps(String tableLines) {
#
#              String[] tableRows = tableLines.split("\\n");
#              List<Map<String, String>> listOfMaps = new ArrayList<>();
#
#              if (tableRows.length < 2) {
#                  return listOfMaps;
#              }
#
#              String[] headers = null;
#              for (int i = 0; i < tableRows.length; i++) {
#                  String trimmedLine = tableRows[i].trim();
#                  if (!trimmedLine.isEmpty()) {
#                      String[] columns = trimmedLine.split("\\|");
#                      List<String> rowColumns = new ArrayList<>(columns.length);
#                      for (int j = 1; j < columns.length; j++) {
#                          String column = columns[j].trim();
#                          rowColumns.add(column);
#                      }
#
#                      if (headers == null) {
#                          headers = rowColumns.toArray(new String[0]);
#                      } else {
#                          Map<String, String> rowMap = new HashMap<>();
#                          for (int j = 0; j < Math.min(headers.length, rowColumns.size()); j++) {
#                              rowMap.put(headers[j], rowColumns.get(j));
#                          }
#                          listOfMaps.add(rowMap);
#                      }
#                  }
#              }
#
#              return listOfMaps;
#          }
#      }
#      """

