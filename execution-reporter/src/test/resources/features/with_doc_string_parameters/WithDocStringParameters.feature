Feature: WithDocStringParameters
  As a developer or CI pipeline consuming SpecBinder execution reports
  I want each step entry that receives a doc string to include the text content
    in the arguments array, so that I can see exactly what multi-line input was
    passed to each step
  So that I can debug failures and audit test behavior without re-running the suite

  Rule: step reports include the doc string content as a string in the arguments array

    Scenario: a step with a doc string passes alongside a step without parameters
      Given a feature file under path "fixtures/docstring-passing.feature" with the following content:
        """
        Feature: DocStringPassing

          Scenario: Process a document
            Given a document with content:
              \"\"\"
              Hello World
              This is a test document
              \"\"\"
            Then the document is stored
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/docstring-passing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DocStringPassingFeature {

            public void aDocumentWithContent(String docString) { }
            public void theDocumentIsStored() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DocStringPassing")
        @SourceFilePath("fixtures/docstring-passing.feature")
        public class DocStringPassingTest extends DocStringPassingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Process a document")
            public void scenario_1() {
                aDocumentWithContent(\"\"\"
                        Hello World
                        This is a test document
                        \"\"\");
                theDocumentIsStored();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/docstring-passing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/docstring-passing.feature",
          "displayName" : "DocStringPassing",
          "generatedClass" : "fixtures.DocStringPassingTest",
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
            "id" : "fixtures.DocStringPassingTest#scenario_1",
            "displayName" : "Scenario: Process a document",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aDocumentWithContent",
              "arguments" : [ "Hello World\nThis is a test document\n" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theDocumentIsStored",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

  Rule: when a step with a doc string fails the error and doc string content are both captured

    Scenario: a doc string step fails and subsequent steps are skipped
      Given a feature file under path "fixtures/docstring-failing.feature" with the following content:
        """
        Feature: DocStringFailing

          Scenario: Validate document content
            Given a document to validate:
              \"\"\"
              { "name": "test", "value": -1 }
              \"\"\"
            When the document is processed
            Then the result is available
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/docstring-failing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DocStringFailingFeature {

            public void aDocumentToValidate(String docString) {
                if (docString.contains("-1")) {
                    throw new AssertionError("document contains invalid value: -1");
                }
            }
            public void theDocumentIsProcessed() { }
            public void theResultIsAvailable() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DocStringFailing")
        @SourceFilePath("fixtures/docstring-failing.feature")
        public class DocStringFailingTest extends DocStringFailingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Validate document content")
            public void scenario_1() {
                aDocumentToValidate(\"\"\"
                        { "name": "test", "value": -1 }
                        \"\"\");
                theDocumentIsProcessed();
                theResultIsAvailable();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/docstring-failing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/docstring-failing.feature",
          "displayName" : "DocStringFailing",
          "generatedClass" : "fixtures.DocStringFailingTest",
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
            "id" : "fixtures.DocStringFailingTest#scenario_1",
            "displayName" : "Scenario: Validate document content",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "aDocumentToValidate",
              "arguments" : [ "{ \"name\": \"test\", \"value\": -1 }\n" ],
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "document contains invalid value: -1",
                "stackTrace" : "<stackTrace>"
              }
            }, {
              "methodName" : "theDocumentIsProcessed",
              "status" : "skipped"
            }, {
              "methodName" : "theResultIsAvailable",
              "status" : "skipped"
            } ]
          } ]
        }
        """

  Rule: steps combining inline parameters with a doc string capture all arguments in positional order

    Scenario: a step has both an inline string parameter and a doc string
      Given a feature file under path "fixtures/docstring-mixed.feature" with the following content:
        """
        Feature: DocStringMixed

          Scenario: Save a user note
            When user "Alice" saves a note:
              \"\"\"
              Remember to review the PR
              \"\"\"
            Then the note is saved
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;

        @Gherkin2JUnit("fixtures/docstring-mixed.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DocStringMixedFeature {

            public void userSavesANote(String user, String docString) { }
            public void theNoteIsSaved() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DocStringMixed")
        @SourceFilePath("fixtures/docstring-mixed.feature")
        public class DocStringMixedTest extends DocStringMixedFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Save a user note")
            public void scenario_1() {
                userSavesANote("Alice", \"\"\"
                        Remember to review the PR
                        \"\"\");
                theNoteIsSaved();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/docstring-mixed.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/docstring-mixed.feature",
          "displayName" : "DocStringMixed",
          "generatedClass" : "fixtures.DocStringMixedTest",
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
            "id" : "fixtures.DocStringMixedTest#scenario_1",
            "displayName" : "Scenario: Save a user note",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "userSavesANote",
              "arguments" : [ "Alice", "Remember to review the PR\n" ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theNoteIsSaved",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """
