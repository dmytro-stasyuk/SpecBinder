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

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
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

        import dev.specbinder.annotations.output.FeatureFilePath;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUser$p1Exists(String p1) {
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
                givenUser$p1Exists(username);
            }
        }
        """

    Scenario: Step with multiple scenario outline parameters
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

        import dev.specbinder.annotations.output.FeatureFilePath;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUser$p1SendsMessage$p2To$p3(String p1, String p2, String p3) {
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
                whenUser$p1SendsMessage$p2To$p3(username, message, recipient);
            }
        }
        """

    Scenario: Step mixing quoted parameters and scenario outline parameters
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

        import dev.specbinder.annotations.output.FeatureFilePath;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUser$p1AssignsRole$p2ToUser$p3(String p1, String p2, String p3) {
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
                givenUser$p1AssignsRole$p2ToUser$p3("admin", role, username);
            }
        }
        """


