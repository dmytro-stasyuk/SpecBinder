Feature: StepLevelNoExtension

  As a developer using SpecBinder without the execution reporter
  I want no JSON report file to be produced when @ExtendWith(SpecBinderReporter.class) is absent
  So that the reporter remains strictly opt-in and does not interfere with projects that only use code generation

  Scenario: A marker class without @ExtendWith produces no JSON file
    Given a feature file under path "fixtures/no-extension.feature" with the following content:
      """
      Feature: NoExtension

        Scenario: Without the extension nothing is reported
          Given a precondition holds
      """
    And the following SpecBinder marker class:
      """
      package fixtures;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit("fixtures/no-extension.feature")
      public abstract class NoExtensionFeature {

          public void aPreconditionHolds() { }
      }
      """
    And the following SpecBinder-generated test class:
      """
      package fixtures;

      import dev.specbinder.annotations.output.SourceFilePath;
      import dev.specbinder.annotations.output.SourceLine;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Test;

      @DisplayName("NoExtension")
      @SourceFilePath("fixtures/no-extension.feature")
      public class NoExtensionTest extends NoExtensionFeature {

          @Test
          @SourceLine(3)
          @DisplayName("Scenario: Without the extension nothing is reported")
          public void scenario_1() {
              aPreconditionHolds();
          }
      }
      """
    When the test class is executed
    Then no report file should be produced at "fixtures/no-extension.feature.json"
