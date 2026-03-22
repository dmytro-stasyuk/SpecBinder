Feature: StepMethodJavaDocComments
  As a developer
  I want JavaDoc comments above step method calls to preserve the original Gherkin step text
  So that I can trace generated method calls back to their original feature file steps easier

  Rule: JavaDoc comments in method calls preserve the original Gherkin step text exactly as written
  - each step call is preceded by a JavaDoc comment
  - the comment contains the complete step keyword and text
  - And, But, and * keywords are preserved in comments (not replaced with inherited keyword)

    Scenario: JavaDoc comment preserves exact step text including keyword
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
        Feature: JavaDoc Preservation
          Scenario: Test
            Given user "Alice" exists
            When user clicks "Submit" button
            Then message "Success" is displayed
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
         * Feature: JavaDoc Preservation
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicks$p1Button(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void message$p1IsDisplayed(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                user$p1Exists("Alice");
                /*
                 * When user clicks "Submit" button
                 */
                userClicks$p1Button("Submit");
                /*
                 * Then message "Success" is displayed
                 */
                message$p1IsDisplayed("Success");
            }
        }
        """

    Scenario: JavaDoc comment preserves And keyword in original form
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
        Feature: And Keyword Preservation
          Scenario: Test
            Given user exists
            And user is active
            And user has permissions
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: And Keyword Preservation
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userHasPermissions() {
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
                 * And user is active
                 */
                userIsActive();
                /*
                 * And user has permissions
                 */
                userHasPermissions();
            }
        }
        """

    Scenario: JavaDoc comment preserves But keyword in original form
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
        Feature: But Keyword Preservation
          Scenario: Test
            Then username is visible
            But password is not visible
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: But Keyword Preservation
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void usernameIsVisible() {
                Assertions.fail("Step is not yet implemented");
            }

            public void passwordIsNotVisible() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then username is visible
                 */
                usernameIsVisible();
                /*
                 * But password is not visible
                 */
                passwordIsNotVisible();
            }
        }
        """

    Scenario: JavaDoc comment preserves asterisk keyword in original form
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
        Feature: Asterisk Preservation
          Scenario: Test
            Given system is ready
            * database is connected
            * cache is warm
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Asterisk Preservation
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void systemIsReady() {
                Assertions.fail("Step is not yet implemented");
            }

            public void databaseIsConnected() {
                Assertions.fail("Step is not yet implemented");
            }

            public void cacheIsWarm() {
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
                 * * database is connected
                 */
                databaseIsConnected();
                /*
                 * * cache is warm
                 */
                cacheIsWarm();
            }
        }
        """
