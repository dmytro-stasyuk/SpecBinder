Feature: EnumFactoryMethodFallback
  As a developer writing behavior specifications with domain-specific enum values
  I want the code generator to automatically resolve human-readable enum text (e.g., "monday") to the correct constant via static factory methods when direct valueOf matching fails
  So that my feature files read naturally while the generated test code remains fully type-safe and compiler-verified

  Rule: when step parameter value doesn't match any enum constant but the enum declares exactly one
  suitable static factory method, the factory method is invoked during code generation to resolve the text
  to an actual enum constant, and the resolved constant is placed directly in the generated code
  - a suitable factory method is: non-private, static, accepts a single String parameter, and returns the enum type
  - the factory method can have any name (of, from, parse, create, etc.)
  - when a direct constant match exists, it takes precedence (factory method is not invoked)
  - if the enum declares more than one suitable factory method, the fallback is not used (ambiguous)
  - if the factory method cannot resolve the value (throws an exception), the value is placed as a String literal

    Example: inner enum with of(String) factory method - lowercase value resolved to constant
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Factory Method Enum Matching
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.MyFeature.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Factory Method Enum Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1(MONDAY);
            }
        }
        """

    Example: external enum with of(String) factory method in different package
      Given the following enum class:
      """
      package features.enums;

      public enum DayOfWeek {
          MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

          public static DayOfWeek of(String value) {
              return valueOf(value.toUpperCase());
          }
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import features.enums.DayOfWeek;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }
      }
      """
      And the following feature file:
        """
        Feature: External Factory Method Enum
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.enums.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: External Factory Method Enum
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1(MONDAY);
            }
        }
        """

    Example: factory method with custom name (parse) is recognized
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek parse(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Custom Named Factory Method
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.MyFeature.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Custom Named Factory Method
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1(MONDAY);
            }
        }
        """

    Example: [counter] multiple suitable factory methods - ambiguous, compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }

              public static DayOfWeek from(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Ambiguous Factory Methods
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Ambiguous Factory Methods
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1("monday");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.MyFeature.DayOfWeek
        """

    Example: direct constant match takes precedence over factory method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Constant Precedence Over Factory
          Scenario: Test
            Given the following day of the week "MONDAY"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.MyFeature.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Constant Precedence Over Factory
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "MONDAY"
                 */
                theFollowingDayOfTheWeek$p1(MONDAY);
            }
        }
        """

    Example: [counter] enum without factory method - compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
          }
      }
      """
      Given the following feature file:
        """
        Feature: No Factory Method
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: No Factory Method
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1("monday");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.MyFeature.DayOfWeek
        """

    Example: [counter] factory method throws exception for unresolvable value - compilation error
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Factory Method Cannot Resolve
          Scenario: Test
            Given the following day of the week "not_a_day"
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Factory Method Cannot Resolve
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "not_a_day"
                 */
                theFollowingDayOfTheWeek$p1("not_a_day");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.MyFeature.DayOfWeek
        """

  Rule: factory method fallback applies to Scenario Outline parameter type inference
  - when inherited step takes an enum parameter and the enum has exactly one suitable factory method,
    example table values that don't match constants still result in enum parameter type
  - JUnit 5 handles the actual string-to-enum conversion at runtime using the factory method

    Example: mixed matching and non-matching Example values with factory method - parameter type is enum
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Factory Method With Mixed Examples
          Scenario Outline: Test with day
            Given the following day of the week "<day>"
          Examples:
            | day    |
            | MONDAY |
            | friday |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Factory Method With Mixed Examples
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            day
                            MONDAY
                            friday
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with day")
            public void scenario_1(MyFeature.DayOfWeek day) {
                /*
                 * Given the following day of the week "<day>"
                 */
                theFollowingDayOfTheWeek$p1(day);
            }
        }
        """

    Example: non-matching Example values with factory method - parameter type is enum
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Factory Method With Examples
          Scenario Outline: Test with day
            Given the following day of the week "<day>"
          Examples:
            | day    |
            | monday |
            | friday |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Factory Method With Examples
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            day
                            monday
                            friday
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with day")
            public void scenario_1(MyFeature.DayOfWeek day) {
                /*
                 * Given the following day of the week "<day>"
                 */
                theFollowingDayOfTheWeek$p1(day);
            }
        }
        """

    Example: [counter] non-matching Example values without factory method - parameter type is String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
          }
      }
      """
      Given the following feature file:
        """
        Feature: No Factory Method With Examples
          Scenario Outline: Test with day
            Given the following day of the week "<day>"
          Examples:
            | day    |
            | monday |
            | friday |
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: No Factory Method With Examples
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            day
                            monday
                            friday
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with day")
            public void scenario_1(String day) {
                /*
                 * Given the following day of the week "<day>"
                 */
                theFollowingDayOfTheWeek$p1(day);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.MyFeature.DayOfWeek
        """

  Rule: factory method fallback applies to data table object fields with enum types
  - when a parameter class field is an enum type and the enum has exactly one suitable factory method,
    cell values that don't match constants are resolved via the factory method during code generation
    and the resolved constant is placed directly in the generated code
  - when value matches an enum constant directly, the constant is used (factory method is not invoked)

    Example: data table cell values resolved to constants via factory method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED;

              public static Status of(String value) {
                  return valueOf(value.toUpperCase().replace(" ", "_"));
              }
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
          Scenario: Create products with user-friendly status values
            Given the following products:
              | name   | status       |
              | Laptop | available    |
              | Mouse  | out of stock |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static features.ProductsFeature.Status.AVAILABLE;
      import static features.ProductsFeature.Status.OUT_OF_STOCK;

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
          @DisplayName("Scenario: Create products with user-friendly status values")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | available    |
               *   | Mouse  | out of stock |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      OUT_OF_STOCK
                              )
                      ));
          }
      }
      """

    Example: mixed matching - some cells match constants directly, others resolved via factory method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;
      import org.junit.jupiter.api.Assertions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public enum Status {
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED;

              public static Status of(String value) {
                  return valueOf(value.toUpperCase());
              }
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
          Scenario: Create products with mixed status value formats
            Given the following products:
              | name   | status       |
              | Laptop | AVAILABLE    |
              | Mouse  | discontinued |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static features.ProductsFeature.Status.AVAILABLE;
      import static features.ProductsFeature.Status.DISCONTINUED;

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
          @DisplayName("Scenario: Create products with mixed status value formats")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | AVAILABLE    |
               *   | Mouse  | discontinued |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      DISCONTINUED
                              )
                      ));
          }
      }
      """

    Example: external enum with custom-named factory method for data table field
      Given the following enum class:
      """
      package external.enums;

      public enum ProductStatus {
          AVAILABLE, OUT_OF_STOCK, DISCONTINUED;

          public static ProductStatus fromText(String value) {
              return valueOf(value.toUpperCase());
          }
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
      import external.enums.ProductStatus;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class ProductsFeature {

          public void theFollowingProducts(List<ProductsParam> products) {
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
        Feature: Products With External Enum
          Scenario: Create products with external enum factory method
            Given the following products:
              | name   | status    |
              | Laptop | available |
        """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import static external.enums.ProductStatus.AVAILABLE;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.util.List;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Products With External Enum
       */
      @DisplayName("ProductsFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/ProductsFeature.feature")
      public class ProductsFeatureTest extends ProductsFeature {
          @Test
          @Order(1)
          @DisplayName("Scenario: Create products with external enum factory method")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status    |
               *   | Laptop | available |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      AVAILABLE
                              )
                      ));
          }
      }
      """

    Example: [counter] data table enum field without factory method - non-matching value passed as String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;
      import static dev.specbinder.annotations.Gherkin2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      import java.util.List;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
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
          Scenario: Create products with non-matching status
            Given the following products:
              | name   | status    |
              | Laptop | available |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
          @DisplayName("Scenario: Create products with non-matching status")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status    |
               *   | Laptop | available |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      "available"
                              )
                      ));
          }
      }
      """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.ProductsFeature.Status
        """

  Rule: factory method fallback works with useQualifiedEnumConstants option
  - when useQualifiedEnumConstants is enabled, factory-method-resolved constants use the qualified form
    (e.g., DayOfWeek.MONDAY instead of static import MONDAY)

    Example: step parameter with factory method and useQualifiedEnumConstants
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(useQualifiedEnumConstants = true)
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
          }

          public enum DayOfWeek {
              MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

              public static DayOfWeek of(String value) {
                  return valueOf(value.toUpperCase());
              }
          }
      }
      """
      Given the following feature file:
        """
        Feature: Qualified Factory Method
          Scenario: Test
            Given the following day of the week "monday"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Qualified Factory Method
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "monday"
                 */
                theFollowingDayOfTheWeek$p1(DayOfWeek.MONDAY);
            }
        }
        """

    Example: data table field with factory method and useQualifiedEnumConstants
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
              AVAILABLE, OUT_OF_STOCK, DISCONTINUED;

              public static Status of(String value) {
                  return valueOf(value.toUpperCase());
              }
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
          Scenario: Create products with qualified factory method
            Given the following products:
              | name   | status       |
              | Laptop | AVAILABLE    |
              | Mouse  | discontinued |
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
          @DisplayName("Scenario: Create products with qualified factory method")
          public void scenario_1() {
              /*
               * Given the following products:
               *   | name   | status       |
               *   | Laptop | AVAILABLE    |
               *   | Mouse  | discontinued |
               */
              theFollowingProducts(
                      List.of(
                              new ProductsParam(
                                      "Laptop",
                                      Status.AVAILABLE
                              ),
                              new ProductsParam(
                                      "Mouse",
                                      Status.DISCONTINUED
                              )
                      ));
          }
      }
      """
