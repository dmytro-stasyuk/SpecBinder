Feature: ScenarioOutline
  As a test developer using Gherkin
  I want Scenario Outlines to be converted to parameterized JUnit tests
  So that I can write data-driven tests with Examples tables

  Rule: Scenario Outline is converted to a method with @ParameterizedTest annotation instead of @Test
  - Examples table is converted to @CsvSource annotation with pipe-delimited data
  - @ParameterizedTest name format is "Example {index}: [{arguments}]"
  - Examples table column headers become method parameters with String type

    Scenario: A basic scenario outline generates @ParameterizedTest method
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
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
       * Feature: StringConcatenation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void iConcatenateThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second | combined
                          hello | world  | helloworld
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Concatenating words")
          public void scenario_1(String first, String second, String combined) {
              /*
               * Given I have <first> and <second>
               */
              iHave$p1And$p2(first, second);
              /*
               * When I concatenate them
               */
              iConcatenateThem();
              /*
               * Then the result is <combined>
               */
              theResultIs$p1(combined);
          }
      }
      """

    Scenario: Examples table with a title
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples: Valid combinations
            | first | second | combined    |
            | hello | world  | helloworld  |
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
       * Feature: StringConcatenation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void iConcatenateThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          /*
           * Examples: Valid combinations
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second | combined
                          hello | world  | helloworld
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Concatenating words")
          public void scenario_1(String first, String second, String combined) {
              /*
               * Given I have <first> and <second>
               */
              iHave$p1And$p2(first, second);
              /*
               * When I concatenate them
               */
              iConcatenateThem();
              /*
               * Then the result is <combined>
               */
              theResultIs$p1(combined);
          }
      }
      """

    Scenario: Examples table with a title and description
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples: Valid combinations
            These examples cover the most common
            string concatenation scenarios
            | first | second | combined    |
            | hello | world  | helloworld  |
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
       * Feature: StringConcatenation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void iConcatenateThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          /*
           * Examples: Valid combinations
           *   These examples cover the most common
           *   string concatenation scenarios
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second | combined
                          hello | world  | helloworld
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Concatenating words")
          public void scenario_1(String first, String second, String combined) {
              /*
               * Given I have <first> and <second>
               */
              iHave$p1And$p2(first, second);
              /*
               * When I concatenate them
               */
              iConcatenateThem();
              /*
               * Then the result is <combined>
               */
              theResultIs$p1(combined);
          }
      }
      """

  Rule: Examples table is formatted with aligned columns using pipe separators even if source table is not aligned

    Scenario: with examples table columns misaligned
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
      Feature: Formatting
        Scenario Outline: Mixed lengths
          Given <shortValue> and <mediumValue> and <veryLongValue>
          Examples:
            | shortValue | mediumValue | veryLongValue      |
           | x               | medium      |     this is very long  |
                | abc          |  test        | y                     |
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
       * Feature: Formatting
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          shortValue | mediumValue | veryLongValue
                          x          | medium      | this is very long
                          abc        | test        | y
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Mixed lengths")
          public void scenario_1(String shortValue, String mediumValue, String veryLongValue) {
              /*
               * Given <shortValue> and <mediumValue> and <veryLongValue>
               */
              $p1And$p2And$p3(shortValue, mediumValue, veryLongValue);
          }
      }
      """

  Rule: the "Scenario Template" keyword (synonym for "Scenario Outline") should be mapped to a test method similarly to Scenario Outline

    Scenario: A basic scenario template generates @ParameterizedTest method
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
      Feature: StringConcatenation
        Scenario Template: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
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
       * Feature: StringConcatenation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void iConcatenateThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second | combined
                          hello | world  | helloworld
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Template: Concatenating words")
          public void scenario_1(String first, String second, String combined) {
              /*
               * Given I have <first> and <second>
               */
              iHave$p1And$p2(first, second);
              /*
               * When I concatenate them
               */
              iConcatenateThem();
              /*
               * Then the result is <combined>
               */
              theResultIs$p1(combined);
          }
      }
      """
