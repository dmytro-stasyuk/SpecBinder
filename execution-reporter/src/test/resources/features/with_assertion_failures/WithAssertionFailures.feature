Feature: WithAssertionFailures
  As a developer or downstream tool consuming SpecBinder execution reports
  I want each failing step's error entry to include the structured expected and actual values
    captured from any AssertionFailedError that defines them, so that tools (such as the
    IntelliJ plugin) can render an expected-vs-actual diff without parsing free-form messages
  So that I can review approval-style mismatches and decide whether to accept the actual value

  Rule: an AssertionFailedError with defined expected and actual is captured into expected and actual on the error entry

    Scenario: a step throws AssertionFailedError carrying single-line string expected and actual
      Given a feature file under path "fixtures/assertion-failed-with-values.feature" with the following content:
        """
        Feature: AssertionFailedWithValues

          Scenario: A step asserts a greeting and the values differ
            Then the greeting should match
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import org.opentest4j.AssertionFailedError;

        @Gherkin2JUnit("fixtures/assertion-failed-with-values.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class AssertionFailedWithValuesFeature {

            public void theGreetingShouldMatch() {
                throw new AssertionFailedError("greeting mismatch", "Hello", "World");
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("AssertionFailedWithValues")
        @SourceFilePath("fixtures/assertion-failed-with-values.feature")
        public class AssertionFailedWithValuesTest extends AssertionFailedWithValuesFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step asserts a greeting and the values differ")
            public void scenario_1() {
                theGreetingShouldMatch();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/assertion-failed-with-values.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/assertion-failed-with-values.feature",
          "displayName" : "AssertionFailedWithValues",
          "generatedClass" : "fixtures.AssertionFailedWithValuesTest",
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
            "id" : "fixtures.AssertionFailedWithValuesTest#scenario_1",
            "displayName" : "Scenario: A step asserts a greeting and the values differ",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theGreetingShouldMatch",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "org.opentest4j.AssertionFailedError",
                "message" : "greeting mismatch",
                "expected" : "Hello",
                "actual" : "World",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """

    Scenario: a step calls Assertions.assertEquals with the expected value supplied by the Gherkin step text
      Given a feature file under path "fixtures/assertion-failed-via-assert-equals.feature" with the following content:
        """
        Feature: AssertionFailedViaAssertEquals

          Scenario: A step uses JUnit's Assertions.assertEquals where the expected value comes from the step text
            Then the greeting should equal "Hello"
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/assertion-failed-via-assert-equals.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class AssertionFailedViaAssertEqualsFeature {

            public void theGreetingShouldEqual(String expected) {
                Assertions.assertEquals(expected, "World");
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("AssertionFailedViaAssertEquals")
        @SourceFilePath("fixtures/assertion-failed-via-assert-equals.feature")
        public class AssertionFailedViaAssertEqualsTest extends AssertionFailedViaAssertEqualsFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step uses JUnit's Assertions.assertEquals where the expected value comes from the step text")
            public void scenario_1() {
                theGreetingShouldEqual("Hello");
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/assertion-failed-via-assert-equals.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/assertion-failed-via-assert-equals.feature",
          "displayName" : "AssertionFailedViaAssertEquals",
          "generatedClass" : "fixtures.AssertionFailedViaAssertEqualsTest",
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
            "id" : "fixtures.AssertionFailedViaAssertEqualsTest#scenario_1",
            "displayName" : "Scenario: A step uses JUnit's Assertions.assertEquals where the expected value comes from the step text",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theGreetingShouldEqual",
              "arguments" : [ "Hello" ],
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "org.opentest4j.AssertionFailedError",
                "message" : "expected: <Hello> but was: <World>",
                "expected" : "Hello",
                "actual" : "World",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """

    Scenario: a step throws AssertionFailedError with the expected HTML supplied by a docString parameter
      Given a feature file under path "fixtures/assertion-failed-docstring-expected.feature" with the following content:
        """
        Feature: AssertionFailedDocStringExpected

          Scenario: A step asserts an HTML response body where the expected value comes from a doc string
            Then the response body should match:
              \"\"\"html
              <section>
                <h1>Hello</h1>
                <p>Welcome to the site</p>
              </section>
              \"\"\"
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import org.opentest4j.AssertionFailedError;

        @Gherkin2JUnit("fixtures/assertion-failed-docstring-expected.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class AssertionFailedDocStringExpectedFeature {

            public void theResponseBodyShouldMatch(String docString) {
                String actual = "<section>\n  <h1>Hello</h1>\n  <p>Welcome to the app</p>\n</section>\n";
                throw new AssertionFailedError("HTML body mismatch", docString, actual);
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("AssertionFailedDocStringExpected")
        @SourceFilePath("fixtures/assertion-failed-docstring-expected.feature")
        public class AssertionFailedDocStringExpectedTest extends AssertionFailedDocStringExpectedFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step asserts an HTML response body where the expected value comes from a doc string")
            public void scenario_1() {
                theResponseBodyShouldMatch(\"\"\"
                        <section>
                          <h1>Hello</h1>
                          <p>Welcome to the site</p>
                        </section>
                        \"\"\");
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/assertion-failed-docstring-expected.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/assertion-failed-docstring-expected.feature",
          "displayName" : "AssertionFailedDocStringExpected",
          "generatedClass" : "fixtures.AssertionFailedDocStringExpectedTest",
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
            "id" : "fixtures.AssertionFailedDocStringExpectedTest#scenario_1",
            "displayName" : "Scenario: A step asserts an HTML response body where the expected value comes from a doc string",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theResponseBodyShouldMatch",
              "arguments" : [ "<section>\n  <h1>Hello</h1>\n  <p>Welcome to the site</p>\n</section>\n" ],
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "org.opentest4j.AssertionFailedError",
                "message" : "HTML body mismatch",
                "expected" : "<section>\n  <h1>Hello</h1>\n  <p>Welcome to the site</p>\n</section>\n",
                "actual" : "<section>\n  <h1>Hello</h1>\n  <p>Welcome to the app</p>\n</section>\n",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """

  Rule: an AssertionFailedError without defined expected or actual omits both fields from the error entry

    Scenario: a step throws AssertionFailedError with only a message and no expected or actual values
      Given a feature file under path "fixtures/assertion-failed-no-values.feature" with the following content:
        """
        Feature: AssertionFailedNoValues

          Scenario: A step fails without providing comparison values
            Then the step fails without context
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import org.opentest4j.AssertionFailedError;

        @Gherkin2JUnit("fixtures/assertion-failed-no-values.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class AssertionFailedNoValuesFeature {

            public void theStepFailsWithoutContext() {
                throw new AssertionFailedError("boom");
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("AssertionFailedNoValues")
        @SourceFilePath("fixtures/assertion-failed-no-values.feature")
        public class AssertionFailedNoValuesTest extends AssertionFailedNoValuesFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step fails without providing comparison values")
            public void scenario_1() {
                theStepFailsWithoutContext();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/assertion-failed-no-values.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/assertion-failed-no-values.feature",
          "displayName" : "AssertionFailedNoValues",
          "generatedClass" : "fixtures.AssertionFailedNoValuesTest",
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
            "id" : "fixtures.AssertionFailedNoValuesTest#scenario_1",
            "displayName" : "Scenario: A step fails without providing comparison values",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theStepFailsWithoutContext",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "org.opentest4j.AssertionFailedError",
                "message" : "boom",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """

  Rule: a plain java.lang.AssertionError produces an error entry without expected or actual fields

    Scenario: a step throws a plain AssertionError that is not an AssertionFailedError
      Given a feature file under path "fixtures/plain-assertion-error.feature" with the following content:
        """
        Feature: PlainAssertionError

          Scenario: A step throws a plain AssertionError
            Then the step fails with a plain AssertionError
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/plain-assertion-error.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class PlainAssertionErrorFeature {

            public void theStepFailsWithAPlainAssertionError() {
                throw new AssertionError("plain failure");
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("PlainAssertionError")
        @SourceFilePath("fixtures/plain-assertion-error.feature")
        public class PlainAssertionErrorTest extends PlainAssertionErrorFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step throws a plain AssertionError")
            public void scenario_1() {
                theStepFailsWithAPlainAssertionError();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/plain-assertion-error.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/plain-assertion-error.feature",
          "displayName" : "PlainAssertionError",
          "generatedClass" : "fixtures.PlainAssertionErrorTest",
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
            "id" : "fixtures.PlainAssertionErrorTest#scenario_1",
            "displayName" : "Scenario: A step throws a plain AssertionError",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theStepFailsWithAPlainAssertionError",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "plain failure",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """

  Rule: multi-line string expected and actual values are captured with newlines preserved

    Scenario: a step throws AssertionFailedError comparing multi-line documents
      Given a feature file under path "fixtures/assertion-failed-multiline.feature" with the following content:
        """
        Feature: AssertionFailedMultiline

          Scenario: A step compares two multi-line documents that differ on one line
            Then the document should match the expected baseline
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import org.opentest4j.AssertionFailedError;

        @Gherkin2JUnit("fixtures/assertion-failed-multiline.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class AssertionFailedMultilineFeature {

            public void theDocumentShouldMatchTheExpectedBaseline() {
                String expected = "line one\nline two\nline three\n";
                String actual = "line one\nline TWO\nline three\n";
                throw new AssertionFailedError("document mismatch", expected, actual);
            }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("AssertionFailedMultiline")
        @SourceFilePath("fixtures/assertion-failed-multiline.feature")
        public class AssertionFailedMultilineTest extends AssertionFailedMultilineFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: A step compares two multi-line documents that differ on one line")
            public void scenario_1() {
                theDocumentShouldMatchTheExpectedBaseline();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/assertion-failed-multiline.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/assertion-failed-multiline.feature",
          "displayName" : "AssertionFailedMultiline",
          "generatedClass" : "fixtures.AssertionFailedMultilineTest",
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
            "id" : "fixtures.AssertionFailedMultilineTest#scenario_1",
            "displayName" : "Scenario: A step compares two multi-line documents that differ on one line",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theDocumentShouldMatchTheExpectedBaseline",
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "org.opentest4j.AssertionFailedError",
                "message" : "document mismatch",
                "expected" : "line one\nline two\nline three\n",
                "actual" : "line one\nline TWO\nline three\n",
                "stackTrace" : "<stackTrace>"
              }
            } ]
          } ]
        }
        """
