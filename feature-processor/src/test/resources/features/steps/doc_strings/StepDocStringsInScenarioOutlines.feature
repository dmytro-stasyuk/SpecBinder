Feature: StepDocStringsInScenarioOutlines
  As a developer
  I want Gherkin DocStrings to be mapped to String parameters in generated step methods
  So that I can work with multi-line text content in my tests

  Rule: Scenario Outline parameters are replaced in DocStrings
  - angle bracket parameters <param> in DocStrings are replaced with values which come from the method parameters
  - the replacement happens at the method call site, not in the method signature
  - DocString parameter type remains String in method signature
  - each example row gets its own DocString with substituted values

    Scenario: Scenario Outline with DocString containing one parameter
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
        Feature: Template Messages
          Scenario Outline: Send template message
            When user sends message:
              \"\"\"
              Hello <recipient>,

              This is an automated message.
              \"\"\"

          Examples:
            | recipient |
            | Alice     |
            | Bob       |
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
         * Feature: Template Messages
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUserSendsMessage(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            recipient
                            Alice
                            Bob
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Send template message")
            public void scenario_1(String recipient) {
                /*
                 * When user sends message:
                 */
                whenUserSendsMessage(\"\"\"
                        Hello <recipient>,

                        This is an automated message.
                        \"\"\"
                        .replaceAll("<recipient>", recipient));
            }
        }
        """

    Scenario: Scenario Outline with DocString containing multiple parameters
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
        Feature: Email Templates
          Scenario Outline: Generate email
            Given email template:
              \"\"\"
              From: <sender>
              To: <recipient>
              Subject: <subject>

              Dear <recipient>,

              <body>

              Regards,
              <sender>
              \"\"\"

          Examples:
            | sender | recipient | subject       | body               |
            | Alice  | Bob       | Meeting       | See you tomorrow   |
            | Carol  | Dave      | Project Update| Status is green    |
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
         * Feature: Email Templates
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenEmailTemplate(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            sender | recipient | subject        | body
                            Alice  | Bob       | Meeting        | See you tomorrow
                            Carol  | Dave      | Project Update | Status is green
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Generate email")
            public void scenario_1(String sender, String recipient, String subject, String body) {
                /*
                 * Given email template:
                 */
                givenEmailTemplate(\"\"\"
                        From: <sender>
                        To: <recipient>
                        Subject: <subject>

                        Dear <recipient>,

                        <body>

                        Regards,
                        <sender>
                        \"\"\"
                        .replaceAll("<sender>", sender)
                        .replaceAll("<recipient>", recipient)
                        .replaceAll("<subject>", subject)
                        .replaceAll("<body>", body));
            }
        }
        """

    Scenario: Scenario Outline mixing quoted parameters and DocString with placeholders
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
        Feature: Notifications
          Scenario Outline: User receives notification
            When user "admin" sends notification of type "<type>" with message:
              \"\"\"
              Notification: <type>

              <message>
              \"\"\"

          Examples:
            | type    | message                |
            | warning | System will restart    |
            | info    | Update available       |
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
         * Feature: Notifications
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUser$p1SendsNotificationOfType$p2WithMessage(String p1, String p2,
                    String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            type    | message
                            warning | System will restart
                            info    | Update available
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: User receives notification")
            public void scenario_1(String type, String message) {
                /*
                 * When user "admin" sends notification of type "<type>" with message:
                 */
                whenUser$p1SendsNotificationOfType$p2WithMessage("admin", type, \"\"\"
                        Notification: <type>

                        <message>
                        \"\"\"
                        .replaceAll("<type>", type)
                        .replaceAll("<message>", message));
            }
        }
        """

    Scenario: Scenario Outline parameters in DocStrings with columns names containing spaces
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
        Feature: Notifications
          Scenario Outline: User receives notification
            When user "admin" sends notification of type <dialog type> with message:
              \"\"\"
              Notification: <dialog type>

              <message text>
              \"\"\"

          Examples:
            | dialog type | message text        |
            | warning     | System will restart |
            | info        | Update available    |
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
         * Feature: Notifications
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUser$p1SendsNotificationOfType$p2WithMessage(String p1, String p2,
                    String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            dialog type | message text
                            warning     | System will restart
                            info        | Update available
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: User receives notification")
            public void scenario_1(String dialogType, String messageText) {
                /*
                 * When user "admin" sends notification of type <dialog type> with message:
                 */
                whenUser$p1SendsNotificationOfType$p2WithMessage("admin", dialogType, \"\"\"
                        Notification: <dialog type>

                        <message text>
                        \"\"\"
                        .replaceAll("<dialog type>", dialogType)
                        .replaceAll("<message text>", messageText));
            }
        }
        """

  Rule: when a Scenario Outline has some steps that make use of values from examples table while
  a step with a docstring parameter doesn't use any example value, then the replacement at call site for the step
  with docstring is not necessary and should not be added in generated class, i.e. no need to call replaceAll
  for examples table column values where docstring doesn't contain any references to them

    Scenario: DocString with no parameter references while other step uses example values
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
        Feature: Static Messages
          Scenario Outline: Process transaction
            Given system configuration:
              \"\"\"
              {
                "logging": true,
                "notifications": true,
                "timeout": 30
              }
              \"\"\"
            When user "<username>" performs transaction of type "<type>"

          Examples:
            | username | type     |
            | Alice    | deposit  |
            | Bob      | withdraw |
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
         * Feature: Static Messages
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenSystemConfiguration(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUser$p1PerformsTransactionOfType$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | type
                            Alice    | deposit
                            Bob      | withdraw
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Process transaction")
            public void scenario_1(String username, String type) {
                /*
                 * Given system configuration:
                 */
                givenSystemConfiguration(\"\"\"
                        {
                          "logging": true,
                          "notifications": true,
                          "timeout": 30
                        }
                        \"\"\");
                /*
                 * When user "<username>" performs transaction of type "<type>"
                 */
                whenUser$p1PerformsTransactionOfType$p2(username, type);
            }
        }
        """

    Scenario: multiple steps where only some DocStrings reference example parameters
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
        Feature: Mixed DocStrings
          Scenario Outline: Configure and send message
            Given default configuration:
              \"\"\"
              {
                "mode": "production",
                "debug": false
              }
              \"\"\"
            When message is sent to "<recipient>" with content:
              \"\"\"
              Hello <recipient>,
              This is a test message.
              \"\"\"

          Examples:
            | recipient |
            | Alice     |
            | Bob       |
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
         * Feature: Mixed DocStrings
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenDefaultConfiguration(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenMessageIsSentTo$p1WithContent(String p1, String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            recipient
                            Alice
                            Bob
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Configure and send message")
            public void scenario_1(String recipient) {
                /*
                 * Given default configuration:
                 */
                givenDefaultConfiguration(\"\"\"
                        {
                          "mode": "production",
                          "debug": false
                        }
                        \"\"\");
                /*
                 * When message is sent to "<recipient>" with content:
                 */
                whenMessageIsSentTo$p1WithContent(recipient, \"\"\"
                        Hello <recipient>,
                        This is a test message.
                        \"\"\"
                        .replaceAll("<recipient>", recipient));
            }
        }
        """

    Scenario: DocString references only some of the example parameters
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
        Feature: Partial Parameter Usage
          Scenario Outline: Send notification
            Given notification template:
              \"\"\"
              Subject: Account Update for <username>

              Dear <username>,

              Your account has been updated.

              Best regards,
              Support Team
              \"\"\"
            When action "<action>" is performed with priority "<priority>"

          Examples:
            | username | action | priority |
            | Alice    | update | high     |
            | Bob      | delete | low      |
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
         * Feature: Partial Parameter Usage
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenNotificationTemplate(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenAction$p1IsPerformedWithPriority$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | action | priority
                            Alice    | update | high
                            Bob      | delete | low
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Send notification")
            public void scenario_1(String username, String action, String priority) {
                /*
                 * Given notification template:
                 */
                givenNotificationTemplate(\"\"\"
                        Subject: Account Update for <username>

                        Dear <username>,

                        Your account has been updated.

                        Best regards,
                        Support Team
                        \"\"\"
                        .replaceAll("<username>", username));
                /*
                 * When action "<action>" is performed with priority "<priority>"
                 */
                whenAction$p1IsPerformedWithPriority$p2(action, priority);
            }
        }
        """




