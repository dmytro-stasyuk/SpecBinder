Feature: WithSimpleParameters
  As a developer or CI pipeline consuming SpecBinder execution reports
  I want each step entry in the JSON report to include the runtime argument values
    alongside the method name, so that I can trace exactly which values were passed
  So that I can reproduce failures and understand test behavior without re-running the suite

  Rule: step reports include an arguments array with the runtime parameter values

    Scenario: all steps with a single inline parameter pass
      Given a feature file under path "fixtures/simple-params-passing.feature" with the following content:
        """
        Feature: SimpleParamsPassing

          Scenario: Steps with inline parameters
            Given a user "Alice" is registered
            When the user "Alice" places an order
            Then the confirmation for "Alice" is sent
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-passing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsPassingFeature {

            public void aUserIsRegistered(String name) { }
            public void theUserPlacesAnOrder(String name) { }
            public void theConfirmationForIsSent(String name) { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsPassing")
        @SourceFilePath("fixtures/simple-params-passing.feature")
        public class SimpleParamsPassingTest extends SimpleParamsPassingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Steps with inline parameters")
            public void scenario_1() {
                aUserIsRegistered("Alice");
                theUserPlacesAnOrder("Alice");
                theConfirmationForIsSent("Alice");
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-passing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-passing.feature",
          "displayName" : "SimpleParamsPassing",
          "generatedClass" : "fixtures.SimpleParamsPassingTest",
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
            "id" : "fixtures.SimpleParamsPassingTest#scenario_1",
            "displayName" : "Scenario: Steps with inline parameters",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aUserIsRegistered",
              "arguments" : [ "Alice" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theUserPlacesAnOrder",
              "arguments" : [ "Alice" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theConfirmationForIsSent",
              "arguments" : [ "Alice" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

  Rule: when a parameterized step fails the error captures the runtime value and skipped steps have no arguments

    Scenario: a parameterized step fails and the error includes the parameter value
      Given a feature file under path "fixtures/simple-params-failing.feature" with the following content:
        """
        Feature: SimpleParamsFailing

          Scenario: A parameterized step fails
            Given a user "Bob" is registered
            When the user "Bob" places an order
            Then the confirmation for "Bob" is sent
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-failing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsFailingFeature {

            public void aUserIsRegistered(String name) { }
            public void theUserPlacesAnOrder(String name) {
                throw new AssertionError("order rejected for user " + name);
            }
            public void theConfirmationForIsSent(String name) { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsFailing")
        @SourceFilePath("fixtures/simple-params-failing.feature")
        public class SimpleParamsFailingTest extends SimpleParamsFailingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A parameterized step fails")
            public void scenario_1() {
                aUserIsRegistered("Bob");
                theUserPlacesAnOrder("Bob");
                theConfirmationForIsSent("Bob");
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-failing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-failing.feature",
          "displayName" : "SimpleParamsFailing",
          "generatedClass" : "fixtures.SimpleParamsFailingTest",
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
            "id" : "fixtures.SimpleParamsFailingTest#scenario_1",
            "displayName" : "Scenario: A parameterized step fails",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aUserIsRegistered",
              "arguments" : [ "Bob" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theUserPlacesAnOrder",
              "arguments" : [ "Bob" ],
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "order rejected for user Bob",
                "stackTrace" : "<stackTrace>"
              }
            }, {
              "methodName" : "theConfirmationForIsSent",
              "status" : "skipped"
            } ]
          } ]
        }
        """

  Rule: non-string parameter types use their native JSON representation

    Scenario: a step with an int parameter serializes as a JSON number
      Given a feature file under path "fixtures/simple-params-int.feature" with the following content:
        """
        Feature: SimpleParamsInt

          Scenario: Integer parameter
            Given a cart with "3" items
            When the user checks out
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-int.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsIntFeature {

            public void aCartWithItems(int count) { }
            public void theUserChecksOut() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsInt")
        @SourceFilePath("fixtures/simple-params-int.feature")
        public class SimpleParamsIntTest extends SimpleParamsIntFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Integer parameter")
            public void scenario_1() {
                aCartWithItems(3);
                theUserChecksOut();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-int.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-int.feature",
          "displayName" : "SimpleParamsInt",
          "generatedClass" : "fixtures.SimpleParamsIntTest",
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
            "id" : "fixtures.SimpleParamsIntTest#scenario_1",
            "displayName" : "Scenario: Integer parameter",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aCartWithItems",
              "arguments" : [ 3 ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theUserChecksOut",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

    Scenario: a step with a boolean parameter serializes as a JSON boolean
      Given a feature file under path "fixtures/simple-params-boolean.feature" with the following content:
        """
        Feature: SimpleParamsBoolean

          Scenario: Boolean parameter
            Given the feature flag is "true"
            When the page is loaded
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-boolean.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsBooleanFeature {

            public void theFeatureFlagIs(boolean enabled) { }
            public void thePageIsLoaded() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsBoolean")
        @SourceFilePath("fixtures/simple-params-boolean.feature")
        public class SimpleParamsBooleanTest extends SimpleParamsBooleanFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Boolean parameter")
            public void scenario_1() {
                theFeatureFlagIs(true);
                thePageIsLoaded();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-boolean.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-boolean.feature",
          "displayName" : "SimpleParamsBoolean",
          "generatedClass" : "fixtures.SimpleParamsBooleanTest",
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
            "id" : "fixtures.SimpleParamsBooleanTest#scenario_1",
            "displayName" : "Scenario: Boolean parameter",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theFeatureFlagIs",
              "arguments" : [ true ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "thePageIsLoaded",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

    Scenario: a step with a double parameter serializes as a JSON number
      Given a feature file under path "fixtures/simple-params-double.feature" with the following content:
        """
        Feature: SimpleParamsDouble

          Scenario: Double parameter
            Given a product priced at "19.99"
            When the user adds it to the cart
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-double.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsDoubleFeature {

            public void aProductPricedAt(double price) { }
            public void theUserAddsItToTheCart() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsDouble")
        @SourceFilePath("fixtures/simple-params-double.feature")
        public class SimpleParamsDoubleTest extends SimpleParamsDoubleFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Double parameter")
            public void scenario_1() {
                aProductPricedAt(19.99);
                theUserAddsItToTheCart();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-double.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-double.feature",
          "displayName" : "SimpleParamsDouble",
          "generatedClass" : "fixtures.SimpleParamsDoubleTest",
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
            "id" : "fixtures.SimpleParamsDoubleTest#scenario_1",
            "displayName" : "Scenario: Double parameter",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aProductPricedAt",
              "arguments" : [ 19.99 ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theUserAddsItToTheCart",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

    Scenario: a step with a char parameter serializes as a JSON string
      Given a feature file under path "fixtures/simple-params-char.feature" with the following content:
        """
        Feature: SimpleParamsChar

          Scenario: Char parameter
            Given the grade "A" is assigned
            When the transcript is generated
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-char.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsCharFeature {

            public void theGradeIsAssigned(char grade) { }
            public void theTranscriptIsGenerated() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsChar")
        @SourceFilePath("fixtures/simple-params-char.feature")
        public class SimpleParamsCharTest extends SimpleParamsCharFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Char parameter")
            public void scenario_1() {
                theGradeIsAssigned('A');
                theTranscriptIsGenerated();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-char.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-char.feature",
          "displayName" : "SimpleParamsChar",
          "generatedClass" : "fixtures.SimpleParamsCharTest",
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
            "id" : "fixtures.SimpleParamsCharTest#scenario_1",
            "displayName" : "Scenario: Char parameter",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theGradeIsAssigned",
              "arguments" : [ "A" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theTranscriptIsGenerated",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

  Rule: steps with multiple inline parameters record all values in positional order

    Scenario: a step with multiple inline parameters on the same line
      Given a feature file under path "fixtures/simple-params-multi.feature" with the following content:
        """
        Feature: SimpleParamsMulti

          Scenario: Multiple inline parameters
            Given a user "Alice" is registered
            When the user "Alice" sends a message "Hello" to "Bob"
            Then the inbox of "Bob" contains "Hello"
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/simple-params-multi.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class SimpleParamsMultiFeature {

            public void aUserIsRegistered(String name) { }
            public void theUserSendsAMessageTo(String sender, String message, String recipient) { }
            public void theInboxOfContains(String user, String message) { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("SimpleParamsMulti")
        @SourceFilePath("fixtures/simple-params-multi.feature")
        public class SimpleParamsMultiTest extends SimpleParamsMultiFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Multiple inline parameters")
            public void scenario_1() {
                aUserIsRegistered("Alice");
                theUserSendsAMessageTo("Alice", "Hello", "Bob");
                theInboxOfContains("Bob", "Hello");
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/simple-params-multi.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/simple-params-multi.feature",
          "displayName" : "SimpleParamsMulti",
          "generatedClass" : "fixtures.SimpleParamsMultiTest",
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
            "id" : "fixtures.SimpleParamsMultiTest#scenario_1",
            "displayName" : "Scenario: Multiple inline parameters",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aUserIsRegistered",
              "arguments" : [ "Alice" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theUserSendsAMessageTo",
              "arguments" : [ "Alice", "Hello", "Bob" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theInboxOfContains",
              "arguments" : [ "Bob", "Hello" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """
