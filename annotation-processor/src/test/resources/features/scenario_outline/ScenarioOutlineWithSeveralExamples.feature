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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
          Examples:
            | first | second | combined    |
            | foo   | bar    | foobar      |
            | test  | data   | testdata    |
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
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first | second | combined
                          foo   | bar    | foobar
                          test  | data   | testdata
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
          Examples:
            | first | second | output   |
            | foo   | bar    | foobar   |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected columns [first, second, combined], but found [first, second, output] in Examples section 2 (columns are in different order or have different names).
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
          Examples:
            | first | second |
            | foo   | bar    |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected 3 columns [first, second, combined], but found 2 columns [first, second] in Examples section 2.
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
      Feature: StringConcatenation
        Scenario Outline: Concatenating words
          Given I have <first> and <second>
          When I concatenate them
          Then the result is <combined>
          Examples:
            | first | second | combined    |
            | hello | world  | helloworld  |
          Examples:
            | combined | first | second |
            | foobar   | foo   | bar    |
      """
      When the generator is run
      Then the generator should report an error:
      """
      ERROR: All Examples sections must have identical header columns in the same order. Expected columns [first, second, combined], but found [combined, first, second] in Examples section 2 (columns are in different order or have different names).
      """



