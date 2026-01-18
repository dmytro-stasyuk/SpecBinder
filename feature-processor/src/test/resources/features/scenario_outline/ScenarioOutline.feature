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

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Calculator
        Scenario Outline: Adding numbers
          Given I have <a> and <b>
          When I add them
          Then the result is <sum>
          Examples:
            | a | b | sum |
            | 1 | 2 | 3   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Calculator
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenIHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenIAddThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenTheResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a | b | sum
                          1 | 2 | 3
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Adding numbers")
          public void scenario_1(String a, String b, String sum) {
              /*
               * Given I have <a> and <b>
               */
              givenIHave$p1And$p2(a, b);
              /*
               * When I add them
               */
              whenIAddThem();
              /*
               * Then the result is <sum>
               */
              thenTheResultIs$p1(sum);
          }
      }
      """

  Rule: Examples table is formatted with aligned columns using pipe separators even if source table is not aligned

    Scenario: with examples table columns misaligned
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

      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void given$p1And$p2And$p3(String p1, String p2, String p3) {
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
              given$p1And$p2And$p3(shortValue, mediumValue, veryLongValue);
          }
      }
      """

  Rule: the "Scenario Template" keyword (synonym for "Scenario Outline") should be mapped to a test method similarly to Scenario Outline

    Scenario: A basic scenario template generates @ParameterizedTest method
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
      Feature: Calculator
        Scenario Template: Adding numbers
          Given I have <a> and <b>
          When I add them
          Then the result is <sum>
          Examples:
            | a | b | sum |
            | 1 | 2 | 3   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Calculator
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenIHave$p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenIAddThem() {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenTheResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a | b | sum
                          1 | 2 | 3
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Template: Adding numbers")
          public void scenario_1(String a, String b, String sum) {
              /*
               * Given I have <a> and <b>
               */
              givenIHave$p1And$p2(a, b);
              /*
               * When I add them
               */
              whenIAddThem();
              /*
               * Then the result is <sum>
               */
              thenTheResultIs$p1(sum);
          }
      }
      """
