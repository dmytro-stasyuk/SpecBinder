Feature: InheritedStepAndParameterTypeInferenceForEnums
  As a developer writing behavior specifications with enum-typed step parameters
  I want the code generator to automatically infer enum types from inherited step methods and substitute matching constant names in place of raw strings
  So that the generated test code is type-safe and compiles without manual enum conversion, regardless of where the enum is declared

  Rule: parameters of Enum type are passed as enum equivalent constants

    Example: enum parameter type is declared inside base class
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
        Feature: Boolean Parameter Matching
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
         * Feature: Boolean Parameter Matching
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

    Example: enum parameter type is declared in same package as base class but in its own file
      Given the following enum class:
      """
      package features;

      public enum DayOfWeek {
          MONDAY,
          TUESDAY,
          WEDNESDAY,
          THURSDAY,
          FRIDAY,
          SATURDAY,
          SUNDAY
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Enum Parameter Matching
          Scenario: Test
            Given the following day of the week "MONDAY"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Enum Parameter Matching
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

    Example: enum parameter type is declared in a different package and in its own file
      Given the following enum class:
      """
      package features.enums;

      public enum DayOfWeek {
          MONDAY,
          TUESDAY,
          WEDNESDAY,
          THURSDAY,
          FRIDAY,
          SATURDAY,
          SUNDAY
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import features.enums.DayOfWeek;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Enum Parameter Matching
          Scenario: Test
            Given the following day of the week "MONDAY"
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
         * Feature: Enum Parameter Matching
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

    Example: enum parameter type is declared in a different package and inside another class
      Given the following enum class:
      """
      package features.enums;

      public class TimeConstants {

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
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import features.enums.TimeConstants.DayOfWeek;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Enum Parameter Matching
          Scenario: Test
            Given the following day of the week "MONDAY"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import static features.enums.TimeConstants.DayOfWeek.MONDAY;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Enum Parameter Matching
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

    Example: [counter] inherited method with required name has enum parameter type but not matching constant for our parameter value
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
        Feature: Enum Parameter Matching
          Scenario: Test
            Given the following day of the week "INVALID_DAY"
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
         * Feature: Enum Parameter Matching
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
                 * Given the following day of the week "INVALID_DAY"
                 */
                theFollowingDayOfTheWeek$p1("INVALID_DAY");
            }
        }
        """
  And the compilation error should contain the following text:
    """
    incompatible types: java.lang.String cannot be converted to features.MyFeature.DayOfWeek
    """

  Rule: matching step parameter values against enum type constants is case sensitive
  - if text value specified cannot be matched exactly (case sensitive) against any of the enum constants then
  - the parameter is treated as a regular String and no enum constant substitution is performed which results in a compilation error

    Example: [counter] lowercase value does not match uppercase enum constant declared inside base class
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
        Feature: Case Sensitive Enum Matching
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
         * Feature: Case Sensitive Enum Matching
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

    Example: [counter] lowercase value does not match uppercase enum constant declared in same package
      Given the following enum class:
      """
      package features;

      public enum DayOfWeek {
          MONDAY,
          TUESDAY,
          WEDNESDAY,
          THURSDAY,
          FRIDAY,
          SATURDAY,
          SUNDAY
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Case Sensitive Enum Matching
          Scenario: Test
            Given the following day of the week "Monday"
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
         * Feature: Case Sensitive Enum Matching
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
                 * Given the following day of the week "Monday"
                 */
                theFollowingDayOfTheWeek$p1("Monday");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.DayOfWeek
        """

    Example: [counter] lowercase value does not match uppercase enum constant declared in different package
      Given the following enum class:
      """
      package features.enums;

      public enum DayOfWeek {
          MONDAY,
          TUESDAY,
          WEDNESDAY,
          THURSDAY,
          FRIDAY,
          SATURDAY,
          SUNDAY
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import features.enums.DayOfWeek;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Case Sensitive Enum Matching
          Scenario: Test
            Given the following day of the week "MONDAY "
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
         * Feature: Case Sensitive Enum Matching
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
                 * Given the following day of the week "MONDAY "
                 */
                theFollowingDayOfTheWeek$p1("MONDAY ");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.enums.DayOfWeek
        """

    Example: [counter] lowercase value does not match uppercase enum constant declared inside class in different package
      Given the following enum class:
      """
      package features.enums;

      public class TimeConstants {

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
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import features.enums.TimeConstants.DayOfWeek;

      @Feature2JUnit
      public abstract class MyFeature {

          protected void theFollowingDayOfTheWeek$p1(DayOfWeek dayOfWeek) {
              // Implementation with enum parameter
          }
      }
      """
      And the following feature file:
        """
        Feature: Case Sensitive Enum Matching
          Scenario: Test
            Given the following day of the week "MoNdAy"
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
         * Feature: Case Sensitive Enum Matching
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
                 * Given the following day of the week "MoNdAy"
                 */
                theFollowingDayOfTheWeek$p1("MoNdAy");
            }
        }
        """
      And the compilation error should contain the following text:
        """
        incompatible types: java.lang.String cannot be converted to features.enums.TimeConstants.DayOfWeek
        """


