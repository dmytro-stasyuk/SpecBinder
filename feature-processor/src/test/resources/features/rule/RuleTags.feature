Feature: RuleTags
  As a test developer using Gherkin
  I want Gherkin tags on Rules to be converted to JUnit @Tag annotations
  So that I can filter and organize test execution by rule categories

  Rule: Single tag on a Rule is converted to a single JUnit @Tag annotation on the nested class

    Scenario: Rule with single tag
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with tagged rule

        @validation
        Rule: Input validation rules
          Scenario: Validate email format
            Given an email address
            When validation is performed
            Then the email format should be valid
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
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
       * Feature: feature with tagged rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void anEmailAddress() {
              Assertions.fail("Step is not yet implemented");
          }

          public void validationIsPerformed() {
              Assertions.fail("Step is not yet implemented");
          }

          public void theEmailFormatShouldBeValid() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @Tag("validation")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Input validation rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @DisplayName("Scenario: Validate email format")
              public void scenario_1() {
                  /*
                   * Given an email address
                   */
                  anEmailAddress();
                  /*
                   * When validation is performed
                   */
                  validationIsPerformed();
                  /*
                   * Then the email format should be valid
                   */
                  theEmailFormatShouldBeValid();
              }
          }
      }
      """

  Rule: Multiple tags on a Rule are converted to a @Tags container annotation with an array of @Tag annotations

    Scenario: Rule with multiple tags
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
      Feature: feature with multi-tagged rule

        @validation @important @security
        Rule: Security validation rules
          Scenario: Validate password strength
            Given a password
            When strength validation is performed
            Then the password should meet requirements
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with multi-tagged rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void aPassword() {
              Assertions.fail("Step is not yet implemented");
          }

          public void strengthValidationIsPerformed() {
              Assertions.fail("Step is not yet implemented");
          }

          public void thePasswordShouldMeetRequirements() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @Tags({
                  @Tag("validation"),
                  @Tag("important"),
                  @Tag("security")
          })
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Security validation rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @DisplayName("Scenario: Validate password strength")
              public void scenario_1() {
                  /*
                   * Given a password
                   */
                  aPassword();
                  /*
                   * When strength validation is performed
                   */
                  strengthValidationIsPerformed();
                  /*
                   * Then the password should meet requirements
                   */
                  thePasswordShouldMeetRequirements();
              }
          }
      }
      """

  Rule: Rule tags are independent of Feature-level tags and only apply to the nested Rule class

    Scenario: Feature with tags and Rule with different tags
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      @feature-level @smoke
      Feature: feature with both feature and rule tags

        @rule-level @validation
        Rule: Validation rules
          Scenario: Validate input
            Given valid input
            When validation runs
            Then input should be accepted
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with both feature and rule tags
       */
      @Tags({
              @Tag("feature-level"),
              @Tag("smoke")
      })
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void validInput() {
              Assertions.fail("Step is not yet implemented");
          }

          public void validationRuns() {
              Assertions.fail("Step is not yet implemented");
          }

          public void inputShouldBeAccepted() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @Tags({
                  @Tag("rule-level"),
                  @Tag("validation")
          })
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Validation rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @DisplayName("Scenario: Validate input")
              public void scenario_1() {
                  /*
                   * Given valid input
                   */
                  validInput();
                  /*
                   * When validation runs
                   */
                  validationRuns();
                  /*
                   * Then input should be accepted
                   */
                  inputShouldBeAccepted();
              }
          }
      }
      """

