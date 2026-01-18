Feature: StepDocStringsFormatPreservation
  As a BDD test developer working with complex multi-line content
  I want DocStrings to preserve exact formatting including indentation, line breaks, and special characters when mapped to Java String parameters
  So that I can reliably test JSON payloads, XML documents, and formatted text without manual escaping or losing critical whitespace

  Rule: Triple quotes in output are escaped but cannot be tested due to Gherkin limitation
  - When DocString content contains triple quotes in source feature files, they are escaped as \\\"\\\"\\\" in generated Java code
  - This escaping prevents breaking Java text block syntax
  - NOTE: This cannot be demonstrated in test scenarios because Gherkin does not support triple quotes inside DocStrings
  - The Gherkin parser would interpret """ inside a DocString as the end delimiter, making it impossible to write valid test cases
  - This is a known limitation of the Gherkin specification, not a limitation of the code generator

    Rule: Multi-line content in DocStrings is preserved exactly as written
    - indentation is preserved
    - blank lines are preserved
    - special characters are preserved
    - line breaks are maintained

    Scenario: DocString with complex formatting is preserved
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
        Feature: File Content
          Scenario: Verify file structure
            Then file should contain:
              \"\"\"
              {
                "name": "project",
                "version": "1.0.0",

                "dependencies": {
                  "lib1": "^2.0.0"
                }
              }
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: File Content
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void thenFileShouldContain(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Verify file structure")
            public void scenario_1() {
                /*
                 * Then file should contain:
                 */
                thenFileShouldContain(\"\"\"
                        {
                          "name": "project",
                          "version": "1.0.0",

                          "dependencies": {
                            "lib1": "^2.0.0"
                          }
                        }
                        \"\"\");
            }
        }
        """

    Scenario: DocString with special characters and symbols
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
        Feature: Special Characters
          Scenario: Handle special text
            Given text with symbols:
              \"\"\"
              Special chars: @#$%^&*()
              Quotes: "single" and 'double'
              Backslash: \\path\\to\\file
              Unicode: café, naïve, 日本語
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Special Characters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenTextWithSymbols(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Handle special text")
            public void scenario_1() {
                /*
                 * Given text with symbols:
                 */
                givenTextWithSymbols(\"\"\"
                        Special chars: @#$%^&*()
                        Quotes: "single" and 'double'
                        Backslash: \\path\\to\\file
                        Unicode: café, naïve, 日本語
                        \"\"\");
            }
        }
        """

  Rule: DocString content type markers are ignored by the generator
  - DocStrings can have optional content type markers (e.g., ```json, ```xml).
  - These markers are stripped out by the generator

    Scenario: DocString with json content type marker
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
        Feature: API Testing
          Scenario: Send JSON request
            Given the following JSON payload:
              \"\"\"json
              {
                "userId": 123,
                "action": "create",
                "data": {
                  "name": "Test Item"
                }
              }
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: API Testing
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenTheFollowingJsonPayload(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Send JSON request")
            public void scenario_1() {
                /*
                 * Given the following JSON payload:
                 */
                givenTheFollowingJsonPayload(\"\"\"
                        {
                          "userId": 123,
                          "action": "create",
                          "data": {
                            "name": "Test Item"
                          }
                        }
                        \"\"\");
            }
        }
        """

    Scenario: DocString with xml content type marker
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
        Feature: XML Processing
          Scenario: Parse XML document
            When system processes XML:
              \"\"\"xml
              <?xml version="1.0" encoding="UTF-8"?>
              <document>
                <title>Sample Document</title>
                <content>This is a test</content>
              </document>
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: XML Processing
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenSystemProcessesXml(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Parse XML document")
            public void scenario_1() {
                /*
                 * When system processes XML:
                 */
                whenSystemProcessesXml(\"\"\"
                        <?xml version="1.0" encoding="UTF-8"?>
                        <document>
                          <title>Sample Document</title>
                          <content>This is a test</content>
                        </document>
                        \"\"\");
            }
        }
        """

    Scenario: DocString with custom content type marker
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
        Feature: Custom Format
          Scenario: Process custom data
            Then output should match:
              \"\"\"yaml
              version: 2.0
              services:
                web:
                  image: nginx
                  ports:
                    - "80:80"
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Custom Format
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void thenOutputShouldMatch(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process custom data")
            public void scenario_1() {
                /*
                 * Then output should match:
                 */
                thenOutputShouldMatch(\"\"\"
                        version: 2.0
                        services:
                          web:
                            image: nginx
                            ports:
                              - "80:80"
                        \"\"\");
            }
        }
        """