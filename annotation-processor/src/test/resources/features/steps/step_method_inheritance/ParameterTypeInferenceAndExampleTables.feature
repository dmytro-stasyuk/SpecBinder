Feature: ParameterTypeInferenceAndExampleTables
  As a developer writing BDD tests with Scenario Outlines
  I want the generator to automatically match step definitions from base class even when parameter values come from the Examples tables
  So that I can use strongly-typed step methods with parameterized tests while maintaining compile-time type safety

  Rule: step methods with integer parameters match when Examples table values can be converted to integer

    Scenario: matching Examples value against Integer parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void age$p1(Integer age) {
              // Implementation with int parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Int Parameter From Examples
          Scenario Outline: Test with age
            Given age "<age>"
          Examples:
            | age |
            | 25  |
            | 42  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Int Parameter From Examples
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
                            age
                            25
                            42
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with age")
            public void scenario_1(Integer age) {
                /*
                 * Given age "<age>"
                 */
                age$p1(age);
            }
        }
        """

    Scenario: matching Examples value against boxed Integer parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void count$p1(Integer count) {
              // Implementation with Integer parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Integer Parameter From Examples
          Scenario Outline: Test with count
            Given count "<count>"
          Examples:
            | count |
            | 100   |
            | 200   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Integer Parameter From Examples
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
                            count
                            100
                            200
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with count")
            public void scenario_1(Integer count) {
                /*
                 * Given count "<count>"
                 */
                count$p1(count);
            }
        }
        """

    Example: [counter] no match when Examples values cannot all be converted to integer
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void quantity$p1(int quantity) {
              // Implementation with int parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Mixed Values In Examples
          Scenario Outline: Test with quantity
            Given quantity "<quantity>"
          Examples:
            | quantity |
            | 10       |
            | true     |
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
         * Feature: Mixed Values In Examples
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
                            quantity
                            10
                            true
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with quantity")
            public void scenario_1(String quantity) {
                /*
                 * Given quantity "<quantity>"
                 */
                quantity$p1(quantity);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to int
        """

  Rule: step methods with long parameters match when Examples table values can be converted to long

    Scenario: matching Examples value against long parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void timestamp$p1(long timestamp) {
              // Implementation with long parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Long Parameter From Examples
          Scenario Outline: Test with timestamp
            Given timestamp "<timestamp>"
          Examples:
            | timestamp  |
            | 1234567890 |
            | 9876543210 |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Long;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Parameter From Examples
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
                            timestamp
                            1234567890
                            9876543210
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with timestamp")
            public void scenario_1(Long timestamp) {
                /*
                 * Given timestamp "<timestamp>"
                 */
                timestamp$p1(timestamp);
            }
        }
        """

    Example: [counter] no match when Examples values cannot all be converted to long
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void amount$p1(long amount) {
              // Implementation with long parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Invalid Long Values In Examples
          Scenario Outline: Test with amount
            Given amount "<amount>"
          Examples:
            | amount |
            | 5000   |
            | false  |
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
         * Feature: Invalid Long Values In Examples
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
                            amount
                            5000
                            false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with amount")
            public void scenario_1(String amount) {
                /*
                 * Given amount "<amount>"
                 */
                amount$p1(amount);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to long
        """

  Rule: step methods with double parameters match when Examples table values can be converted to double

    Scenario: matching Examples value against double parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void price$p1(double price) {
              // Implementation with double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Double Parameter From Examples
          Scenario Outline: Test with price
            Given price "<price>"
          Examples:
            | price |
            | 19.99 |
            | 29.99 |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Double;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Parameter From Examples
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
                            price
                            19.99
                            29.99
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with price")
            public void scenario_1(Double price) {
                /*
                 * Given price "<price>"
                 */
                price$p1(price);
            }
        }
        """

    Scenario: integer values in Examples can be converted to double
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void rate$p1(double rate) {
              // Implementation with double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Integer To Double Conversion
          Scenario Outline: Test with rate
            Given rate "<rate>"
          Examples:
            | rate |
            | 10   |
            | 20   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Integer To Double Conversion
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
                            rate
                            10
                            20
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with rate")
            public void scenario_1(Integer rate) {
                /*
                 * Given rate "<rate>"
                 */
                rate$p1(rate);
            }
        }
        """

    Example: [counter] no match when Examples values cannot all be converted to double
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void temperature$p1(double temperature) {
              // Implementation with double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Invalid Double Values In Examples
          Scenario Outline: Test with temperature
            Given temperature "<temperature>"
          Examples:
            | temperature |
            | 98.6        |
            | hot         |
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
         * Feature: Invalid Double Values In Examples
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
                            temperature
                            98.6
                            hot
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with temperature")
            public void scenario_1(String temperature) {
                /*
                 * Given temperature "<temperature>"
                 */
                temperature$p1(temperature);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to double
        """

  Rule: step methods with boolean parameters match when Examples table values can be converted to boolean

    Scenario: matching Examples value against boolean parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void featureEnabled$p1(boolean enabled) {
              // Implementation with boolean parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean Parameter From Examples
          Scenario Outline: Test with enabled flag
            Given feature enabled "<enabled>"
          Examples:
            | enabled |
            | true    |
            | false   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Parameter From Examples
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
                            enabled
                            true
                            false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with enabled flag")
            public void scenario_1(Boolean enabled) {
                /*
                 * Given feature enabled "<enabled>"
                 */
                featureEnabled$p1(enabled);
            }
        }
        """

    Example: [counter] no match when Examples values cannot all be converted to boolean
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void value$p1(boolean value) {
              // Implementation with boolean parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Invalid Boolean Values In Examples
          Scenario Outline: Test with value
            Given value "<value>"
          Examples:
            | value |
            | true  |
            | 42    |
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
         * Feature: Invalid Boolean Values In Examples
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
                            value
                            true
                            42
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with value")
            public void scenario_1(String value) {
                /*
                 * Given value "<value>"
                 */
                value$p1(value);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to boolean
        """

  Rule: step methods with enum parameters match when all Examples table values are valid enum constants

    Scenario: matching Examples values against enum parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }

          public enum DayOfWeek {
              MONDAY,
              TUESDAY,
              WEDNESDAY,
              THURSDAY,
              FRIDAY,
              SATURDAY,
              SUNDAY
          }
      }
      """
      Given the following feature file:
        """
        Feature: Enum Parameter From Examples
          Scenario Outline: Test with day
            Given the following day of the week "<day>"
          Examples:
            | day    |
            | MONDAY |
            | FRIDAY |
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
         * Feature: Enum Parameter From Examples
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
                            FRIDAY
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

    Example: [counter] no match when any Examples value is not a valid enum constant
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }

          public enum DayOfWeek {
              MONDAY,
              TUESDAY,
              WEDNESDAY,
              THURSDAY,
              FRIDAY,
              SATURDAY,
              SUNDAY
          }
      }
      """
      Given the following feature file:
        """
        Feature: Invalid Enum Values In Examples
          Scenario Outline: Test with day
            Given the following day of the week "<day>"
          Examples:
            | day         |
            | MONDAY      |
            | INVALID_DAY |
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
         * Feature: Invalid Enum Values In Examples
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
                            INVALID_DAY
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

    Scenario: matching enum with multiple enum types in base class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void status$p1(Status status) {
              // Implementation with Status enum parameter
          }

          protected void priority$p1(Priority priority) {
              // Implementation with Priority enum parameter
          }

          public enum Status {
              ACTIVE,
              INACTIVE,
              PENDING
          }

          public enum Priority {
              LOW,
              MEDIUM,
              HIGH
          }
      }
      """
      Given the following feature file:
        """
        Feature: Multiple Enums In Base Class
          Scenario Outline: Test with status
            Given status "<status>"
          Examples:
            | status   |
            | ACTIVE   |
            | INACTIVE |
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
         * Feature: Multiple Enums In Base Class
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
                            status
                            ACTIVE
                            INACTIVE
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with status")
            public void scenario_1(MyFeature.Status status) {
                /*
                 * Given status "<status>"
                 */
                status$p1(status);
            }
        }
        """

    Scenario: case-sensitive enum constant matching
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void color$p1(Color color) {
              // Implementation with enum parameter
          }

          public enum Color {
              RED,
              GREEN,
              BLUE
          }
      }
      """
      Given the following feature file:
        """
        Feature: Case Insensitive Enum Matching
          Scenario Outline: Test with color
            Given color "<color>"
          Examples:
            | color |
            | red   |
            | GREEN |
            | Blue  |
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
         * Feature: Case Insensitive Enum Matching
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
                            color
                            red
                            GREEN
                            Blue
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with color")
            public void scenario_1(String color) {
                /*
                 * Given color "<color>"
                 */
                color$p1(color);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.MyFeature.Color
        """

    Scenario: enum takes precedence over boolean when values match both
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void answer$p1(Answer answer) {
              // Implementation with enum parameter
          }

          public enum Answer {
              TRUE,
              FALSE,
              MAYBE
          }
      }
      """
      Given the following feature file:
        """
        Feature: Enum With Boolean-Like Constants
          Scenario Outline: Test with answer
            Given answer "<answer>"
          Examples:
            | answer |
            | TRUE   |
            | FALSE  |
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
         * Feature: Enum With Boolean-Like Constants
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
                            answer
                            TRUE
                            FALSE
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with answer")
            public void scenario_1(MyFeature.Answer answer) {
                /*
                 * Given answer "<answer>"
                 */
                answer$p1(answer);
            }
        }
        """

    Scenario: mixed enum and primitive parameters from Examples
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void taskWithStatus$p1AndPriority$p2(Status status, int priority) {
              // Implementation with enum and int parameters
          }

          public enum Status {
              TODO,
              IN_PROGRESS,
              DONE
          }
      }
      """
      Given the following feature file:
        """
        Feature: Mixed Enum And Primitive Parameters
          Scenario Outline: Test with task
            Given task with status "<status>" and priority "<priority>"
          Examples:
            | status      | priority |
            | TODO        | 1        |
            | IN_PROGRESS | 2        |
            | DONE        | 3        |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Enum And Primitive Parameters
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
                            status      | priority
                            TODO        | 1
                            IN_PROGRESS | 2
                            DONE        | 3
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with task")
            public void scenario_1(MyFeature.Status status, Integer priority) {
                /*
                 * Given task with status "<status>" and priority "<priority>"
                 */
                taskWithStatus$p1AndPriority$p2(status, priority);
            }
        }
        """

  Rule: step methods with multiple parameters match when all Examples table values can be converted

    Scenario: matching Examples values against multiple typed parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void userWithName$p1AndAge$p2(String name, int age) {
              // Implementation with String and int parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Multiple Parameters From Examples
          Scenario Outline: Test with user data
            Given user with name "<name>" and age "<age>"
          Examples:
            | name  | age |
            | Alice | 25  |
            | Bob   | 30  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Multiple Parameters From Examples
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
                            name  | age
                            Alice | 25
                            Bob   | 30
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with user data")
            public void scenario_1(String name, Integer age) {
                /*
                 * Given user with name "<name>" and age "<age>"
                 */
                userWithName$p1AndAge$p2(name, age);
            }
        }
        """

    Example: [counter] no match when one parameter's Examples values cannot be converted
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void productWithName$p1AndPrice$p2(String name, double price) {
              // Implementation with String and double parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Multiple Parameters With Invalid Value
          Scenario Outline: Test with product data
            Given product with name "<name>" and price "<price>"
          Examples:
            | name   | price |
            | Widget | 19.99 |
            | Gadget | cheap |
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
         * Feature: Multiple Parameters With Invalid Value
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
                            name   | price
                            Widget | 19.99
                            Gadget | cheap
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with product data")
            public void scenario_1(String name, String price) {
                /*
                 * Given product with name "<name>" and price "<price>"
                 */
                productWithName$p1AndPrice$p2(name, price);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to double
        """

    Scenario: matching Examples values against all primitive types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void dataWithValues$p1$p2$p3$p4(int count, long timestamp, double price, boolean enabled) {
              // Implementation with int, long, double, and boolean parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: All Primitive Types From Examples
          Scenario Outline: Test with all types
            Given data with values "<count>" "<timestamp>" "<price>" "<enabled>"
          Examples:
            | count | timestamp  | price | enabled |
            | 42    | 1234567890 | 19.99 | true    |
            | 100   | 9876543210 | 29.99 | false   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import java.lang.Double;
        import java.lang.Integer;
        import java.lang.Long;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: All Primitive Types From Examples
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
                            count | timestamp  | price | enabled
                            42    | 1234567890 | 19.99 | true
                            100   | 9876543210 | 29.99 | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with all types")
            public void scenario_1(Integer count, Long timestamp, Double price, Boolean enabled) {
                /*
                 * Given data with values "<count>" "<timestamp>" "<price>" "<enabled>"
                 */
                dataWithValues$p1$p2$p3$p4(count, timestamp, price, enabled);
            }
        }
        """

  Rule: mixed parameters with some from Examples and some literal values

    Scenario: matching when one parameter is literal and one is from Examples
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void userWithRole$p1AndAge$p2(String role, int age) {
              // Implementation with String and int parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Mixed Literal And Examples Parameters
          Scenario Outline: Test with mixed parameters
            Given user with role "admin" and age "<age>"
          Examples:
            | age |
            | 25  |
            | 30  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal And Examples Parameters
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
                            age
                            25
                            30
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed parameters")
            public void scenario_1(Integer age) {
                /*
                 * Given user with role "admin" and age "<age>"
                 */
                userWithRole$p1AndAge$p2("admin", age);
            }
        }
        """

    Example: [counter] literal value mismatch prevents match even when Examples values are valid
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void configWithEnabled$p1AndCount$p2(boolean enabled, int count) {
              // Implementation with boolean and int parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Literal Mismatch With Valid Examples
          Scenario Outline: Test with literal mismatch
            Given config with enabled "maybe" and count "<count>"
          Examples:
            | count |
            | 10    |
            | 20    |
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Literal Mismatch With Valid Examples
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
                            count
                            10
                            20
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal mismatch")
            public void scenario_1(Integer count) {
                /*
                 * Given config with enabled "maybe" and count "<count>"
                 */
                configWithEnabled$p1AndCount$p2("maybe", count);
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to boolean
        """