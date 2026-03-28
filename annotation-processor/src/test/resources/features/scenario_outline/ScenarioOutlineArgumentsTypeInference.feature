Feature: ScenarioOutlineArgumentsTypeInference
  As a test developer using Scenario Outlines with typed data
  I want Examples table columns to be automatically converted to appropriate Java wrapper types
  So that I can use strongly-typed parameters in my test methods without manual type conversion

  - Type inference is performed per column by checking all values in that column
  - Each column in the Examples table is analyzed independently
  - All values in a column must be convertible to a type for that type to be used
  - Type checking follows a specific precedence order: Boolean, Integer, Long, Double, Character, then String
  - The first type that all values in a column can convert to is selected
  - If no wrapper type matches all values, String is used as the default

  Rule: Boolean type conversion
  - A column is typed as Boolean if all values are "true" or "false" (case-insensitive)
  - Generated method parameter uses Java wrapper type: Boolean
  - Boolean conversion has highest precedence in type checking

    Scenario: Column with only boolean values is typed as Boolean
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Boolean Parameters
        Scenario Outline: Testing with boolean flags
          Given user <username> with admin <isAdmin> and active <isActive>
          Examples:
            | username | isAdmin | isActive |
            | alice    | true    | false    |
            | bob      | false   | true     |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Boolean;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Boolean Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithAdmin$p2AndActive$p3(String p1, Boolean p2, Boolean p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          username | isAdmin | isActive
                          alice    | true    | false
                          bob      | false   | true
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with boolean flags")
          public void scenario_1(String username, Boolean isAdmin, Boolean isActive) {
              /*
               * Given user <username> with admin <isAdmin> and active <isActive>
               */
              user$p1WithAdmin$p2AndActive$p3(username, isAdmin, isActive);
          }
      }
      """

    Scenario: Boolean values are case-insensitive
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Boolean Case Insensitive
        Scenario Outline: Testing case insensitivity
          Given flag is <enabled>
          Examples:
            | enabled |
            | True    |
            | FALSE   |
            | true    |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Boolean;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Boolean Case Insensitive
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void flagIs$p1(Boolean p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          enabled
                          True
                          FALSE
                          true
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing case insensitivity")
          public void scenario_1(Boolean enabled) {
              /*
               * Given flag is <enabled>
               */
              flagIs$p1(enabled);
          }
      }
      """

    Scenario: Empty cells in Examples table do not affect type inference for boolean columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell Boolean Type Inference
        Scenario Outline: Testing with empty cells in boolean Examples
          Given user <name> with admin <isAdmin> and premium <isPremium>
          Examples:
            | name  | isAdmin | isPremium |
            | Alice | true    | false     |
            | Bob   |         | true      |
            | Carol | false   |           |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Boolean;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell Boolean Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithAdmin$p2AndPremium$p3(String p1, Boolean p2, Boolean p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | isAdmin | isPremium
                          Alice | true    | false
                          Bob   |         | true
                          Carol | false   |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in boolean Examples")
          public void scenario_1(String name, Boolean isAdmin, Boolean isPremium) {
              /*
               * Given user <name> with admin <isAdmin> and premium <isPremium>
               */
              user$p1WithAdmin$p2AndPremium$p3(name, isAdmin, isPremium);
          }
      }
      """

    Scenario: Column with non-boolean value falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Non-Boolean Fallback
        Scenario Outline: Mixed boolean and non-boolean values
          Given status is <status>
          Examples:
            | status  |
            | true    |
            | false   |
            | pending |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Non-Boolean Fallback
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void statusIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          status
                          true
                          false
                          pending
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Mixed boolean and non-boolean values")
          public void scenario_1(String status) {
              /*
               * Given status is <status>
               */
              statusIs$p1(status);
          }
      }
      """

  Rule: Integer type conversion
  - A column is typed as Integer if all values are valid 32-bit signed integers
  - Values must be parseable by Integer.parseInt() without throwing NumberFormatException
  - Values must be within the range: -2147483648 to 2147483647
  - Generated method parameter uses Java wrapper type: Integer
  - Integer conversion is checked after Boolean

    Scenario: Column with valid integer values is typed as Integer
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Integer Parameters
        Scenario Outline: Testing with integer values
          Given user <username> with age <age> and score <score>
          Examples:
            | username | age | score |
            | alice    | 25  | 100   |
            | bob      | 30  | -50   |
            | carol    | 0   | 0     |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Integer Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithAge$p2AndScore$p3(String p1, Integer p2, Integer p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          username | age | score
                          alice    | 25  | 100
                          bob      | 30  | -50
                          carol    | 0   | 0
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with integer values")
          public void scenario_1(String username, Integer age, Integer score) {
              /*
               * Given user <username> with age <age> and score <score>
               */
              user$p1WithAge$p2AndScore$p3(username, age, score);
          }
      }
      """

    Scenario: Integer at boundary values
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Integer Boundaries
        Scenario Outline: Testing with boundary integer values
          Given value is <value>
          Examples:
            | value       |
            | 2147483647  |
            | -2147483648 |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Integer;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Integer Boundaries
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          2147483647
                          -2147483648
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with boundary integer values")
          public void scenario_1(Integer value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

    Scenario: Column with decimal value falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Non-Integer Fallback
        Scenario Outline: Mixed integer and decimal values
          Given value is <value>
          Examples:
            | value |
            | 10    |
            | 20    |
            | 10.5  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Non-Integer Fallback
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          10
                          20
                          10.5
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Mixed integer and decimal values")
          public void scenario_1(Double value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

    Scenario: Empty cells in Examples table do not affect type inference for integer columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell Type Inference
        Scenario Outline: Testing with empty cells in Examples
          Given user <username> with age <age> and score <score>
          Examples:
            | username | age | score |
            | alice    | 25  | 100   |
            | bob      |     | 85    |
            | carol    | 30  |       |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Integer;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithAge$p2AndScore$p3(String p1, Integer p2, Integer p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          username | age | score
                          alice    | 25  | 100
                          bob      |     | 85
                          carol    | 30  |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in Examples")
          public void scenario_1(String username, Integer age, Integer score) {
              /*
               * Given user <username> with age <age> and score <score>
               */
              user$p1WithAge$p2AndScore$p3(username, age, score);
          }
      }
      """

  Rule: Long type conversion
  - A column is typed as Long if all values are valid 64-bit signed integers
  - Values must be parseable by Long.parseLong() without throwing NumberFormatException
  - This includes values that exceed Integer range but fit within Long range
  - Generated method parameter uses Java wrapper type: Long
  - Long conversion is checked after Integer

    Scenario: Column with values exceeding Integer range is typed as Long
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Long Parameters
        Scenario Outline: Testing with large integer values
          Given account <account> has balance <balance>
          Examples:
            | account | balance      |
            | alice   | 2147483648   |
            | bob     | -2147483649  |
            | carol   | 999999999999 |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Long;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Long Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void account$p1HasBalance$p2(String p1, Long p2) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          account | balance
                          alice   | 2147483648
                          bob     | -2147483649
                          carol   | 999999999999
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with large integer values")
          public void scenario_1(String account, Long balance) {
              /*
               * Given account <account> has balance <balance>
               */
              account$p1HasBalance$p2(account, balance);
          }
      }
      """

    Scenario: Long at boundary values
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Long Boundaries
        Scenario Outline: Testing with boundary long values
          Given value is <value>
          Examples:
            | value                |
            | 9223372036854775807  |
            | -9223372036854775808 |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Long;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Long Boundaries
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(Long p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          9223372036854775807
                          -9223372036854775808
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with boundary long values")
          public void scenario_1(Long value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

    Scenario: Empty cells in Examples table do not affect type inference for long columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell Long Type Inference
        Scenario Outline: Testing with empty cells in long Examples
          Given account <account> has balance <balance> and limit <limit>
          Examples:
            | account | balance      | limit        |
            | alice   | 2147483648   | 9000000000   |
            | bob     |              | -2147483649  |
            | carol   | -9000000000  |              |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Long;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell Long Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void account$p1HasBalance$p2AndLimit$p3(String p1, Long p2, Long p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          account | balance     | limit
                          alice   | 2147483648  | 9000000000
                          bob     |             | -2147483649
                          carol   | -9000000000 |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in long Examples")
          public void scenario_1(String account, Long balance, Long limit) {
              /*
               * Given account <account> has balance <balance> and limit <limit>
               */
              account$p1HasBalance$p2AndLimit$p3(account, balance, limit);
          }
      }
      """

    Scenario: Column with value exceeding Long range falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Non-Long Fallback
        Scenario Outline: Value exceeding long range
          Given value is <value>
          Examples:
            | value                 |
            | 9223372036854775808   |
            | 99999999999999999999  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Non-Long Fallback
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          9223372036854775808
                          99999999999999999999
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Value exceeding long range")
          public void scenario_1(Double value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

  Rule: Double type conversion
  - A column is typed as Double if all values are valid floating-point numbers
  - Values must be parseable by Double.parseDouble() without throwing NumberFormatException
  - This includes integer values, decimal values, and scientific notation
  - Generated method parameter uses Java wrapper type: Double
  - Double conversion is checked after Long

    Scenario: Column with decimal values is typed as Double
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Double Parameters
        Scenario Outline: Testing with decimal values
          Given product <product> with price <price> and tax <tax>
          Examples:
            | product | price | tax  |
            | apple   | 1.99  | 0.15 |
            | banana  | 0.89  | 0.10 |
            | orange  | 2.50  | 0.00 |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Double Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void product$p1WithPrice$p2AndTax$p3(String p1, Double p2, Double p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          product | price | tax
                          apple   | 1.99  | 0.15
                          banana  | 0.89  | 0.10
                          orange  | 2.50  | 0.00
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with decimal values")
          public void scenario_1(String product, Double price, Double tax) {
              /*
               * Given product <product> with price <price> and tax <tax>
               */
              product$p1WithPrice$p2AndTax$p3(product, price, tax);
          }
      }
      """

    Scenario: Column with mixed integer and decimal values is typed as Double
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Mixed Integer and Decimal
        Scenario Outline: Testing with mixed integer-like and decimal values
          Given product <product> with price <price>
          Examples:
            | product | price |
            | apple   | 1.99  |
            | banana  | 2     |
            | orange  | 10    |
            | grape   | 3.50  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Mixed Integer and Decimal
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void product$p1WithPrice$p2(String p1, Double p2) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          product | price
                          apple   | 1.99
                          banana  | 2
                          orange  | 10
                          grape   | 3.50
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with mixed integer-like and decimal values")
          public void scenario_1(String product, Double price) {
              /*
               * Given product <product> with price <price>
               */
              product$p1WithPrice$p2(product, price);
          }
      }
      """

    Scenario: Double with scientific notation
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Double Scientific Notation
        Scenario Outline: Testing with scientific notation values
          Given value is <value>
          Examples:
            | value   |
            | 1.5e10  |
            | 2.3E-5  |
            | -4.7e8  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Double Scientific Notation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          1.5e10
                          2.3E-5
                          -4.7e8
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with scientific notation values")
          public void scenario_1(Double value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

    Scenario: Empty cells in Examples table do not affect type inference for double columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell Double Type Inference
        Scenario Outline: Testing with empty cells in double Examples
          Given product <product> with price <price> and discount <discount>
          Examples:
            | product | price | discount |
            | Widget  | 19.99 | 0.15     |
            | Gadget  |       | 0.20     |
            | Tool    | 29.50 |          |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell Double Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void product$p1WithPrice$p2AndDiscount$p3(String p1, Double p2, Double p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          product | price | discount
                          Widget  | 19.99 | 0.15
                          Gadget  |       | 0.20
                          Tool    | 29.50 |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in double Examples")
          public void scenario_1(String product, Double price, Double discount) {
              /*
               * Given product <product> with price <price> and discount <discount>
               */
              product$p1WithPrice$p2AndDiscount$p3(product, price, discount);
          }
      }
      """

    Scenario: Column with non-numeric value falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Non-Double Fallback
        Scenario Outline: Mixed numeric and text values
          Given value is <value>
          Examples:
            | value |
            | 1.5   |
            | 2.7   |
            | N/A   |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Non-Double Fallback
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          1.5
                          2.7
                          N/A
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Mixed numeric and text values")
          public void scenario_1(String value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

  Rule: Character type conversion
  - A column is typed as Character if all values are exactly one character long
  - Only single-character strings qualify for Character conversion
  - Generated method parameter uses Java wrapper type: Character
  - Character conversion is checked after Double

    Scenario: Column with single-character values is typed as Character
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Character Parameters
        Scenario Outline: Testing with single characters
          Given option <option> with grade <grade> and category <category>
          Examples:
            | option | grade | category |
            | A      | B     | C        |
            | X      | Y     | Z        |
            | 1      | 2     | 3        |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Character;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Character Parameters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void option$p1WithGrade$p2AndCategory$p3(Character p1, Character p2, Character p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          option | grade | category
                          A      | B     | C
                          X      | Y     | Z
                          1      | 2     | 3
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with single characters")
          public void scenario_1(Character option, Character grade, Character category) {
              /*
               * Given option <option> with grade <grade> and category <category>
               */
              option$p1WithGrade$p2AndCategory$p3(option, grade, category);
          }
      }
      """

    Scenario: Empty cells in Examples table do not affect type inference for character columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell Character Type Inference
        Scenario Outline: Testing with empty cells in character Examples
          Given student <name> with grade <grade> and section <section>
          Examples:
            | name  | grade | section |
            | Alice | A     | X       |
            | Bob   |       | Y       |
            | Carol | C     |         |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Character;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell Character Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void student$p1WithGrade$p2AndSection$p3(String p1, Character p2, Character p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | grade | section
                          Alice | A     | X
                          Bob   |       | Y
                          Carol | C     |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in character Examples")
          public void scenario_1(String name, Character grade, Character section) {
              /*
               * Given student <name> with grade <grade> and section <section>
               */
              student$p1WithGrade$p2AndSection$p3(name, grade, section);
          }
      }
      """

    Scenario: Column with multi-character value falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Non-Character Fallback
        Scenario Outline: Mixed single and multi-character values
          Given value is <value>
          Examples:
            | value |
            | A     |
            | B     |
            | AB    |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Non-Character Fallback
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void valueIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          A
                          B
                          AB
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Mixed single and multi-character values")
          public void scenario_1(String value) {
              /*
               * Given value is <value>
               */
              valueIs$p1(value);
          }
      }
      """

  Rule: String type as fallback
  - A column is typed as String if no wrapper type conversion succeeds for all values
  - String is the default type when values are heterogeneous or don't match any wrapper type pattern
  - Generated method parameter uses Java type: String
  - String conversion always succeeds and serves as the ultimate fallback

    Scenario: Column with heterogeneous values uses String type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Mixed Types
        Scenario Outline: Testing with mixed types
          Given input is <input>
          Examples:
            | input  |
            | 123    |
            | true   |
            | hello  |
            | 45.6   |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Mixed Types
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void inputIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          input
                          123
                          true
                          hello
                          45.6
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with mixed types")
          public void scenario_1(String input) {
              /*
               * Given input is <input>
               */
              inputIs$p1(input);
          }
      }
      """

    Scenario: Empty cells in Examples table are handled as empty strings for string columns
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Empty Cell String Type Inference
        Scenario Outline: Testing with empty cells in string Examples
          Given user <name> with status <status> and role <role>
          Examples:
            | name  | status   | role  |
            | Alice | active   | admin |
            | Bob   |          | user  |
            | Carol | inactive |       |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Empty Cell String Type Inference
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithStatus$p2AndRole$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | status   | role
                          Alice | active   | admin
                          Bob   |          | user
                          Carol | inactive |
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with empty cells in string Examples")
          public void scenario_1(String name, String status, String role) {
              /*
               * Given user <name> with status <status> and role <role>
               */
              user$p1WithStatus$p2AndRole$p3(name, status, role);
          }
      }
      """

    Scenario: Column with all empty cells defaults to String type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: All Empty Cells Default to String
        Scenario Outline: Testing with all empty cells in a column
          Given user <name> with value <value> and status <status>
          Examples:
            | name  | value | status |
            | Alice |       | active |
            | Bob   |       | idle   |
            | Carol |       | closed |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: All Empty Cells Default to String
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithValue$p2AndStatus$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | value | status
                          Alice |       | active
                          Bob   |       | idle
                          Carol |       | closed
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with all empty cells in a column")
          public void scenario_1(String name, String value, String status) {
              /*
               * Given user <name> with value <value> and status <status>
               */
              user$p1WithValue$p2AndStatus$p3(name, value, status);
          }
      }
      """

  Rule: Type inference works independently per column in Examples table
  - Each column is analyzed and typed independently
  - Different columns can have different types in the same Examples table
  - The generated method signature includes the appropriate type for each parameter

    Scenario: Mixed typed columns in same Examples table
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Multiple Column Types
        Scenario Outline: Testing with different column types
          Given user <name> with age <age> and active <active> and score <score> and grade <grade>
          Examples:
            | name  | age | active | score | grade |
            | alice | 25  | true   | 95.5  | A     |
            | bob   | 30  | false  | 87.3  | B     |
            | carol | 28  | true   | 92.0  | A     |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Multiple Column Types
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1WithAge$p2AndActive$p3AndScore$p4AndGrade$p5(String p1, Integer p2,
                  Boolean p3, Double p4, Character p5) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          name  | age | active | score | grade
                          alice | 25  | true   | 95.5  | A
                          bob   | 30  | false  | 87.3  | B
                          carol | 28  | true   | 92.0  | A
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Testing with different column types")
          public void scenario_1(String name, Integer age, Boolean active, Double score,
                  Character grade) {
              /*
               * Given user <name> with age <age> and active <active> and score <score> and grade <grade>
               */
              user$p1WithAge$p2AndActive$p3AndScore$p4AndGrade$p5(name, age, active, score, grade);
          }
      }
      """




