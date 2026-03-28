Feature: BackgroundWithDocString
  As a spec2junit user
  I want the generator to convert Background steps with DocStrings into @BeforeEach methods with String parameters
  So that I can set up multi-line test data before each scenario with compile-time type safety

  Rule: Background steps with DocStrings should generate methods accepting String parameter

    Scenario: Background with a DocString step
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
      Feature: API testing
        Background:
          Given the server responds with:
            \"\"\"
            {
              "status": "ok",
              "version": "1.0"
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
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.TestInfo;

      /**
       * Feature: API testing
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void theServerRespondsWith(String docString) {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given the server responds with:
               */
              theServerRespondsWith(\"\"\"
                      {
                        "status": "ok",
                        "version": "1.0"
                      }
                      \"\"\");
          }
      }
      """

    Scenario: Background with multiple steps including DocString
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
      Feature: email testing
        Background:
          Given the email service is available
          And the email template is:
            \"\"\"
            Dear User,
            Welcome to our service!
            \"\"\"
          And email sending is enabled
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.TestInfo;

      /**
       * Feature: email testing
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void theEmailServiceIsAvailable() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theEmailTemplateIs(String docString) {
              Assertions.fail("Step is not yet implemented");
          }

          public void emailSendingIsEnabled() {
              Assertions.fail("Step is not yet implemented");
          }

          @BeforeEach
          @DisplayName("Background:")
          public void featureBackground(TestInfo testInfo) {
              /*
               * Given the email service is available
               */
              theEmailServiceIsAvailable();
              /*
               * And the email template is:
               */
              theEmailTemplateIs(\"\"\"
                      Dear User,
                      Welcome to our service!
                      \"\"\");
              /*
               * And email sending is enabled
               */
              emailSendingIsEnabled();
          }
      }
      """
