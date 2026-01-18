Feature: GherkinComments
  As a developer
  I want to verify that Gherkin comments (lines starting with #) are ignored by the generator
  So that comments in feature files do not appear in generated test code

  Rule: Gherkin comments (lines starting with #) are ignored in all locations and do not appear in generated code

    Scenario: Feature file with comments in all possible locations
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
      # Comment before feature
      # Multiple comments before feature
      Feature: feature with comprehensive comments
        # Comment after feature name

        # Comment before background
        Background:
          # Comment before background step
          Given a background step
          # Comment between background steps
          And another background step

        # Comment before rule
        Rule: test rule
          # Comment after rule name

          # Comment before scenario in rule
          Scenario: scenario in rule
            # Comment before step in rule scenario
            Given a rule step
            # Comment between steps
            When another rule step

        # Comment before feature-level scenario
        Scenario: first scenario
          # Comment before step
          Given a step
          # Comment between steps
          When another step
          # Comment between steps
          Then final step

        # Comment between scenarios
        # Multiple comments between scenarios

        Scenario: second scenario
          Given yet another step

        # Comment before scenario outline
        Scenario Outline: parameterized scenario
          # Comment before outline step
          Given I have <value>
          # Comment in outline
          When I use <value>

          # Comment before examples
          Examples:
            # Comment in examples section
            | value |
            | test  |
            # Comment after examples row
            | data  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestInfo;
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: feature with comprehensive comments
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void givenABackgroundStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenAnotherBackgroundStep() {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given a background step
               */
              givenABackgroundStep();
              /*
               * And another background step
               */
              givenAnotherBackgroundStep();
          }

          public void givenARuleStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenAnotherRuleStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenAStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenAnotherStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenFinalStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenYetAnotherStep() {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenIHave$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenIUse$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: test rule")
          public class Rule_1 {
              @Test
              @Order(1)
              @DisplayName("Scenario: scenario in rule")
              public void scenario_1() {
                  /*
                   * Given a rule step
                   */
                  givenARuleStep();
                  /*
                   * When another rule step
                   */
                  whenAnotherRuleStep();
              }

              @Test
              @Order(2)
              @DisplayName("Scenario: first scenario")
              public void scenario_2() {
                  /*
                   * Given a step
                   */
                  givenAStep();
                  /*
                   * When another step
                   */
                  whenAnotherStep();
                  /*
                   * Then final step
                   */
                  thenFinalStep();
              }

              @Test
              @Order(3)
              @DisplayName("Scenario: second scenario")
              public void scenario_3() {
                  /*
                   * Given yet another step
                   */
                  givenYetAnotherStep();
              }

              @ParameterizedTest(
                      name = "Example {index}: [{arguments}]"
              )
              @CsvSource(
                      useHeadersInDisplayName = true,
                      delimiter = '|',
                      textBlock = \"\"\"
                              value
                              test
                              data
                              \"\"\"
              )
              @Order(4)
              @DisplayName("Scenario Outline: parameterized scenario")
              public void scenario_4(String value) {
                  /*
                   * Given I have <value>
                   */
                  givenIHave$p1(value);
                  /*
                   * When I use <value>
                   */
                  whenIUse$p1(value);
              }
          }
      }
      """
