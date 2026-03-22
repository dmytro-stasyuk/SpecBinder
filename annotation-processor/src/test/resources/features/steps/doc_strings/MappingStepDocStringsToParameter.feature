Feature: MappingStepDocStringsToParameter
  As a developer
  I want Gherkin DocStrings to be mapped to String parameters in generated step methods
  So that I can work with multi-line text content in my tests

  Rule: DocString parameters are added as the last parameter of type String
  - if a step has a DocString, a parameter of type String named "docString" is added
  - the DocString content is passed as a text block (triple quotes """ """)

    Scenario: Step with DocString and no quoted parameters
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
        Feature: Document Processing
          Scenario: Process document
            Given document contains:
              \"\"\"
              Hello World
              This is a test document
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Document Processing
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void documentContains(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process document")
            public void scenario_1() {
                /*
                 * Given document contains:
                 */
                documentContains(\"\"\"
                        Hello World
                        This is a test document
                        \"\"\");
            }
        }
        """

    Scenario: Step with DocString and one quoted parameter
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
        Feature: User Documents
          Scenario: Save user document
            When user "Alice" saves document:
              \"\"\"
              Meeting notes:
              - Discuss project timeline
              - Review budget
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: User Documents
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1SavesDocument(String p1, String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Save user document")
            public void scenario_1() {
                /*
                 * When user "Alice" saves document:
                 */
                user$p1SavesDocument("Alice", \"\"\"
                        Meeting notes:
                        - Discuss project timeline
                        - Review budget
                        \"\"\");
            }
        }
        """

    Scenario: Step with DocString and multiple quoted parameters
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
        Feature: Email System
          Scenario: Send email
            When user "Bob" sends email to "alice@example.com" with content:
              \"\"\"
              Dear Alice,

              Please review the attached document.

              Best regards,
              Bob
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Email System
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1SendsEmailTo$p2WithContent(String p1, String p2, String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Send email")
            public void scenario_1() {
                /*
                 * When user "Bob" sends email to "alice@example.com" with content:
                 */
                user$p1SendsEmailTo$p2WithContent("Bob", "alice@example.com", \"\"\"
                        Dear Alice,

                        Please review the attached document.

                        Best regards,
                        Bob
                        \"\"\");
            }
        }
        """

