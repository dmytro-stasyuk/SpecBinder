Feature: TypeInferenceWithEnumFields
  As a BDD test developer working with domain models that use enums for type-safe state representation
  I want Gherkin data table values automatically converted to enum constants with proper static imports
  So that I can write readable test scenarios without manual enum conversion code, catching invalid enum values at compile-time instead of runtime

  Rule: conversion for enum types is also supported by passing the enum name of the enum constant (e.g., for enum Color
  { RED, GREEN }, passing RED directly as enum constant instead of original string value "RED"
  - a static import is added for the enum type constant that is used as as the parameter value

    Scenario: Existing inner class has a single enum field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void givenTheFollowingProducts(List<ProductsParam> products) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class ProductsParam {

              private final String name;
              private final Status status;

              public ProductsParam(String name, Status status) {
                  this.name = name;
                  this.status = status;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario: Create products with status
            Given the following products:
              | name   | status        |
              | Laptop | AVAILABLE     |
              | Mouse  | OUT_OF_STOCK  |
              | Tablet | DISCONTINUED  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static features.ProductsFeature.Status.AVAILABLE;
      import static features.ProductsFeature.Status.DISCONTINUED;
      import static features.ProductsFeature.Status.OUT_OF_STOCK;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with status")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | AVAILABLE    |
               *   | Mouse  | OUT_OF_STOCK |
               *   | Tablet | DISCONTINUED |
               */
              givenTheFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      OUT_OF_STOCK
                              ),
                              new ProductsParam(
                                      "Tablet",
                                      DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: Existing inner class has multiple enum fields
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class OrdersFeature {

          public enum Status {
              PENDING, SHIPPED, DELIVERED, CANCELLED
          }

          public enum Priority {
              LOW, MEDIUM, HIGH, URGENT
          }

          public void givenTheFollowingOrders(List<OrdersParam> orders) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class OrdersParam {

              private final String orderId;
              private final Status status;
              private final Priority priority;

              public OrdersParam(String orderId, Status status, Priority priority) {
                  this.orderId = orderId;
                  this.status = status;
                  this.priority = priority;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Orders Management
          Scenario: Create orders with status and priority
            Given the following orders:
              | order id | status    | priority |
              | ORD-001  | PENDING   | HIGH     |
              | ORD-002  | SHIPPED   | MEDIUM   |
              | ORD-003  | DELIVERED | LOW      |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static features.OrdersFeature.Priority.HIGH;
      import static features.OrdersFeature.Priority.LOW;
      import static features.OrdersFeature.Priority.MEDIUM;
      import static features.OrdersFeature.Status.DELIVERED;
      import static features.OrdersFeature.Status.PENDING;
      import static features.OrdersFeature.Status.SHIPPED;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Orders Management
       */
      @DisplayName("OrdersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/OrdersFeature.feature")
      public class OrdersFeatureTest extends OrdersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create orders with status and priority")
          public void scenario_1() {
              /*
               * Given the following orders:
               *   | order id | status    | priority |
               *   | ORD-001  | PENDING   | HIGH     |
               *   | ORD-002  | SHIPPED   | MEDIUM   |
               *   | ORD-003  | DELIVERED | LOW      |
               */
              givenTheFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      "ORD-001",
                                      PENDING,
                                      HIGH
                              ),
                              new OrdersParam(
                                      "ORD-002",
                                      SHIPPED,
                                      MEDIUM
                              ),
                              new OrdersParam(
                                      "ORD-003",
                                      DELIVERED,
                                      LOW
                              )
                      ));
          }
      }
      """

    Scenario: Existing inner class has mix of enum, primitive, and wrapper types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class EmployeesFeature {

          public enum Department {
              ENGINEERING, SALES, MARKETING, HR
          }

          public enum EmploymentType {
              FULL_TIME, PART_TIME, CONTRACT
          }

          public void givenTheFollowingEmployees(List<EmployeesParam> employees) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class EmployeesParam {

              private final String name;
              private final int age;
              private final Department department;
              private final EmploymentType employmentType;
              private final Double salary;
              private final boolean active;

              public EmployeesParam(String name, int age, Department department, EmploymentType employmentType, Double salary, boolean active) {
                  this.name = name;
                  this.age = age;
                  this.department = department;
                  this.employmentType = employmentType;
                  this.salary = salary;
                  this.active = active;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Employees Management
          Scenario: Create employees with mixed types
            Given the following employees:
              | name  | age | department  | employment type | salary   | active |
              | Alice | 30  | ENGINEERING | FULL_TIME       | 85000.00 | true   |
              | Bob   | 25  | SALES       | PART_TIME       | 45000.00 | false  |
              | Carol | 35  | MARKETING   | CONTRACT        | 65000.00 | true   |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static features.EmployeesFeature.Department.ENGINEERING;
      import static features.EmployeesFeature.Department.MARKETING;
      import static features.EmployeesFeature.Department.SALES;
      import static features.EmployeesFeature.EmploymentType.CONTRACT;
      import static features.EmployeesFeature.EmploymentType.FULL_TIME;
      import static features.EmployeesFeature.EmploymentType.PART_TIME;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Employees Management
       */
      @DisplayName("EmployeesFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/EmployeesFeature.feature")
      public class EmployeesFeatureTest extends EmployeesFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create employees with mixed types")
          public void scenario_1() {
              /*
               * Given the following employees:
               *   | name  | age | department  | employment type | salary   | active |
               *   | Alice | 30  | ENGINEERING | FULL_TIME       | 85000.00 | true   |
               *   | Bob   | 25  | SALES       | PART_TIME       | 45000.00 | false  |
               *   | Carol | 35  | MARKETING   | CONTRACT        | 65000.00 | true   |
               */
              givenTheFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      "Alice",
                                      30,
                                      ENGINEERING,
                                      FULL_TIME,
                                      85000.00,
                                      true
                              ),
                              new EmployeesParam(
                                      "Bob",
                                      25,
                                      SALES,
                                      PART_TIME,
                                      45000.00,
                                      false
                              ),
                              new EmployeesParam(
                                      "Carol",
                                      35,
                                      MARKETING,
                                      CONTRACT,
                                      65000.00,
                                      true
                              )
                      ));
          }
      }
      """

  Rule: if there is no matching enum constant for the specified value then it should be passed in as String
  i.e. wrapped in double quotes and the generated class won't compile

    Example: Invalid enum value that doesn't exist used
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void givenTheFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;
              private final Status status;

              public ProductsParam(String name, Status status) {
                  this.name = name;
                  this.status = status;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario: Create products with invalid status
            Given the following products:
              | name   | status     |
              | Laptop | IN_TRANSIT |
        """
      When the generator is run
      Then the following java source file should be be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with invalid status")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status     |
               *   | Laptop | IN_TRANSIT |
               */
              givenTheFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      "IN_TRANSIT"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.ProductsFeature.Status
        """

  Rule: if data table cell value is empty then for enum field null is passed

    Example: Empty cell value for enum field passes null
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void givenTheFollowingProducts(List<ProductsParam> products) {
          }

          public static class ProductsParam {

              private final String name;
              private final Status status;

              public ProductsParam(String name, Status status) {
                  this.name = name;
                  this.status = status;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario: Create products with empty status
            Given the following products:
              | name   | status |
              | Laptop |        |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with empty status")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status |
               *   | Laptop |        |
               */
              givenTheFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      null
                              )
                      ));
          }
      }
      """

  Rule: enum type inference works for enums declared in external packages
  - when enum is declared in its own class file in another package, static imports are added for the enum constants
  - when enum is declared as inner class inside another class in another package, static imports are added for the enum constants

    Scenario: Enum declared in its own class file in another package
      Given the following enum class:
      """
      package external.enums;

      public enum ProductStatus {
          AVAILABLE, OUT_OF_STOCK, DISCONTINUED
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;
      import external.enums.ProductStatus;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public void givenTheFollowingProducts(List<ProductsParam> products) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class ProductsParam {

              private final String name;
              private final ProductStatus status;

              public ProductsParam(String name, ProductStatus status) {
                  this.name = name;
                  this.status = status;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Products Management
          Scenario: Create products with external enum status
            Given the following products:
              | name   | status        |
              | Laptop | AVAILABLE     |
              | Mouse  | OUT_OF_STOCK  |
              | Tablet | DISCONTINUED  |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static external.enums.ProductStatus.AVAILABLE;
      import static external.enums.ProductStatus.DISCONTINUED;
      import static external.enums.ProductStatus.OUT_OF_STOCK;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with external enum status")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | AVAILABLE    |
               *   | Mouse  | OUT_OF_STOCK |
               *   | Tablet | DISCONTINUED |
               */
              givenTheFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      OUT_OF_STOCK
                              ),
                              new ProductsParam(
                                      "Tablet",
                                      DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: Enum declared as inner class inside another class in another package
      Given the following enum class:
      """
      package external.models;

      public class OrderModel {

          public enum OrderStatus {
              PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
          }

          public enum Priority {
              LOW, MEDIUM, HIGH, URGENT
          }
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;
      import external.models.OrderModel.OrderStatus;
      import external.models.OrderModel.Priority;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class OrdersFeature {

          public void givenTheFollowingOrders(List<OrdersParam> orders) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class OrdersParam {

              private final String orderId;
              private final OrderStatus status;
              private final Priority priority;

              public OrdersParam(String orderId, OrderStatus status, Priority priority) {
                  this.orderId = orderId;
                  this.status = status;
                  this.priority = priority;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Orders Management
          Scenario: Create orders with external nested enum types
            Given the following orders:
              | order id | status     | priority |
              | ORD-001  | PENDING    | HIGH     |
              | ORD-002  | PROCESSING | MEDIUM   |
              | ORD-003  | SHIPPED    | URGENT   |
              | ORD-004  | DELIVERED  | LOW      |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static external.models.OrderModel.OrderStatus.DELIVERED;
      import static external.models.OrderModel.OrderStatus.PENDING;
      import static external.models.OrderModel.OrderStatus.PROCESSING;
      import static external.models.OrderModel.OrderStatus.SHIPPED;
      import static external.models.OrderModel.Priority.HIGH;
      import static external.models.OrderModel.Priority.LOW;
      import static external.models.OrderModel.Priority.MEDIUM;
      import static external.models.OrderModel.Priority.URGENT;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Orders Management
       */
      @DisplayName("OrdersFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/OrdersFeature.feature")
      public class OrdersFeatureTest extends OrdersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create orders with external nested enum types")
          public void scenario_1() {
              /*
               * Given the following orders:
               *   | order id | status     | priority |
               *   | ORD-001  | PENDING    | HIGH     |
               *   | ORD-002  | PROCESSING | MEDIUM   |
               *   | ORD-003  | SHIPPED    | URGENT   |
               *   | ORD-004  | DELIVERED  | LOW      |
               */
              givenTheFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      "ORD-001",
                                      PENDING,
                                      HIGH
                              ),
                              new OrdersParam(
                                      "ORD-002",
                                      PROCESSING,
                                      MEDIUM
                              ),
                              new OrdersParam(
                                      "ORD-003",
                                      SHIPPED,
                                      URGENT
                              ),
                              new OrdersParam(
                                      "ORD-004",
                                      DELIVERED,
                                      LOW
                              )
                      ));
          }
      }
      """
