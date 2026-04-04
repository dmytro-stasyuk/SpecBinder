Feature: StepDocStringBackslashEscaping
  As a developer
  I want backslash sequences in DocString content to be passed through as-is to generated Java text blocks
  So that I can use Java escape sequences like \", \\, and \s directly in my feature files

  Rule: DocString content is passed through as-is to the generated Java text block
  - backslash sequences in the DocString are not modified by the generator
  - valid Java escape sequences (\", \\, \s, \n, \t, etc.) are preserved as written
  - it is the user's responsibility to ensure the DocString content contains valid Java text block syntax
  - the only exception is triple quotes (""") which are escaped to \""" to avoid breaking the text block delimiter

    Scenario: DocString with \s trailing space escape is preserved
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Trailing Spaces
          Scenario: Test
            Given the following template:
              \"\"\"
              Name:  \s
              Value: \s
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
         * Feature: Trailing Spaces
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theFollowingTemplate(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following template:
                 */
                theFollowingTemplate(\"\"\"
                        Name:  \s
                        Value: \s
                        \"\"\");
            }
        }
        """

    Scenario: DocString with escaped double quotes
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Escaped Quotes In DocString
          Scenario: Test
            Given the following JSON:
              \"\"\"
              {"key": "say \"hello\""}
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
         * Feature: Escaped Quotes In DocString
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theFollowingJson(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following JSON:
                 */
                theFollowingJson(\"\"\"
                        {"key": "say \"hello\""}
                        \"\"\");
            }
        }
        """

    Scenario: DocString with double backslash for literal backslash in output
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Literal Backslash
          Scenario: Test
            Given the following path:
              \"\"\"
              C:\\Users\\admin\\Documents\\report.txt
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
         * Feature: Literal Backslash
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theFollowingPath(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following path:
                 */
                theFollowingPath(\"\"\"
                        C:\\Users\\admin\\Documents\\report.txt
                        \"\"\");
            }
        }
        """

    Scenario: DocString with mixed escape sequences and literal content
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Mixed DocString Escapes
          Scenario: Test
            Given the following content:
              \"\"\"
              path: C:\\config
              value: "say \"hi\""
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
         * Feature: Mixed DocString Escapes
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theFollowingContent(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following content:
                 */
                theFollowingContent(\"\"\"
                        path: C:\\config
                        value: "say \"hi\""
                        \"\"\");
            }
        }
        """

  Rule: A double backslash sequence (\\) in DocString content produces a literal backslash in the runtime string
  - the sequence \\ (backslash-backslash) in the Gherkin DocString represents a literal \
    e.g. @DisplayName("Rule: Items marked as \\"final sale\\" cannot be returned")

    Scenario: DocString with literal backslash-quote sequence for Java source containing escaped quotes
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Java Source With Escaped Quotes
          Scenario: Test
            Given the following Java source:
              \"\"\"
              @Nested
              @Order(1)
              @DisplayName("Rule: Items marked as \\"final sale\\" cannot be returned")
              public class Rule_1 {
              }
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
         * Feature: Java Source With Escaped Quotes
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theFollowingJavaSource(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the following Java source:
                 */
                theFollowingJavaSource(\"\"\"
                        @Nested
                        @Order(1)
                        @DisplayName("Rule: Items marked as \\"final sale\\" cannot be returned")
                        public class Rule_1 {
                        }
                        \"\"\");
            }
        }
        """
