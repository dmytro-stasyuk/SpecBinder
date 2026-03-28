Feature: DollarSignInBlockText
  As a developer
  I want to use dollar signs in the title and description text of Gherkin blocks
  So that the generator correctly handles them in JavaDoc comments and @DisplayName annotations

  Rule: A dollar sign in the Feature name and description should be preserved in the generated JavaDoc comment

    Scenario: Feature name contains a dollar sign
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
      Feature: costs $5 per item
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: costs $5 per item
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

    Scenario: Feature description contains dollar signs
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
      Feature: pricing
        Items cost $5 each
        Premium items cost $10 each
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: pricing
       *   Items cost $5 each
       *   Premium items cost $10 each
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

  Rule: A dollar sign in the Scenario name and description should be preserved in @DisplayName and JavaDoc

    Scenario: Scenario name contains a dollar sign
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
      Feature: pricing feature
        Scenario: item costs $5
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
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: item costs $5")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: Scenario description contains dollar signs
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
      Feature: pricing feature
        Scenario: pricing check
          Verify that $HOME expands to /users/$admin
          and costs are $5 per unit
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
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          /**
           * Verify that $HOME expands to /users/$admin
           * and costs are $5 per unit
           */
          @Test
          @Order(1)
          @Tag("new")
          @DisplayName("Scenario: pricing check")
          public void scenario_1() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

  Rule: A dollar sign in the Rule name and description should be preserved in @DisplayName and JavaDoc

    Scenario: Rule name contains a dollar sign
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
      Feature: pricing feature
        Rule: items under $10 get free shipping
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
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: items under $10 get free shipping")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

    Scenario: Rule description contains dollar signs
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
      Feature: pricing feature
        Rule: shipping policy
          Orders under $10 are charged $3 shipping
          Orders over $50 get free shipping
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
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          /**
           * Orders under $10 are charged $3 shipping
           * Orders over $50 get free shipping
           */
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: shipping policy")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

  Rule: A dollar sign in the Background name should be preserved in @DisplayName

    Scenario: Background name contains a dollar sign
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
      Feature: pricing feature

        Background: setup $5 account balance
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.BeforeEach;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.TestInfo;

      /**
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @BeforeEach
          @DisplayName("Background: setup $5 account balance")
          public void featureBackground(TestInfo testInfo) {
          }
      }
      """

  Rule: A dollar sign in the Scenario Outline Examples name should be preserved in generated code

    Scenario: Examples block name contains a dollar sign
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
      Feature: pricing feature
        Scenario Outline: purchase for <price>
          Given the price is <price>
          Examples: prices in $USD
            | price |
            | $5    |
            | $10   |
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
       * Feature: pricing feature
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void thePriceIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          price
                          $5
                          $10
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: purchase for <price>")
          public void scenario_1(String price) {
              /*
               * Given the price is <price>
               */
              thePriceIs$p1(price);
          }
      }
      """
