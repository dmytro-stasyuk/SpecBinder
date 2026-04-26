Feature: WithBackgroundSteps

  As a developer using SpecBinder with Background blocks in feature files
  I want the execution report to expose background steps in a dedicated backgroundSteps array
  separate from the scenario's own steps[]
  So that report consumers can trace setup failures separately from scenario logic
  without needing a per-step discriminator field

  Scenario: Background steps appear in a backgroundSteps array separate from the scenario steps
    Given a feature file under path "fixtures/step-level-background.feature" with the following content:
      """
      Feature: StepLevelBackground

        Background:
          Given the cart is reset
          And the catalog is loaded

        Scenario: A scenario after a background
          When an event fires
          Then an outcome is observed
      """
    And the following SpecBinder marker class:
      """
      package fixtures;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.reporter.SpecBinderReporter;
      import org.junit.jupiter.api.extension.ExtendWith;

      @Gherkin2JUnit("fixtures/step-level-background.feature")
      @ExtendWith(SpecBinderReporter.class)
      public abstract class StepLevelBackgroundFeature {

          public void theCartIsReset() { }
          public void theCatalogIsLoaded() { }
          public void anEventFires() { }
          public void anOutcomeIsObserved() { }
      }
      """
    And the following SpecBinder-generated test class:
      """
      package fixtures;

      import dev.specbinder.annotations.output.SourceFilePath;
      import dev.specbinder.annotations.output.SourceLine;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Test;

      @DisplayName("StepLevelBackground")
      @SourceFilePath("fixtures/step-level-background.feature")
      public class StepLevelBackgroundTest extends StepLevelBackgroundFeature {

          @BeforeEach
          public void background_1() {
              theCartIsReset();
              theCatalogIsLoaded();
          }

          @Test
          @SourceLine(7)
          @DisplayName("Scenario: A scenario after a background")
          public void scenario_1() {
              anEventFires();
              anOutcomeIsObserved();
          }
      }
      """
    When the test class is executed
    Then the produced report at "fixtures/step-level-background.feature.json" should match:
      """
      {
        "schemaVersion" : 3,
        "sourceFilePath" : "fixtures/step-level-background.feature",
        "displayName" : "StepLevelBackground",
        "generatedClass" : "fixtures.StepLevelBackgroundTest",
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
          "id" : "fixtures.StepLevelBackgroundTest#scenario_1",
          "displayName" : "Scenario: A scenario after a background",
          "status" : "passed",
          "sourceLine" : 7,
          "startedAt" : "<ts>",
          "durationMs" : 0,
          "backgroundSteps" : [ {
            "methodName" : "theCartIsReset",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          }, {
            "methodName" : "theCatalogIsLoaded",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          } ],
          "steps" : [ {
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

  Scenario: A failing background step skips all scenario steps
    Given a feature file under path "fixtures/bg-failing.feature" with the following content:
      """
      Feature: BgFailing

        Background:
          Given the cart is reset
          And the catalog is loaded

        Scenario: A scenario after a failing background
          When an event fires
          Then an outcome is observed
      """
    And the following SpecBinder marker class:
      """
      package fixtures;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.reporter.SpecBinderReporter;
      import org.junit.jupiter.api.extension.ExtendWith;

      @Gherkin2JUnit("fixtures/bg-failing.feature")
      @ExtendWith(SpecBinderReporter.class)
      public abstract class BgFailingFeature {

          public void theCartIsReset() { }
          public void theCatalogIsLoaded() {
              throw new AssertionError("catalog failed to load");
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
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Test;

      @DisplayName("BgFailing")
      @SourceFilePath("fixtures/bg-failing.feature")
      public class BgFailingTest extends BgFailingFeature {

          @BeforeEach
          public void background_1() {
              theCartIsReset();
              theCatalogIsLoaded();
          }

          @Test
          @SourceLine(7)
          @DisplayName("Scenario: A scenario after a failing background")
          public void scenario_1() {
              anEventFires();
              anOutcomeIsObserved();
          }
      }
      """
    When the test class is executed
    Then the produced report at "fixtures/bg-failing.feature.json" should match:
      """
      {
        "schemaVersion" : 3,
        "sourceFilePath" : "fixtures/bg-failing.feature",
        "displayName" : "BgFailing",
        "generatedClass" : "fixtures.BgFailingTest",
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
          "id" : "fixtures.BgFailingTest#scenario_1",
          "displayName" : "Scenario: A scenario after a failing background",
          "status" : "failed",
          "sourceLine" : 7,
          "startedAt" : "<ts>",
          "durationMs" : 0,
          "backgroundSteps" : [ {
            "methodName" : "theCartIsReset",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          }, {
            "methodName" : "theCatalogIsLoaded",
            "status" : "failed",
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "error" : {
              "type" : "java.lang.AssertionError",
              "message" : "catalog failed to load",
              "stackTrace" : "<stackTrace>"
            }
          } ],
          "steps" : [ {
            "methodName" : "anEventFires",
            "status" : "skipped"
          }, {
            "methodName" : "anOutcomeIsObserved",
            "status" : "skipped"
          } ]
        } ]
      }
      """

  Scenario: Background steps repeat for each scenario in the report
    Given a feature file under path "fixtures/bg-multi-scenario.feature" with the following content:
      """
      Feature: BgMultiScenario

        Background:
          Given the cart is reset

        Scenario: First scenario
          When event alpha fires

        Scenario: Second scenario
          When event beta fires
      """
    And the following SpecBinder marker class:
      """
      package fixtures;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.reporter.SpecBinderReporter;
      import org.junit.jupiter.api.extension.ExtendWith;

      @Gherkin2JUnit("fixtures/bg-multi-scenario.feature")
      @ExtendWith(SpecBinderReporter.class)
      public abstract class BgMultiScenarioFeature {

          public void theCartIsReset() { }
          public void eventAlphaFires() { }
          public void eventBetaFires() { }
      }
      """
    And the following SpecBinder-generated test class:
      """
      package fixtures;

      import dev.specbinder.annotations.output.SourceFilePath;
      import dev.specbinder.annotations.output.SourceLine;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Test;

      @DisplayName("BgMultiScenario")
      @SourceFilePath("fixtures/bg-multi-scenario.feature")
      public class BgMultiScenarioTest extends BgMultiScenarioFeature {

          @BeforeEach
          public void background_1() {
              theCartIsReset();
          }

          @Test
          @SourceLine(6)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              eventAlphaFires();
          }

          @Test
          @SourceLine(9)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              eventBetaFires();
          }
      }
      """
    When the test class is executed
    Then the produced report at "fixtures/bg-multi-scenario.feature.json" should match:
      """
      {
        "schemaVersion" : 3,
        "sourceFilePath" : "fixtures/bg-multi-scenario.feature",
        "displayName" : "BgMultiScenario",
        "generatedClass" : "fixtures.BgMultiScenarioTest",
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
          "id" : "fixtures.BgMultiScenarioTest#scenario_1",
          "displayName" : "Scenario: First scenario",
          "status" : "passed",
          "sourceLine" : 6,
          "startedAt" : "<ts>",
          "durationMs" : 0,
          "backgroundSteps" : [ {
            "methodName" : "theCartIsReset",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          } ],
          "steps" : [ {
            "methodName" : "eventAlphaFires",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          } ]
        }, {
          "type" : "scenario",
          "id" : "fixtures.BgMultiScenarioTest#scenario_2",
          "displayName" : "Scenario: Second scenario",
          "status" : "passed",
          "sourceLine" : 9,
          "startedAt" : "<ts>",
          "durationMs" : 0,
          "backgroundSteps" : [ {
            "methodName" : "theCartIsReset",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          } ],
          "steps" : [ {
            "methodName" : "eventBetaFires",
            "status" : "passed",
            "startedAt" : "<ts>",
            "durationMs" : 0
          } ]
        } ]
      }
      """

  Scenario: Background within a Rule block populates backgroundSteps for scenarios under that Rule
    Given a feature file under path "fixtures/bg-under-rule.feature" with the following content:
      """
      Feature: BgUnderRule

        Rule: Items require an active cart

          Background:
            Given the cart is reset

          Scenario: A scenario under a rule with background
            When an event fires
            Then an outcome is observed
      """
    And the following SpecBinder marker class:
      """
      package fixtures;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.reporter.SpecBinderReporter;
      import org.junit.jupiter.api.extension.ExtendWith;

      @Gherkin2JUnit("fixtures/bg-under-rule.feature")
      @ExtendWith(SpecBinderReporter.class)
      public abstract class BgUnderRuleFeature {

          public void theCartIsReset() { }
          public void anEventFires() { }
          public void anOutcomeIsObserved() { }
      }
      """
    And the following SpecBinder-generated test class:
      """
      package fixtures;

      import dev.specbinder.annotations.output.SourceFilePath;
      import dev.specbinder.annotations.output.SourceLine;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Test;

      @DisplayName("BgUnderRule")
      @SourceFilePath("fixtures/bg-under-rule.feature")
      public class BgUnderRuleTest extends BgUnderRuleFeature {

          @Nested
          @SourceLine(3)
          @DisplayName("Rule: Items require an active cart")
          class Rule_1 {

              @BeforeEach
              public void background_1() {
                  theCartIsReset();
              }

              @Test
              @SourceLine(8)
              @DisplayName("Scenario: A scenario under a rule with background")
              public void scenario_1() {
                  anEventFires();
                  anOutcomeIsObserved();
              }
          }
      }
      """
    When the test class is executed
    Then the produced report at "fixtures/bg-under-rule.feature.json" should match:
      """
      {
        "schemaVersion" : 3,
        "sourceFilePath" : "fixtures/bg-under-rule.feature",
        "displayName" : "BgUnderRule",
        "generatedClass" : "fixtures.BgUnderRuleTest",
        "executedAt" : "<ts>",
        "totalDurationMs" : 0,
        "summary" : {
          "passed" : 1,
          "failed" : 0,
          "aborted" : 0,
          "skipped" : 0
        },
        "rules" : [ {
          "id" : "fixtures.BgUnderRuleTest$Rule_1",
          "displayName" : "Rule: Items require an active cart",
          "sourceLine" : 3,
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.BgUnderRuleTest$Rule_1#scenario_1",
            "displayName" : "Scenario: A scenario under a rule with background",
            "status" : "passed",
            "sourceLine" : 8,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "backgroundSteps" : [ {
              "methodName" : "theCartIsReset",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ],
            "steps" : [ {
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
        } ]
      }
      """
