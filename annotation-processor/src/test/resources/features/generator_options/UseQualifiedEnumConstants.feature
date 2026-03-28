Feature: UseQualifiedEnumConstants
  As a BDD test developer working with codebases that have multiple enums with similar constant names
  I want enum constants referenced with their type qualifier (e.g., Status.AVAILABLE instead of static import AVAILABLE)
  So that generated code is self-documenting and avoids ambiguity when different enums share constant names like ACTIVE or PENDING

  Rule: enum constants are referenced with their type name prefix

    Scenario: Single enum field with qualified constants for enum defined in base class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void theFollowingProducts(List<ProductsParam> products) {
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
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
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      Status.AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      Status.OUT_OF_STOCK
                              ),
                              new ProductsParam(
                                      "Tablet",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: Multiple enum fields with qualified constants defined in base class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class OrdersFeature {

          public enum Status {
              PENDING, SHIPPED, DELIVERED, CANCELLED
          }

          public enum Priority {
              LOW, MEDIUM, HIGH, URGENT
          }

          public void theFollowingOrders(List<OrdersParam> orders) {
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/OrdersFeature.feature")
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
              theFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      "ORD-001",
                                      Status.PENDING,
                                      Priority.HIGH
                              ),
                              new OrdersParam(
                                      "ORD-002",
                                      Status.SHIPPED,
                                      Priority.MEDIUM
                              ),
                              new OrdersParam(
                                      "ORD-003",
                                      Status.DELIVERED,
                                      Priority.LOW
                              )
                      ));
          }
      }
      """

    Scenario: Mixed enum, primitive, and wrapper types with qualified enum constants
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class EmployeesFeature {

          public enum Department {
              ENGINEERING, SALES, MARKETING, HR
          }

          public enum EmploymentType {
              FULL_TIME, PART_TIME, CONTRACT
          }

          public void theFollowingEmployees(List<EmployeesParam> employees) {
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/EmployeesFeature.feature")
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
              theFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      "Alice",
                                      30,
                                      Department.ENGINEERING,
                                      EmploymentType.FULL_TIME,
                                      85000.00,
                                      true
                              ),
                              new EmployeesParam(
                                      "Bob",
                                      25,
                                      Department.SALES,
                                      EmploymentType.PART_TIME,
                                      45000.00,
                                      false
                              ),
                              new EmployeesParam(
                                      "Carol",
                                      35,
                                      Department.MARKETING,
                                      EmploymentType.CONTRACT,
                                      65000.00,
                                      true
                              )
                      ));
          }
      }
      """

  Rule: when enum type is not defined in an ancestor class then a regular (non-static) import is added for the enum type
  and references constants with type prefix

    Scenario: Single external enum field with qualified constants
      Given the following enum class:
      """
      package features.enums;

      public enum Status {
          AVAILABLE, OUT_OF_STOCK, DISCONTINUED
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;
      import features.enums.Status;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class ProductsFeature {

          public void theFollowingProducts(List<ProductsParam> products) {
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
          Scenario: Create products with external enum
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

      import features.enums.Status;

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with external enum")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | AVAILABLE    |
               *   | Mouse  | OUT_OF_STOCK |
               *   | Tablet | DISCONTINUED |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      Status.AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      Status.OUT_OF_STOCK
                              ),
                              new ProductsParam(
                                      "Tablet",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: Multiple external enum fields from different packages
      Given the following enum class:
      """
      package features.enums;

      public enum Status {
          PENDING, SHIPPED, DELIVERED, CANCELLED
      }
      """
      And the following enum class:
      """
      package features.enums;

      public enum Priority {
          LOW, MEDIUM, HIGH, URGENT
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;
      import features.enums.Status;
      import features.enums.Priority;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class OrdersFeature {

          public void theFollowingOrders(List<OrdersParam> orders) {
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
          Scenario: Create orders with external enums
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

      import features.enums.Status;
      import features.enums.Priority;

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/OrdersFeature.feature")
      public class OrdersFeatureTest extends OrdersFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create orders with external enums")
          public void scenario_1() {
              /*
               * Given the following orders:
               *   | order id | status    | priority |
               *   | ORD-001  | PENDING   | HIGH     |
               *   | ORD-002  | SHIPPED   | MEDIUM   |
               *   | ORD-003  | DELIVERED | LOW      |
               */
              theFollowingOrders(
                      List.of(
                              new OrdersParam(
                                      "ORD-001",
                                      Status.PENDING,
                                      Priority.HIGH
                              ),
                              new OrdersParam(
                                      "ORD-002",
                                      Status.SHIPPED,
                                      Priority.MEDIUM
                              ),
                              new OrdersParam(
                                      "ORD-003",
                                      Status.DELIVERED,
                                      Priority.LOW
                              )
                      ));
          }
      }
      """

    Scenario: Mixed internal and external enum fields
      Given the following enum class:
      """
      package features.enums;

      public enum Department {
          ENGINEERING, SALES, MARKETING, HR
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;
      import features.enums.Department;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class EmployeesFeature {

          public enum EmploymentType {
              FULL_TIME, PART_TIME, CONTRACT
          }

          public void theFollowingEmployees(List<EmployeesParam> employees) {
              Assertions.fail("Step is not yet implemented");
          }

          public static class EmployeesParam {

              private final String name;
              private final Department department;
              private final EmploymentType employmentType;

              public EmployeesParam(String name, Department department, EmploymentType employmentType) {
                  this.name = name;
                  this.department = department;
                  this.employmentType = employmentType;
              }
          }
      }
      """
      And the following feature file:
        """
        Feature: Employees Management
          Scenario: Create employees with mixed enum types
            Given the following employees:
              | name  | department  | employment type |
              | Alice | ENGINEERING | FULL_TIME       |
              | Bob   | SALES       | PART_TIME       |
              | Carol | MARKETING   | CONTRACT        |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import features.enums.Department;

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/EmployeesFeature.feature")
      public class EmployeesFeatureTest extends EmployeesFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create employees with mixed enum types")
          public void scenario_1() {
              /*
               * Given the following employees:
               *   | name  | department  | employment type |
               *   | Alice | ENGINEERING | FULL_TIME       |
               *   | Bob   | SALES       | PART_TIME       |
               *   | Carol | MARKETING   | CONTRACT        |
               */
              theFollowingEmployees(
                      List.of(
                              new EmployeesParam(
                                      "Alice",
                                      Department.ENGINEERING,
                                      EmploymentType.FULL_TIME
                              ),
                              new EmployeesParam(
                                      "Bob",
                                      Department.SALES,
                                      EmploymentType.PART_TIME
                              ),
                              new EmployeesParam(
                                      "Carol",
                                      Department.MARKETING,
                                      EmploymentType.CONTRACT
                              )
                      ));
          }
      }
      """

  Rule: qualified enum constants work correctly with Scenario Outline and Example references
  using Type.valueOf() conversion at runtime

    Example: Data table with mixed literal and Example reference rows for enum field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED
          }

          public void theFollowingProducts(List<ProductsParam> products) {
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
          Scenario Outline: Create products with mixed rows
            Given the following products:
              | name          | status       |
              | <productName> | <status>     |
              | DefaultItem   | DISCONTINUED |

            Examples:
              | productName | status       |
              | Laptop      | AVAILABLE    |
              | Mouse       | OUT_OF_STOCK |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | status
                          Laptop      | AVAILABLE
                          Mouse       | OUT_OF_STOCK
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create products with mixed rows")
          public void scenario_1(String productName, Status status) {
              /*
               * Given the following products:
               *   | name          | status       |
               *   | <productName> | <status>     |
               *   | DefaultItem   | DISCONTINUED |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      status
                              ),
                              new ProductsParam(
                                      "DefaultItem",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: External enum with Scenario Outline and Example references
      Given the following enum class:
      """
      package features.enums;

      public enum Status {
          AVAILABLE, OUT_OF_STOCK, DISCONTINUED
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import features.enums.Status;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class ProductsFeature {

          public void theFollowingProducts(List<ProductsParam> products) {
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
          Scenario Outline: Create products with mixed rows and external enum
            Given the following products:
              | name          | status       |
              | <productName> | <status>     |
              | DefaultItem   | DISCONTINUED |

            Examples:
              | productName | status       |
              | Laptop      | AVAILABLE    |
              | Mouse       | OUT_OF_STOCK |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import features.enums.Status;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | status
                          Laptop      | AVAILABLE
                          Mouse       | OUT_OF_STOCK
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create products with mixed rows and external enum")
          public void scenario_1(String productName, Status status) {
              /*
               * Given the following products:
               *   | name          | status       |
               *   | <productName> | <status>     |
               *   | DefaultItem   | DISCONTINUED |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      status
                              ),
                              new ProductsParam(
                                      "DefaultItem",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """

    Scenario: Data table uses literal enum values instead of Example placeholder - parameter type remains String
      Given the following enum class:
      """
      package features.enums;

      public enum Status {
          AVAILABLE, OUT_OF_STOCK, DISCONTINUED
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import features.enums.Status;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS, useQualifiedEnumConstants = true)
      public abstract class ProductsFeature {

          public void theFollowingProducts(List<ProductsParam> products) {
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
          Scenario Outline: Create products with mixed rows and external enum
            Given the following products:
              | name          | status       |
              | <productName> | AVAILABLE    |
              | DefaultItem   | DISCONTINUED |

            Examples:
              | productName | status       |
              | Laptop      | AVAILABLE    |
              | Mouse       | OUT_OF_STOCK |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import features.enums.Status;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Products Management
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          productName | status
                          Laptop      | AVAILABLE
                          Mouse       | OUT_OF_STOCK
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Create products with mixed rows and external enum")
          public void scenario_1(String productName, String status) {
              /*
               * Given the following products:
               *   | name          | status       |
               *   | <productName> | AVAILABLE    |
               *   | DefaultItem   | DISCONTINUED |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      productName,
                                      Status.AVAILABLE
                              ),
                              new ProductsParam(
                                      "DefaultItem",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """