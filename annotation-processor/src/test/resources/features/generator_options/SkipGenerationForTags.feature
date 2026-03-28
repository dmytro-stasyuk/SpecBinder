Feature: SkipGenerationForTags
  As a test developer using Gherkin
  I want to exclude tagged Gherkin elements from code generation using regex patterns
  So that I can keep manual or work-in-progress scenarios in the specification without generating test code for them

  Rule: Scenarios tagged with a matching tag are excluded from the generated test class

    Scenario: scenario with exact matching tag is excluded
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with manual scenario

        @manual
        Scenario: Visual verification of report layout
          Given a printed report
          Then the layout matches the approved template
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: feature with manual scenario
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

    Scenario: only the tagged scenario is excluded while untagged scenarios remain
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with mixed scenarios

        Scenario: Automated login test
          Given user exists

        @manual
        Scenario: Visual verification of report layout
          Given a printed report
          Then the layout matches the approved template

        Scenario: Automated checkout test
          Given a shopping cart
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
       * Feature: feature with mixed scenarios
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void userExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Automated login test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              userExists();
          }

          public void aShoppingCart() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Automated checkout test")
          public void scenario_2() {
              /*
               * Given a shopping cart
               */
              aShoppingCart();
          }
      }
      """

  Rule: Rules tagged with a matching tag are excluded from the generated test class

    Scenario: rule with matching tag is excluded
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with tagged rule

        @manual
        Rule: Manual verification rules
          Scenario: Visual check
            Given a printed report

        Rule: Automated rules
          Scenario: API check
            Given an API endpoint
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
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with tagged rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void anApiEndpoint() {
              Assertions.fail("Step is not yet implemented");
          }

          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Automated rules")
          public class Rule_1 {
              @Test
              @Order(1)
              @DisplayName("Scenario: API check")
              public void scenario_1() {
                  /*
                   * Given an API endpoint
                   */
                  anApiEndpoint();
              }
          }
      }
      """

  Rule: Features tagged with a matching tag produce an empty generated test class

    Scenario: feature with matching tag generates empty class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      @manual
      Feature: Manual acceptance criteria
        Scenario: Visual inspection of dashboard
          Given a dashboard page
          Then the layout is correct
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Tag;

      /**
       * Feature: Manual acceptance criteria
       */
      @Tag("manual")
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

  Rule: Regex patterns in skipGenerationForTags are matched against tag names

    Scenario: regex pattern with wildcard matches tags with a common prefix
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"wip-.*"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with wip scenarios

        @wip-sprint-42
        Scenario: Work in progress scenario
          Given something unfinished

        Scenario: Completed scenario
          Given something finished
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
       * Feature: feature with wip scenarios
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void somethingFinished() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Completed scenario")
          public void scenario_1() {
              /*
               * Given something finished
               */
              somethingFinished();
          }
      }
      """

    Scenario: case-insensitive regex pattern matches tags regardless of case
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"(?i)ignore"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with case-variant tags

        @IGNORE
        Scenario: Uppercase ignored scenario
          Given something ignored

        @Ignore
        Scenario: Mixed case ignored scenario
          Given something also ignored

        Scenario: Normal scenario
          Given something normal
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
       * Feature: feature with case-variant tags
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void somethingNormal() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Normal scenario")
          public void scenario_1() {
              /*
               * Given something normal
               */
              somethingNormal();
          }
      }
      """

  Rule: Multiple patterns in skipGenerationForTags are combined with OR logic

    Scenario: element matching any of the patterns is excluded
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual", "wip-.*", "(?i)obsolete"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with various excluded tags

        @manual
        Scenario: Manual test
          Given manual verification

        @wip-sprint-99
        Scenario: Work in progress
          Given unfinished work

        @Obsolete
        Scenario: Obsolete scenario
          Given outdated functionality

        Scenario: Active automated test
          Given automated verification
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
       * Feature: feature with various excluded tags
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void automatedVerification() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Active automated test")
          public void scenario_1() {
              /*
               * Given automated verification
               */
              automatedVerification();
          }
      }
      """

  Rule: An element with multiple tags is excluded if any of its tags matches a pattern

    Scenario: scenario with one matching and one non-matching tag is excluded
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(skipGenerationForTags = {"manual"})
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with multi-tagged scenario

        @smoke @manual
        Scenario: Visual smoke test
          Given a visual check

        @smoke
        Scenario: Automated smoke test
          Given an automated check
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
       * Feature: feature with multi-tagged scenario
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void anAutomatedCheck() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @Tag("smoke")
          @DisplayName("Scenario: Automated smoke test")
          public void scenario_1() {
              /*
               * Given an automated check
               */
              anAutomatedCheck();
          }
      }
      """
