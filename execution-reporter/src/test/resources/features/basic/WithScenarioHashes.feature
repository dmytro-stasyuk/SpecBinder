Feature: StepLevelScenarioHashEnabled
  As a CI/CD pipeline maintainer integrating SpecBinder reports with external tools,
  I want the JSON report to include a stable scenario hash for each plain scenario
    when the emitScenarioHash option is enabled,
  So that I can uniquely identify and track individual scenarios across test runs

  Rule: plain scenarios include scenarioHash in the report when emitScenarioHash was enabled for the class generation

    Scenario: Plain scenario carries scenarioHash from the @ScenarioHash annotation
      Given a feature file under path "fixtures/step-level-hash-plain.feature" with the following content:
        """
        Feature: StepLevelHashPlain

          Scenario: Plain scenario
            Given a precondition holds
            When an event fires
            Then an outcome is observed
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/step-level-hash-plain.feature")
        @Gherkin2JUnitOptions(emitScenarioHash = true)
        @ExtendWith(SpecBinderReporter.class)
        public abstract class StepLevelHashPlainFeature {

            public void aPreconditionHolds() { }
            public void anEventFires() { }
            public void anOutcomeIsObserved() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.ScenarioHash;
        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("StepLevelHashPlain")
        @SourceFilePath("fixtures/step-level-hash-plain.feature")
        public class StepLevelHashPlainTest extends StepLevelHashPlainFeature {

            @Test
            @SourceLine(3)
            @ScenarioHash("aaaa1111bbbb2222cccc3333dddd4444eeee5555ffff66667777888899990000")
            @DisplayName("Scenario: Plain scenario")
            public void scenario_1() {
                aPreconditionHolds();
                anEventFires();
                anOutcomeIsObserved();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/step-level-hash-plain.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/step-level-hash-plain.feature",
          "displayName" : "StepLevelHashPlain",
          "generatedClass" : "fixtures.StepLevelHashPlainTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 1,
            "failed" : 0,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.StepLevelHashPlainTest#scenario_1",
            "displayName" : "Scenario: Plain scenario",
            "status" : "passed",
            "sourceLine" : 3,
            "scenarioHash" : "aaaa1111bbbb2222cccc3333dddd4444eeee5555ffff66667777888899990000",
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aPreconditionHolds",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "anEventFires",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "anOutcomeIsObserved",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """
