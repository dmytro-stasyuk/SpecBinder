Feature: ScenarioOutlineTags
  As a test developer using Gherkin
  I want tags on Scenario Outlines and Examples to be converted to JUnit @Tag annotations
  So that I can filter and selectively execute parameterized test methods

  Rule: Tags on a Scenario Outline are converted to JUnit @Tag annotations on the parameterized test method

    Scenario: Scenario Outline with tags and no tags on Examples
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
      Feature: TaggedOutline

        @smoke
        Scenario Outline: Validate input
          Given I enter <input>
          Then the result is <output>
          Examples:
            | input | output |
            | hello | HELLO  |
            | world | WORLD  |
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: TaggedOutline
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iEnter$p1(String p1) {
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
                          input | output
                          hello | HELLO
                          world | WORLD
                          \"\"\"
          )
          @Order(1)
          @Tag("smoke")
          @DisplayName("Scenario Outline: Validate input")
          public void scenario_1(String input, String output) {
              /*
               * Given I enter <input>
               */
              iEnter$p1(input);
              /*
               * Then the result is <output>
               */
              theResultIs$p1(output);
          }
      }
      """

  Rule: Tags on Examples are combined with Scenario Outline tags into a single set of @Tag annotations

    Scenario: Scenario Outline with tags on both outline and Examples
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
      Feature: CombinedTags

        @regression
        Scenario Outline: Process order
          Given I place an order for <item>
          Then the status is <status>
          @smoke
          Examples:
            | item | status    |
            | book | confirmed |
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: CombinedTags
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iPlaceAnOrderFor$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void theStatusIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          item | status
                          book | confirmed
                          \"\"\"
          )
          @Order(1)
          @Tags({
                  @Tag("regression"),
                  @Tag("smoke")
          })
          @DisplayName("Scenario Outline: Process order")
          public void scenario_1(String item, String status) {
              /*
               * Given I place an order for <item>
               */
              iPlaceAnOrderFor$p1(item);
              /*
               * Then the status is <status>
               */
              theStatusIs$p1(status);
          }
      }
      """

  Rule: Tags from multiple Examples sections are all combined with Scenario Outline tags into one set of @Tag annotations
  - Duplicate tags across Examples sections are included only once

    Scenario: Scenario Outline with multiple tagged Examples sections
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
      Feature: MultiExamplesTags

        @regression
        Scenario Outline: Validate calculation
          Given I calculate <a> plus <b>
          Then the result is <sum>
          @smoke
          Examples: Small numbers
            | a   | b   | sum  |
            | one | two | onetwo |
          @nightly @slow
          Examples: Large numbers
            | a     | b     | sum       |
            | alpha | bravo | alphabravo |
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: MultiExamplesTags
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iCalculate$p1Plus$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void theResultIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          /*
           * Examples: Small numbers
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a   | b   | sum
                          one | two | onetwo
                          \"\"\"
          )
          /*
           * Examples: Large numbers
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a     | b     | sum
                          alpha | bravo | alphabravo
                          \"\"\"
          )
          @Order(1)
          @Tags({
                  @Tag("regression"),
                  @Tag("smoke"),
                  @Tag("nightly"),
                  @Tag("slow")
          })
          @DisplayName("Scenario Outline: Validate calculation")
          public void scenario_1(String a, String b, String sum) {
              /*
               * Given I calculate <a> plus <b>
               */
              iCalculate$p1Plus$p2(a, b);
              /*
               * Then the result is <sum>
               */
              theResultIs$p1(sum);
          }
      }
      """

    Scenario: Duplicate tags across Scenario Outline and Examples are deduplicated
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
      Feature: DeduplicatedTags

        @smoke @regression
        Scenario Outline: Check value
          Given I check <value>
          Then it is valid
          @smoke
          Examples: First set
            | value |
            | abc   |
          @regression @nightly
          Examples: Second set
            | value |
            | xyz   |
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: DeduplicatedTags
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void iCheck$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void itIsValid() {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          /*
           * Examples: First set
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          abc
                          \"\"\"
          )
          /*
           * Examples: Second set
           */
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value
                          xyz
                          \"\"\"
          )
          @Order(1)
          @Tags({
                  @Tag("smoke"),
                  @Tag("regression"),
                  @Tag("nightly")
          })
          @DisplayName("Scenario Outline: Check value")
          public void scenario_1(String value) {
              /*
               * Given I check <value>
               */
              iCheck$p1(value);
              /*
               * Then it is valid
               */
              itIsValid();
          }
      }
      """
