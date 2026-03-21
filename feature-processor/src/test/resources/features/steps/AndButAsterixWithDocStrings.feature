Feature: AndButAsterixWithDocStrings
  As a developer writing feature files with And, But, and * keywords
  I want the generator to correctly handle DocString parameters on these steps
  So that inherited keyword steps with DocStrings produce correct method signatures and calls

  Rule: And, But, and * steps with DocStrings generate correct method signatures and calls
  - the DocString parameter is added as the last parameter of type String named "docString"
  - the step method name is derived from the step text (without the keyword)
  - the keyword inheritance works the same way as for steps without DocStrings

    Scenario: And step with DocString inherits from Given
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
        Feature: And DocString Given
          Scenario: Test
            Given system is initialized
            And configuration is set:
              \"\"\"
              {
                "mode": "test",
                "debug": true
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
         * Feature: And DocString Given
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void systemIsInitialized() {
                Assertions.fail("Step is not yet implemented");
            }

            public void configurationIsSet(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given system is initialized
                 */
                systemIsInitialized();
                /*
                 * And configuration is set:
                 */
                configurationIsSet(\"\"\"
                        {
                          "mode": "test",
                          "debug": true
                        }
                        \"\"\");
            }
        }
        """

    Scenario: But step with DocString inherits from When
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
        Feature: But DocString When
          Scenario: Test
            When request is sent
            But response should not contain:
              \"\"\"
              {
                "error": "unauthorized"
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
         * Feature: But DocString When
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void requestIsSent() {
                Assertions.fail("Step is not yet implemented");
            }

            public void responseShouldNotContain(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When request is sent
                 */
                requestIsSent();
                /*
                 * But response should not contain:
                 */
                responseShouldNotContain(\"\"\"
                        {
                          "error": "unauthorized"
                        }
                        \"\"\");
            }
        }
        """

    Scenario: Asterisk step with DocString inherits from Then
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
        Feature: Asterisk DocString Then
          Scenario: Test
            Then result is verified
            * additional output is:
              \"\"\"
              Expected output line 1
              Expected output line 2
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
         * Feature: Asterisk DocString Then
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void resultIsVerified() {
                Assertions.fail("Step is not yet implemented");
            }

            public void additionalOutputIs(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then result is verified
                 */
                resultIsVerified();
                /*
                 * * additional output is:
                 */
                additionalOutputIs(\"\"\"
                        Expected output line 1
                        Expected output line 2
                        \"\"\");
            }
        }
        """

    Scenario: Multiple And steps where some have DocStrings and some do not
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
        Feature: Mixed And DocStrings
          Scenario: Test
            Given user exists
            And user profile is:
              \"\"\"
              {
                "name": "Alice",
                "role": "admin"
              }
              \"\"\"
            And user is active
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
         * Feature: Mixed And DocStrings
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userProfileIs(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user profile is:
                 */
                userProfileIs(\"\"\"
                        {
                          "name": "Alice",
                          "role": "admin"
                        }
                        \"\"\");
                /*
                 * And user is active
                 */
                userIsActive();
            }
        }
        """

    Scenario: And step with DocString and quoted parameters
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
        Feature: And DocString With Params
          Scenario: Test
            Given system is ready
            And user "Alice" submits document:
              \"\"\"
              Title: My Report
              Content: This is the report body.
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
         * Feature: And DocString With Params
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void systemIsReady() {
                Assertions.fail("Step is not yet implemented");
            }

            public void user$p1SubmitsDocument(String p1, String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given system is ready
                 */
                systemIsReady();
                /*
                 * And user "Alice" submits document:
                 */
                user$p1SubmitsDocument("Alice", \"\"\"
                        Title: My Report
                        Content: This is the report body.
                        \"\"\");
            }
        }
        """

  Rule: And, But, and * steps with DocStrings work correctly in Scenario Outlines
  - DocString content may contain <param> placeholders from the Examples table
  - replaceAll calls are generated at the call site for referenced parameters
  - keyword inheritance works the same as in regular Scenarios

    Scenario: And step with DocString containing example parameters in Scenario Outline
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
        Feature: And DocString Outline
          Scenario Outline: Test
            Given user "<username>" is created
            And user profile is:
              \"\"\"
              {
                "name": "<username>",
                "role": "<role>"
              }
              \"\"\"

          Examples:
            | username | role  |
            | Alice    | admin |
            | Bob      | user  |
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
         * Feature: And DocString Outline
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1IsCreated(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void userProfileIs(String docString) {
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
                            Alice    | admin
                            Bob      | user
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username, String role) {
                /*
                 * Given user "<username>" is created
                 */
                user$p1IsCreated(username);
                /*
                 * And user profile is:
                 */
                userProfileIs(\"\"\"
                        {
                          "name": "<username>",
                          "role": "<role>"
                        }
                        \"\"\"
                        .replaceAll("<username>", username)
                        .replaceAll("<role>", role));
            }
        }
        """

    Scenario: But step with DocString containing example parameters in Scenario Outline
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
        Feature: But DocString Outline
          Scenario Outline: Test
            When user "<username>" logs in
            But error response should not be:
              \"\"\"
              {
                "error": "User <username> is blocked",
                "code": "<errorCode>"
              }
              \"\"\"

          Examples:
            | username | errorCode |
            | Alice    | 403       |
            | Bob      | 401       |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
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
         * Feature: But DocString Outline
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1LogsIn(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void errorResponseShouldNotBe(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | errorCode
                            Alice    | 403
                            Bob      | 401
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username, Integer errorCode) {
                /*
                 * When user "<username>" logs in
                 */
                user$p1LogsIn(username);
                /*
                 * But error response should not be:
                 */
                errorResponseShouldNotBe(\"\"\"
                        {
                          "error": "User <username> is blocked",
                          "code": "<errorCode>"
                        }
                        \"\"\"
                        .replaceAll("<username>", username)
                        .replaceAll("<errorCode>", errorCode.toString()));
            }
        }
        """

    Scenario: Asterisk step with DocString containing example parameters in Scenario Outline
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
        Feature: Asterisk DocString Outline
          Scenario Outline: Test
            Given setup is done
            * expected output is:
              \"\"\"
              Result for <item>: <status>
              \"\"\"

          Examples:
            | item   | status  |
            | order  | shipped |
            | refund | pending |
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
         * Feature: Asterisk DocString Outline
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            public void expectedOutputIs(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            item   | status
                            order  | shipped
                            refund | pending
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String item, String status) {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * * expected output is:
                 */
                expectedOutputIs(\"\"\"
                        Result for <item>: <status>
                        \"\"\"
                        .replaceAll("<item>", item)
                        .replaceAll("<status>", status));
            }
        }
        """

    Scenario: Mixed And, But, and * steps with DocStrings in Scenario Outline with partial parameter usage
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
        Feature: Mixed Keywords DocString Outline
          Scenario Outline: Test
            Given user "<username>" is registered
            And user settings are:
              \"\"\"
              {
                "theme": "dark",
                "language": "en"
              }
              \"\"\"
            When user performs "<action>"
            But response should not contain:
              \"\"\"
              {
                "error": "Action <action> denied for <username>"
              }
              \"\"\"
            * confirmation message is:
              \"\"\"
              Action <action> completed successfully.
              \"\"\"

          Examples:
            | username | action |
            | Alice    | delete |
            | Bob      | update |
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
         * Feature: Mixed Keywords DocString Outline
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1IsRegistered(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void userSettingsAre(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void userPerforms$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void responseShouldNotContain(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            public void confirmationMessageIs(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            username | action
                            Alice    | delete
                            Bob      | update
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test")
            public void scenario_1(String username, String action) {
                /*
                 * Given user "<username>" is registered
                 */
                user$p1IsRegistered(username);
                /*
                 * And user settings are:
                 */
                userSettingsAre(\"\"\"
                        {
                          "theme": "dark",
                          "language": "en"
                        }
                        \"\"\");
                /*
                 * When user performs "<action>"
                 */
                userPerforms$p1(action);
                /*
                 * But response should not contain:
                 */
                responseShouldNotContain(\"\"\"
                        {
                          "error": "Action <action> denied for <username>"
                        }
                        \"\"\"
                        .replaceAll("<username>", username)
                        .replaceAll("<action>", action));
                /*
                 * * confirmation message is:
                 */
                confirmationMessageIs(\"\"\"
                        Action <action> completed successfully.
                        \"\"\"
                        .replaceAll("<action>", action));
            }
        }
        """
