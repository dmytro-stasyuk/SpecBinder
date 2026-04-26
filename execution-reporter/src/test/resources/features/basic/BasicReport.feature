Feature: BasicReport
  As a developer or CI pipeline consuming SpecBinder execution reports
  I want the JSON report to accurately reflect each scenario's pass/fail status
  and record every step with its outcome — including skipped steps after a failure
  So that downstream tooling can render a faithful step-by-step trace of every test run

  Rule: when all steps pass the scenario status is "passed" and every step is "passed"

    Scenario: all steps pass
      Given a feature file under path "fixtures/basic-report-passing.feature" with the following content:
        """
        Feature: BasicReportPassing

          Scenario: All steps pass
            Given a precondition holds
            When an event fires
            Then an outcome is observed
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/basic-report-passing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class BasicReportPassingFeature {

            public void aPreconditionHolds() { }
            public void anEventFires() { }
            public void anOutcomeIsObserved() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("BasicReportPassing")
        @SourceFilePath("fixtures/basic-report-passing.feature")
        public class BasicReportPassingTest extends BasicReportPassingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: All steps pass")
            public void scenario_1() {
                aPreconditionHolds();
                anEventFires();
                anOutcomeIsObserved();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/basic-report-passing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/basic-report-passing.feature",
          "displayName" : "BasicReportPassing",
          "generatedClass" : "fixtures.BasicReportPassingTest",
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
            "id" : "fixtures.BasicReportPassingTest#scenario_1",
            "displayName" : "Scenario: All steps pass",
            "status" : "passed",
            "sourceLine" : 3,
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

  Rule: when a step fails the scenario status is "failed" and subsequent steps are "skipped"

    Scenario: a middle step fails and the remaining steps are skipped
      Given a feature file under path "fixtures/basic-report-failing.feature" with the following content:
        """
        Feature: BasicReportFailing

          Scenario: A middle step fails
            Given a precondition holds
            When the failing event fires
            Then an outcome is observed
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/basic-report-failing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class BasicReportFailingFeature {

            public void aPreconditionHolds() { }
            public void theFailingEventFires() {
                throw new AssertionError("the event did not fire as expected");
            }
            public void anOutcomeIsObserved() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("BasicReportFailing")
        @SourceFilePath("fixtures/basic-report-failing.feature")
        public class BasicReportFailingTest extends BasicReportFailingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A middle step fails")
            public void scenario_1() {
                aPreconditionHolds();
                theFailingEventFires();
                anOutcomeIsObserved();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/basic-report-failing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/basic-report-failing.feature",
          "displayName" : "BasicReportFailing",
          "generatedClass" : "fixtures.BasicReportFailingTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 0,
            "failed" : 1,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.BasicReportFailingTest#scenario_1",
            "displayName" : "Scenario: A middle step fails",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aPreconditionHolds",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theFailingEventFires",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "the event did not fire as expected",
                "stackTrace" : "<stackTrace>"
              }
            }, {
              "methodName" : "anOutcomeIsObserved",
              "status" : "skipped"
            } ]
          } ]
        }
        """

    Scenario: the first step fails and all subsequent steps are skipped
      Given a feature file under path "fixtures/basic-report-first-fails.feature" with the following content:
        """
        Feature: BasicReportFirstFails

          Scenario: The first step fails
            Given the precondition fails
            When an event fires
            Then an outcome is observed
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/basic-report-first-fails.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class BasicReportFirstFailsFeature {

            public void thePreconditionFails() {
                throw new AssertionError("precondition was not met");
            }
            public void anEventFires() { }
            public void anOutcomeIsObserved() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("BasicReportFirstFails")
        @SourceFilePath("fixtures/basic-report-first-fails.feature")
        public class BasicReportFirstFailsTest extends BasicReportFirstFailsFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: The first step fails")
            public void scenario_1() {
                thePreconditionFails();
                anEventFires();
                anOutcomeIsObserved();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/basic-report-first-fails.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/basic-report-first-fails.feature",
          "displayName" : "BasicReportFirstFails",
          "generatedClass" : "fixtures.BasicReportFirstFailsTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 0,
            "failed" : 1,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.BasicReportFirstFailsTest#scenario_1",
            "displayName" : "Scenario: The first step fails",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "thePreconditionFails",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "precondition was not met",
                "stackTrace" : "<stackTrace>"
              }
            }, {
              "methodName" : "anEventFires",
              "status" : "skipped"
            }, {
              "methodName" : "anOutcomeIsObserved",
              "status" : "skipped"
            } ]
          } ]
        }
        """

  Rule: top-level scenarios appear in "scenarios" while rule-level scenarios appear under "rules"

    Scenario: a feature with both top-level and rule-level scenarios
      Given a feature file under path "fixtures/basic-report-mixed.feature" with the following content:
        """
        Feature: BasicReportMixed

          Scenario: Top level scenario
            Given a precondition holds

          Rule: Business rules

            Scenario: Rule level scenario
              When an event fires
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/basic-report-mixed.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class BasicReportMixedFeature {

            public void aPreconditionHolds() { }
            public void anEventFires() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Test;

        @DisplayName("BasicReportMixed")
        @SourceFilePath("fixtures/basic-report-mixed.feature")
        public class BasicReportMixedTest extends BasicReportMixedFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Top level scenario")
            public void scenario_1() {
                aPreconditionHolds();
            }

            @Nested
            @SourceLine(6)
            @DisplayName("Rule: Business rules")
            class Rule_1 {

                @Test
                @SourceLine(8)
                @DisplayName("Scenario: Rule level scenario")
                public void scenario_1() {
                    anEventFires();
                }
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/basic-report-mixed.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/basic-report-mixed.feature",
          "displayName" : "BasicReportMixed",
          "generatedClass" : "fixtures.BasicReportMixedTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 2,
            "failed" : 0,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.BasicReportMixedTest#scenario_1",
            "displayName" : "Scenario: Top level scenario",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aPreconditionHolds",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ],
          "rules" : [ {
            "id" : "fixtures.BasicReportMixedTest$Rule_1",
            "displayName" : "Rule: Business rules",
            "sourceLine" : 6,
            "scenarios" : [ {
              "type" : "scenario",
              "id" : "fixtures.BasicReportMixedTest$Rule_1#scenario_1",
              "displayName" : "Scenario: Rule level scenario",
              "status" : "passed",
              "sourceLine" : 8,
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "steps" : [ {
                "methodName" : "anEventFires",
                "status" : "passed",
                "startedAt" : "<ts>",
                "durationMs" : 0
              } ]
            } ]
          } ]
        }
        """
