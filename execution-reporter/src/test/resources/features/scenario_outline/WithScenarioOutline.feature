Feature: WithScenarioOutline
  As a developer or CI pipeline consuming SpecBinder execution reports
  I want each Scenario Outline example row to carry its own step-by-step trace and optional hash identifiers at the template and row level
  So that I can pinpoint exactly which example row failed and at which step, and track outline templates and individual rows across test runs

  Rule: each row carries its own steps[] reflecting failures and skips at different positions

    Scenario: Outline rows carry per-row steps[] arrays
      Given a feature file under path "fixtures/step-level-outline.feature" with the following content:
        """
        Feature: StepLevelOutline

          Scenario Outline: Failures land at different positions
            Given a precondition holds
            When the event "<event>" fires
            Then the "<outcome>" outcome is observed

            Examples:
              | event | outcome |
              | alpha | success |
              | beta  | pass    |
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/step-level-outline.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class StepLevelOutlineFeature {

            public void aPreconditionHolds() { }
            public void theEventFires(String event) {
                if ("alpha".equals(event)) {
                    throw new AssertionError("alpha event failed to fire");
                }
            }
            public void theOutcomeIsObserved(String outcome) {
                throw new AssertionError("outcome " + outcome + " was not observed");
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        @DisplayName("StepLevelOutline")
        @SourceFilePath("fixtures/step-level-outline.feature")
        public class StepLevelOutlineTest extends StepLevelOutlineFeature {

            @ParameterizedTest(name = "Example {index}: [{arguments}]")
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            event | outcome
                            alpha | success
                            beta  | pass
                            \"\"\")
            @SourceLine(3)
            @DisplayName("Scenario Outline: Failures land at different positions")
            public void scenario_1(String event, String outcome) {
                aPreconditionHolds();
                theEventFires(event);
                theOutcomeIsObserved(outcome);
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/step-level-outline.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/step-level-outline.feature",
          "displayName" : "StepLevelOutline",
          "generatedClass" : "fixtures.StepLevelOutlineTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 0,
            "failed" : 2,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenarioOutline",
            "id" : "fixtures.StepLevelOutlineTest#scenario_1",
            "displayName" : "Scenario Outline: Failures land at different positions",
            "sourceLine" : 3,
            "totalDurationMs" : 0,
            "examples" : [ {
              "displayName" : "Example 1: [event = alpha, outcome = success]",
              "status" : "failed",
              "sourceLine" : 3,
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "examplesRow" : {
                "event" : "alpha",
                "outcome" : "success"
              },
              "steps" : [ {
                "methodName" : "aPreconditionHolds",
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theEventFires",
                "arguments" : [ "alpha" ],
                "status" : "failed",
                "startedAt" : "<ts>",
                "durationMs" : 0,
                "error" : {
                  "type" : "java.lang.AssertionError",
                  "message" : "alpha event failed to fire",
                  "stackTrace" : "<stackTrace>"
                }
              }, {
                "methodName" : "theOutcomeIsObserved",
                "status" : "skipped"
              } ]
            }, {
              "displayName" : "Example 2: [event = beta, outcome = pass]",
              "status" : "failed",
              "sourceLine" : 3,
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "examplesRow" : {
                "event" : "beta",
                "outcome" : "pass"
              },
              "steps" : [ {
                "methodName" : "aPreconditionHolds",
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theEventFires",
                "arguments" : [ "beta" ],
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theOutcomeIsObserved",
                "arguments" : [ "pass" ],
                "status" : "failed",
                "startedAt" : "<ts>",
                "durationMs" : 0,
                "error" : {
                  "type" : "java.lang.AssertionError",
                  "message" : "outcome pass was not observed",
                  "stackTrace" : "<stackTrace>"
                }
              } ]
            } ]
          } ]
        }
        """

  Rule: scenario outlines include scenarioHash at the template level and rowHash for each example row

    Scenario: Outline carries scenarioHash on the template and rowHash on each example row
      Given a feature file under path "fixtures/step-level-hash-outline.feature" with the following content:
        """
        Feature: StepLevelHashOutline

          Scenario Outline: Outline scenario
            Given a precondition holds
            When the event "<event>" fires
            Then the "<outcome>" outcome is observed

            Examples:
              | event | outcome |
              | alpha | success |
              | beta  | pass    |
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/step-level-hash-outline.feature")
        @Gherkin2JUnitOptions(emitScenarioHash = true)
        @ExtendWith(SpecBinderReporter.class)
        public abstract class StepLevelHashOutlineFeature {

            public void aPreconditionHolds() { }
            public void theEventFires(String event) { }
            public void theOutcomeIsObserved(String outcome) { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.ScenarioHash;
        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        @DisplayName("StepLevelHashOutline")
        @SourceFilePath("fixtures/step-level-hash-outline.feature")
        public class StepLevelHashOutlineTest extends StepLevelHashOutlineFeature {

            @ParameterizedTest(name = "Example {index}: [{arguments}]")
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            event | outcome
                            alpha | success
                            beta  | pass
                            \"\"\")
            @SourceLine(3)
            @ScenarioHash("11112222333344445555666677778888aaaabbbbccccddddeeeeffff00009999")
            @DisplayName("Scenario Outline: Outline scenario")
            public void scenario_1(String event, String outcome) {
                aPreconditionHolds();
                theEventFires(event);
                theOutcomeIsObserved(outcome);
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/step-level-hash-outline.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/step-level-hash-outline.feature",
          "displayName" : "StepLevelHashOutline",
          "generatedClass" : "fixtures.StepLevelHashOutlineTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 2,
            "failed" : 0,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenarioOutline",
            "id" : "fixtures.StepLevelHashOutlineTest#scenario_1",
            "displayName" : "Scenario Outline: Outline scenario",
            "sourceLine" : 3,
            "scenarioHash" : "11112222333344445555666677778888aaaabbbbccccddddeeeeffff00009999",
            "totalDurationMs" : 0,
            "examples" : [ {
              "displayName" : "Example 1: [event = alpha, outcome = success]",
              "status" : "passed",
              "sourceLine" : 3,
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "examplesRow" : {
                "event" : "alpha",
                "outcome" : "success"
              },
              "rowHash" : "1c5a03181b255e2e564c786e12b9d7afeedcbf459fb7ce4c9096bb5035e3dc05",
              "steps" : [ {
                "methodName" : "aPreconditionHolds",
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theEventFires",
                "arguments" : [ "alpha" ],
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theOutcomeIsObserved",
                "arguments" : [ "success" ],
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              } ]
            }, {
              "displayName" : "Example 2: [event = beta, outcome = pass]",
              "status" : "passed",
              "sourceLine" : 3,
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "examplesRow" : {
                "event" : "beta",
                "outcome" : "pass"
              },
              "rowHash" : "ac8e2a67e7fb9426bf3d795645824ce2032558be85f5dd33cbd960d903242ff7",
              "steps" : [ {
                "methodName" : "aPreconditionHolds",
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theEventFires",
                "arguments" : [ "beta" ],
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              }, {
                "methodName" : "theOutcomeIsObserved",
                "arguments" : [ "pass" ],
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              } ]
            } ]
          } ]
        }
        """
