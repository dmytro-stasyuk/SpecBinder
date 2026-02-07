Feature: SimpleParameterTypeInference
  As a test developer using Gherkin steps with parameters
  I want step method parameters to be automatically typed based on the parameter values in the step text
  So that I can use strongly-typed parameters in my step implementations without manual type conversion

  Rule: Type inference is performed based on parameter values in step text
  - Each parameter value in quoted text is analyzed to determine its type
  - Type checking follows precedence order: Boolean, Integer, Long, Double, Character, then String
  - The first type that the value can convert to is selected
  - If no wrapper type matches, String is used as the default

  Rule: Boolean type conversion for step parameters
  - A parameter is typed as Boolean if the value is "true" or "false" (case-insensitive)
  - Generated step method parameter uses Java wrapper type: Boolean
  - Boolean conversion has highest precedence in type checking

    Scenario: Step with boolean parameter generates method with Boolean parameter
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
      Feature: Boolean Step Parameters
        Scenario: Testing with boolean value
          Given user is active "true"
          When user is verified "false"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Boolean Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserIsActive$p1(Boolean p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenUserIsVerified$p1(Boolean p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with boolean value")
          public void scenario_1() {
              /*
               * Given user is active "true"
               */
              givenUserIsActive$p1(true);
              /*
               * When user is verified "false"
               */
              whenUserIsVerified$p1(false);
          }
      }
      """

  Rule: Integer type conversion for step parameters
  - A parameter is typed as Integer if the value is a valid 32-bit signed integer
  - Values must be parseable by Integer.parseInt() without throwing NumberFormatException
  - Generated step method parameter uses Java wrapper type: Integer
  - Integer conversion is checked after Boolean

    Scenario: Step with integer parameter generates method with Integer parameter
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
      Feature: Integer Step Parameters
        Scenario: Testing with integer values
          Given user has age "25"
          When user has score "100"
          Then user has balance "-50"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Integer Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserHasAge$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenUserHasScore$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenUserHasBalance$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with integer values")
          public void scenario_1() {
              /*
               * Given user has age "25"
               */
              givenUserHasAge$p1(25);
              /*
               * When user has score "100"
               */
              whenUserHasScore$p1(100);
              /*
               * Then user has balance "-50"
               */
              thenUserHasBalance$p1(-50);
          }
      }
      """

  Rule: Long type conversion for step parameters
  - A parameter is typed as Long if the value is a valid 64-bit signed integer
  - This includes values that exceed Integer range but fit within Long range
  - Generated step method parameter uses Java wrapper type: Long
  - Long conversion is checked after Integer

    Scenario: Step with long parameter generates method with Long parameter
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
      Feature: Long Step Parameters
        Scenario: Testing with large integer values
          Given account has balance "2147483648"
          When transaction amount is "-2147483649"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Long;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Long Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenAccountHasBalance$p1(Long p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenTransactionAmountIs$p1(Long p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with large integer values")
          public void scenario_1() {
              /*
               * Given account has balance "2147483648"
               */
              givenAccountHasBalance$p1(2147483648L);
              /*
               * When transaction amount is "-2147483649"
               */
              whenTransactionAmountIs$p1(-2147483649L);
          }
      }
      """

  Rule: Double type conversion for step parameters
  - A parameter is typed as Double if the value is a valid floating-point number
  - This includes integer values, decimal values, and scientific notation
  - Generated step method parameter uses Java wrapper type: Double
  - Double conversion is checked after Long

    Scenario: Step with double parameter generates method with Double parameter
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
      Feature: Double Step Parameters
        Scenario: Testing with decimal values
          Given product has price "19.99"
          When discount is "0.15"
          Then total is "16.99"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Double Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenProductHasPrice$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenDiscountIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenTotalIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with decimal values")
          public void scenario_1() {
              /*
               * Given product has price "19.99"
               */
              givenProductHasPrice$p1(19.99);
              /*
               * When discount is "0.15"
               */
              whenDiscountIs$p1(0.15);
              /*
               * Then total is "16.99"
               */
              thenTotalIs$p1(16.99);
          }
      }
      """

  Rule: Character type conversion for step parameters
  - A parameter is typed as Character if the value is exactly one character long
  - Only single-character strings qualify for Character conversion
  - Generated step method parameter uses Java wrapper type: Character
  - Character conversion is checked after Double

    Scenario: Step with single-character parameter generates method with Character parameter
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
      Feature: Character Step Parameters
        Scenario: Testing with single characters
          Given user has grade "A"
          When option is "X"
          Then category is "B"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Character;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Character Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserHasGrade$p1(Character p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenOptionIs$p1(Character p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenCategoryIs$p1(Character p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with single characters")
          public void scenario_1() {
              /*
               * Given user has grade "A"
               */
              givenUserHasGrade$p1('A');
              /*
               * When option is "X"
               */
              whenOptionIs$p1('X');
              /*
               * Then category is "B"
               */
              thenCategoryIs$p1('B');
          }
      }
      """

    Scenario: Step with multi-character parameter falls back to String
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
      Feature: Multi-Character Falls Back to String
        Scenario: Testing with multi-character value
          Given user has grade "AB"
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
       * Feature: Multi-Character Falls Back to String
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserHasGrade$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with multi-character value")
          public void scenario_1() {
              /*
               * Given user has grade "AB"
               */
              givenUserHasGrade$p1("AB");
          }
      }
      """

  Rule: String type as fallback for step parameters
  - A parameter is typed as String if no wrapper type conversion succeeds
  - String is the default type when values don't match any wrapper type pattern
  - String conversion always succeeds and serves as the ultimate fallback

    Scenario: Step with non-convertible parameter generates method with String parameter
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
      Feature: String Step Parameters
        Scenario: Testing with text values
          Given user name is "Alice"
          When status is "active"
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
       * Feature: String Step Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserNameIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenStatusIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with text values")
          public void scenario_1() {
              /*
               * Given user name is "Alice"
               */
              givenUserNameIs$p1("Alice");
              /*
               * When status is "active"
               */
              whenStatusIs$p1("active");
          }
      }
      """

  Rule: Method overloading when same step called with different parameter types
  - When the same step is called with parameters that convert to different types, generate overloaded methods
  - Each overloaded method has parameters matching the types of the specific invocation
  - The test scenario calls the appropriate overloaded method for each step invocation

    Scenario: Same step with different parameter types generates overloaded methods
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
      Feature: Overloaded Step Methods
        Scenario: Testing with different types for same step
          Given value is "42"
          When value is "3.14"
          Then value is "hello"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Double;
      import java.lang.Integer;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Overloaded Step Methods
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenValueIs$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenValueIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenValueIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with different types for same step")
          public void scenario_1() {
              /*
               * Given value is "42"
               */
              givenValueIs$p1(42);
              /*
               * When value is "3.14"
               */
              whenValueIs$p1(3.14);
              /*
               * Then value is "hello"
               */
              thenValueIs$p1("hello");
          }
      }
      """

    Scenario: Same step pattern with different values of same type generates single method
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
      Feature: Single Method for Same Type
        Scenario: Testing with multiple integer values
          Given user has age "25"
          When user has age "30"
          Then user has age "35"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Integer;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Single Method for Same Type
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUserHasAge$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenUserHasAge$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenUserHasAge$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with multiple integer values")
          public void scenario_1() {
              /*
               * Given user has age "25"
               */
              givenUserHasAge$p1(25);
              /*
               * When user has age "30"
               */
              whenUserHasAge$p1(30);
              /*
               * Then user has age "35"
               */
              thenUserHasAge$p1(35);
          }
      }
      """

  Rule: Multiple parameters in same step can have different types
  - Each parameter in a step is analyzed independently
  - Different parameters can have different inferred types
  - The generated method signature includes the appropriate type for each parameter

    Scenario: Step with multiple parameters of different types
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
      Feature: Mixed Parameter Types
        Scenario: Testing with multiple parameters
          Given user "Alice" has age "25" and is active "true" with balance "1000.50" and grade "A"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.Boolean;
      import java.lang.Character;
      import java.lang.Double;
      import java.lang.Integer;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Mixed Parameter Types
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenUser$p1HasAge$p2AndIsActive$p3WithBalance$p4AndGrade$p5(String p1, Integer p2,
                  Boolean p3, Double p4, Character p5) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Testing with multiple parameters")
          public void scenario_1() {
              /*
               * Given user "Alice" has age "25" and is active "true" with balance "1000.50" and grade "A"
               */
              givenUser$p1HasAge$p2AndIsActive$p3WithBalance$p4AndGrade$p5("Alice", 25, true, 1000.50, 'A');
          }
      }
      """
