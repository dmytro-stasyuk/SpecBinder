Feature: ScenarioOutline
  As a test developer using Gherkin
  I want Scenario Outlines with several Examples sections to be mapped to repeatable @CSVSource annotations
  So that I can use more than one Examples section in my Scenario Outlines and still have them properly converted to parameterized tests

  Rule: Several Examples sections in a Scenario Outline are mapped to repeatable @CSVSource annotations

    Scenario: Scenario Outline with two Examples sections
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
          Examples:
            | a | b | sum |
            | 3 | 6 | 9   |
            | 4 | 8 | 12  |
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
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a | b | sum
                          3 | 6 | 9
                          4 | 8 | 12
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

  Rule: Examples sections with different columns should report an error

    Scenario: Scenario Outline with Examples sections having different columns
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
          Examples:
            | a | b | result |
            | 3 | 6 | 9      |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected columns [a, b, sum], but found [a, b, result] in Examples section 2 (columns are in different order or have different names).
      """

    Scenario: Scenario Outline with Examples sections having different number of columns
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
          Examples:
            | a | b |
            | 3 | 6 |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected 3 columns [a, b, sum], but found 2 columns [a, b] in Examples section 2.
      """

    Scenario: Scenario Outline with Examples sections having same columns but in different order
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
          Examples:
            | sum | a | b |
            | 9   | 3 | 6 |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected columns [a, b, sum], but found [sum, a, b] in Examples section 2 (columns are in different order or have different names).
      """



