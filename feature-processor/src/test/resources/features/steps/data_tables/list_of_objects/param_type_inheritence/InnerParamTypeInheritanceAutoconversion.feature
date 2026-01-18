Feature: InnerParamTypeInheritanceAutoconversion
  As a
  I want
  So that

  Rule: step data column values can be converted to match existing fields of parameterized list type as long as every value can be converted
  - to the primitive type's wrapper type (e.g., int to Integer, long or Long, double or Double, boolean or Boolean)
  - the conversion simply happens at the call site by directly passing the value as require type, e.g. for int or Integer type field instead of passing string equivalent "42" we pass 42 as an int,
  - similarly for long, double and and boolean field types

#    Scenario: Existing inner class has fields with different primitive types
#      Given the following base class:
#      """
#      package features;
#
#      import dev.specbinder.annotations.Feature2JUnit;
#      import dev.specbinder.annotations.Feature2JUnitOptions;
#      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;
#
#      import java.util.List;
#      import java.util.Map;
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
#
#          protected List<Map<String, String>> createListOfMaps(String tableLines) {
#              return null;
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
#      import java.util.List;
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
#      }
#      """

    Rule: conversion for enum types is also supported by passing the enum name of the enum constant (e.g., for enum Color { RED, GREEN }, passing RED directly as enum constant instead of original string value "RED"
    - so long as every value in the data table column can be converted to the enum constant