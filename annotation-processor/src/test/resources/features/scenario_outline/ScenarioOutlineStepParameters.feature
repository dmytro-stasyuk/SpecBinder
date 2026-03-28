Feature: ScenarioOutlineStepParameters
  As a developer
  I want scenario outline parameters to be correctly recognized in step text
  So that parameter references are replaced with actual values from the Examples table

  Rule: Step text with angle bracket parameters <param> in Scenario Outlines are replaced at method call site
  - Angle bracket parameters in step text are detected and replaced

    Scenario: Step with single scenario outline parameter
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
        Feature: Scenario Outline Single Parameter
          Scenario Outline: Test
            Given user <username> exists
            Examples:
              | username |
              | alice    |
              | bob      |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Scenario Outline Single Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username
                            alice
                            bob
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username) {
                /*
                 * Given user <username> exists
                 */
                user$p1Exists(username);
            }
        }
        """

    Scenario: Step with multiple scenario outline parameters
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
        Feature: Scenario Outline Multiple Parameters
          Scenario Outline: Test
            When user <username> sends message <message> to <recipient>
            Examples:
              | username | message | recipient |
              | alice    | hello   | bob       |
              | carol    | hi      | dave      |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Scenario Outline Multiple Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1SendsMessage$p2To$p3(String p1, String p2, String p3) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | message | recipient
                            alice    | hello   | bob
                            carol    | hi      | dave
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username, String message, String recipient) {
                /*
                 * When user <username> sends message <message> to <recipient>
                 */
                user$p1SendsMessage$p2To$p3(username, message, recipient);
            }
        }
        """

    Scenario: Step mixing quoted parameters and scenario outline parameters
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
        Feature: Mixed Parameters
          Scenario Outline: Test
            Given user "admin" assigns role <role> to user <username>
            Examples:
              | username | role  |
              | alice    | user  |
              | bob      | admin |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1AssignsRole$p2ToUser$p3(String p1, String p2, String p3) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | role
                            alice    | user
                            bob      | admin
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username, String role) {
                /*
                 * Given user "admin" assigns role <role> to user <username>
                 */
                user$p1AssignsRole$p2ToUser$p3("admin", role, username);
            }
        }
        """

  Rule: Outline parameter references inside double-quoted step parameters
  - When a scenario outline parameter like <param> appears inside a double-quoted step parameter
    alongside literal text, the generated code should substitute the placeholder at the call site
  - This follows the same replaceAll pattern already used for DataTable cells with mixed content

    Scenario: Single outline parameter embedded in quoted text
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
        Feature: Embedded Parameter
          Scenario Outline: Test
            Given the user enters "prefix <value> suffix" in the field
            Examples:
              | value |
              | hello |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Embedded Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theUserEnters$p1InTheField(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            value
                            hello
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String value) {
                /*
                 * Given the user enters "prefix <value> suffix" in the field
                 */
                theUserEnters$p1InTheField("prefix <value> suffix"
                        .replaceAll("<value>", value));
            }
        }
        """

    Scenario: Outline parameter is the entire content of a quoted parameter
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
        Feature: Whole Quoted Parameter
          Scenario Outline: Test
            Given the user enters "<value>" in the field
            Examples:
              | value |
              | hello |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Whole Quoted Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theUserEnters$p1InTheField(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            value
                            hello
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String value) {
                /*
                 * Given the user enters "<value>" in the field
                 */
                theUserEnters$p1InTheField(value);
            }
        }
        """

    Scenario: Multiple outline parameters embedded in a single quoted text
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
        Feature: Multiple Embedded Parameters
          Scenario Outline: Test
            When the user sees "Hello <firstName> <lastName>" on the screen
            Examples:
              | firstName | lastName |
              | John      | Doe      |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Multiple Embedded Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theUserSees$p1OnTheScreen(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            firstName | lastName
                            John      | Doe
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String firstName, String lastName) {
                /*
                 * When the user sees "Hello <firstName> <lastName>" on the screen
                 */
                theUserSees$p1OnTheScreen("Hello <firstName> <lastName>"
                        .replaceAll("<firstName>", firstName)
                        .replaceAll("<lastName>", lastName));
            }
        }
        """

    Scenario: Outline parameter joined with text on the left (no space before)
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
        Feature: Joined Left
          Scenario Outline: Test
            Given the css class is "btn-<variant>"
            Examples:
              | variant |
              | primary |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Joined Left
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theCssClassIs$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            variant
                            primary
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String variant) {
                /*
                 * Given the css class is "btn-<variant>"
                 */
                theCssClassIs$p1("btn-<variant>"
                        .replaceAll("<variant>", variant));
            }
        }
        """

    Scenario: Outline parameter joined with text on the right (no space after)
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
        Feature: Joined Right
          Scenario Outline: Test
            Given the size is "<value>px"
            Examples:
              | value |
              | 16    |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Joined Right
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theSizeIs$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            value
                            16
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(Integer value) {
                /*
                 * Given the size is "<value>px"
                 */
                theSizeIs$p1("<value>px"
                        .replaceAll("<value>", value.toString()));
            }
        }
        """

    Scenario: Outline parameter joined with text on both sides (no spaces)
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
        Feature: Joined Both Sides
          Scenario Outline: Test
            Given the endpoint is "/api/<version>/users"
            Examples:
              | version |
              | v2      |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Joined Both Sides
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theEndpointIs$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            version
                            v2
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String version) {
                /*
                 * Given the endpoint is "/api/<version>/users"
                 */
                theEndpointIs$p1("/api/<version>/users"
                        .replaceAll("<version>", version));
            }
        }
        """

    Scenario: Multiple outline parameters joined with text without spaces
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
        Feature: Multiple Joined Parameters
          Scenario Outline: Test
            Given the address is "<host>:<port>"
            Examples:
              | host      | port |
              | localhost | 8080 |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Multiple Joined Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void theAddressIs$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            host      | port
                            localhost | 8080
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String host, Integer port) {
                /*
                 * Given the address is "<host>:<port>"
                 */
                theAddressIs$p1("<host>:<port>"
                        .replaceAll("<host>", host)
                        .replaceAll("<port>", port.toString()));
            }
        }
        """


