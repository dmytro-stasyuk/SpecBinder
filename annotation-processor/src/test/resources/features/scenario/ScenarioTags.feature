Feature: ScenarioTags
  As a test developer using Gherkin
  I want tags on Scenarios to be converted to JUnit @Tag annotations
  So that I can filter and selectively execute individual test methods

  Rule: Single tag on a Scenario is converted to a single JUnit @Tag annotation on the test method

    Scenario: Scenario with single tag
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
      Feature: feature with tagged scenario

        @critical
        Scenario: Process payment
          Given a payment request
          When payment is processed
          Then payment should succeed
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with tagged scenario
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void aPaymentRequest() {
              Assertions.fail("Step is not yet implemented");
          }

          public void paymentIsProcessed() {
              Assertions.fail("Step is not yet implemented");
          }

          public void paymentShouldSucceed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @Tag("critical")
          @DisplayName("Scenario: Process payment")
          public void scenario_1() {
              /*
               * Given a payment request
               */
              aPaymentRequest();
              /*
               * When payment is processed
               */
              paymentIsProcessed();
              /*
               * Then payment should succeed
               */
              paymentShouldSucceed();
          }
      }
      """

  Rule: Multiple tags on a Scenario are converted to a @Tags container annotation with an array of @Tag annotations

    Scenario: Scenario with multiple tags
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
      Feature: feature with multi-tagged scenario

        @critical @smoke @regression
        Scenario: Validate user login
          Given a user account
          When user logs in
          Then login should succeed
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with multi-tagged scenario
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void aUserAccount() {
              Assertions.fail("Step is not yet implemented");
          }

          public void userLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          public void loginShouldSucceed() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @Tags({
                  @Tag("critical"),
                  @Tag("smoke"),
                  @Tag("regression")
          })
          @DisplayName("Scenario: Validate user login")
          public void scenario_1() {
              /*
               * Given a user account
               */
              aUserAccount();
              /*
               * When user logs in
               */
              userLogsIn();
              /*
               * Then login should succeed
               */
              loginShouldSucceed();
          }
      }
      """

  Rule: Scenario tags are independent of Feature-level and Rule-level tags

    Scenario: Feature, Rule, and Scenario each have different tags
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
      @feature-tag
      Feature: feature with layered tags

        @rule-tag
        Rule: Processing rules
          @scenario-tag
          Scenario: Process transaction
            Given a transaction
            When processing occurs
            Then transaction completes
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with layered tags
       */
      @Tag("feature-tag")
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void aTransaction() {
              Assertions.fail("Step is not yet implemented");
          }

          public void processingOccurs() {
              Assertions.fail("Step is not yet implemented");
          }

          public void transactionCompletes() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @Tag("rule-tag")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Processing rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @Tag("scenario-tag")
              @DisplayName("Scenario: Process transaction")
              public void scenario_1() {
                  /*
                   * Given a transaction
                   */
                  aTransaction();
                  /*
                   * When processing occurs
                   */
                  processingOccurs();
                  /*
                   * Then transaction completes
                   */
                  transactionCompletes();
              }
          }
      }
      """

  Rule: Scenario tags apply only to the specific test method, not the entire class

    Scenario: Multiple scenarios with different tags in same class
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
      Feature: feature with differently tagged scenarios

        @critical
        Scenario: Critical test
          Given critical setup
          When critical action
          Then critical result

        @optional
        Scenario: Optional test
          Given optional setup
          When optional action
          Then optional result
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with differently tagged scenarios
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void criticalSetup() {
              Assertions.fail("Step is not yet implemented");
          }

          public void criticalAction() {
              Assertions.fail("Step is not yet implemented");
          }

          public void criticalResult() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @Tag("critical")
          @DisplayName("Scenario: Critical test")
          public void scenario_1() {
              /*
               * Given critical setup
               */
              criticalSetup();
              /*
               * When critical action
               */
              criticalAction();
              /*
               * Then critical result
               */
              criticalResult();
          }

          public void optionalSetup() {
              Assertions.fail("Step is not yet implemented");
          }

          public void optionalAction() {
              Assertions.fail("Step is not yet implemented");
          }

          public void optionalResult() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(2)
          @Tag("optional")
          @DisplayName("Scenario: Optional test")
          public void scenario_2() {
              /*
               * Given optional setup
               */
              optionalSetup();
              /*
               * When optional action
               */
              optionalAction();
              /*
               * Then optional result
               */
              optionalResult();
          }
      }
      """
