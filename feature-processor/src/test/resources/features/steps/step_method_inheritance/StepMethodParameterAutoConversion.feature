Feature: StepMethodParameterAutoConversion
  As a developer writing BDD tests with existing step implementations
  I want the generator to automatically match step definitions with compatible parameter types
  So that I can use strongly-typed step methods (int, long, double & boolean) without manual type conversion, catching type mismatches at compile-time rather than runtime

  Rule: step methods on the class hierarchy are considered a match only if their signatures match including the number
  and type of parameters
    - regarding the parameter types, all parameters are treated initially as String
    - however when it comes to matching existing methods on the class hierarchy the type of the parameter can be String
    - or any of the primitive types (int, long, double, boolean) or their boxed equivalents (Integer, Long, Double, Boolean) or an enum type
    - in such cases the parameter in the step method signature is considered a match only if the parameter in the feature file
    - can be converted to the required type (e.g. "42" can be converted to int/Integer/long/Long but not to boolean/Boolean)
    - similarly "true" and "false" can be converted to boolean/Boolean but not to numeric types
    - any other string value can only be converted to String type

    Scenario: matching step with string parameter against string method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserWithName$p1(String name) {
              // Implementation with String parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: String Parameter Matching
          Scenario: Test
            Given user with name "Alice"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: String Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user with name "Alice"
                 */
                givenUserWithName$p1("Alice");
            }
        }
        """

  Rule: step methods on the class hierarchy with integer parameters are considered a match if conversion is possible

    Scenario: matching numeric value against int parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenAge$p1(int age) {
              // Implementation with int parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Int Parameter Matching
          Scenario: Test
            Given age "42"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Int Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given age "42"
                 */
                givenAge$p1(42);
            }
        }
        """

    Scenario: matching numeric value against boxed integer parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenCount$p1(Integer count) {
              // Implementation with Integer parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Integer Parameter Matching
          Scenario: Test
            Given count "100"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Integer Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given count "100"
                 */
                givenCount$p1(100);
            }
        }
        """

    Example: [counter] no match when value cannot be converted to integer type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenQuantity$p1(int quantity) {
              // Implementation with int parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean To Numeric Mismatch
          Scenario: Test
            Given quantity "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean To Numeric Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenQuantity$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given quantity "true"
                 */
                givenQuantity$p1("true");
            }
        }
        """

    Example: [counter] base method with same name but Object parameter type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenQuantity$p1(Object quantity) {
              // Implementation with Object parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean To Numeric Mismatch
          Scenario: Test
            Given quantity "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean To Numeric Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenQuantity$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given quantity "true"
                 */
                givenQuantity$p1("true");
            }
        }
        """

  Rule: step methods on the class hierarchy with long parameters are considered a match if conversion is possible

    Scenario: matching numeric value against long parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenTimestamp$p1(long timestamp) {
              // Implementation with long parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Long Parameter Matching
          Scenario: Test
            Given timestamp "1234567890"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Long Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given timestamp "1234567890"
                 */
                givenTimestamp$p1(1234567890L);
            }
        }
        """

    Scenario: matching numeric value against boxed long parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenDuration$p1(Long duration) {
              // Implementation with Long parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Long Boxed Parameter Matching
          Scenario: Test
            Given duration "5000"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Long Boxed Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given duration "5000"
                 */
                givenDuration$p1(5000L);
            }
        }
        """

    Example: [counter] no match when value cannot be converted to long type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenAmount$p1(long amount) {
              // Implementation with long parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean To Long Mismatch
          Scenario: Test
            Given amount "false"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean To Long Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenAmount$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given amount "false"
                 */
                givenAmount$p1("false");
            }
        }
        """

  Rule: step methods on the class hierarchy with double parameters are considered a match if conversion is possible

    Scenario: matching numeric value against double parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenPrice$p1(double price) {
              // Implementation with double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Double Parameter Matching
          Scenario: Test
            Given price "19.99"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Double Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given price "19.99"
                 */
                givenPrice$p1(19.99);
            }
        }
        """

    Scenario: matching numeric value against boxed double parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenTemperature$p1(Double temperature) {
              // Implementation with Double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Double Boxed Parameter Matching
          Scenario: Test
            Given temperature "98.6"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Double Boxed Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given temperature "98.6"
                 */
                givenTemperature$p1(98.6);
            }
        }
        """

    Scenario: no match when value cannot be converted to double type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenRate$p1(double rate) {
              // Implementation with double parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean To Double Mismatch
          Scenario: Test
            Given rate "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean To Double Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenRate$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given rate "true"
                 */
                givenRate$p1("true");
            }
        }
        """

  Rule: step methods on the class hierarchy with boolean parameters are considered a match if conversion is possible

    Scenario: matching boolean value against boolean parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenFeatureEnabled$p1(boolean enabled) {
              // Implementation with boolean parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean Parameter Matching
          Scenario: Test
            Given feature enabled "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given feature enabled "true"
                 */
                givenFeatureEnabled$p1(true);
            }
        }
        """

    Scenario: matching boolean value against boxed boolean parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenFlagSet$p1(Boolean flag) {
              // Implementation with Boolean parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Boolean Boxed Parameter Matching
          Scenario: Test
            Given flag set "false"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Boxed Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given flag set "false"
                 */
                givenFlagSet$p1(false);
            }
        }
        """

    Scenario: no match when value cannot be converted to boolean
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenValue$p1(boolean value) {
              // Implementation with boolean parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Numeric To Boolean Mismatch
          Scenario: Test
            Given value "42"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Numeric To Boolean Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenValue$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given value "42"
                 */
                givenValue$p1("42");
            }
        }
        """

  Rule: step methods on the class hierarchy with Enum parameters are considered a match if conversion using enum constant's "valueOf(String arg)" is possible

    Scenario: matching enum value against enum type parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void givenTheFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
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
        Feature: Boolean Parameter Matching
          Scenario: Test
            Given the following day of the week "MONDAY"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.MyFeature.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "MONDAY"
                 */
                givenTheFollowingDayOfTheWeek$p1(MONDAY);
            }
        }
        """

    Example: [counter] inherited method with required name has enum parameter type but not matching constant for our parameter value
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void givenTheFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
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
        Feature: Enum Parameter Matching
          Scenario: Test
            Given the following day of the week "INVALID_DAY"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Enum Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenTheFollowingDayOfTheWeek$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following day of the week "INVALID_DAY"
                 */
                givenTheFollowingDayOfTheWeek$p1("INVALID_DAY");
            }
        }
        """

  Rule: same step matching logic applies for step methods with multiple parameters, can be of different types

    Scenario: matching step with multiple parameters of different types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserWithName$p1AndAge$p2(String name, int age) {
              // Implementation with String and int parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Multiple Parameters Matching
          Scenario: Test
            Given user with name "Bob" and age "25"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Parameters Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user with name "Bob" and age "25"
                 */
                givenUserWithName$p1AndAge$p2("Bob", 25);
            }
        }
        """

    Scenario: matching step with all primitive types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenDataWithValues$p1$p2$p3$p4(int count, long timestamp, double price, boolean enabled) {
              // Implementation with int, long, double, and boolean parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: All Primitive Types Matching
          Scenario: Test
            Given data with values "42" "1234567890" "19.99" "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: All Primitive Types Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given data with values "42" "1234567890" "19.99" "true"
                 */
                givenDataWithValues$p1$p2$p3$p4(42, 1234567890L, 19.99, true);
            }
        }
        """

    Scenario: no match when one parameter cannot be converted
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenProductWithName$p1AndPrice$p2(String name, double price) {
              // Implementation with String and double parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Multiple Parameters With Mismatch
          Scenario: Test
            Given product with name "Widget" and price "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Parameters With Mismatch
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenProductWithName$p1AndPrice$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given product with name "Widget" and price "true"
                 */
                givenProductWithName$p1AndPrice$p2("Widget", "true");
            }
        }
        """

    Scenario: matching mixed boxed and primitive parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenConfigWithValues$p1$p2$p3(Integer count, double rate, Boolean enabled) {
              // Implementation with Integer, double, and Boolean parameters
          }
      }
      """
      Given the following feature file:
        """
        Feature: Mixed Boxed And Primitive Matching
          Scenario: Test
            Given config with values "100" "3.14" "false"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Mixed Boxed And Primitive Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given config with values "100" "3.14" "false"
                 */
                givenConfigWithValues$p1$p2$p3(100, 3.14, false);
            }
        }
        """




