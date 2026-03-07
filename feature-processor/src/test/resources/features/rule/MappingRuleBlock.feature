Feature: MappingRuleBlock
  As a test developer using Gherkin
  I want Rules to be organized as nested test classes
  So that I can logically group and execute related scenarios together

  Rule: rule section should be mapped to nested inner class and rule name should be mapped to the value in display name annotation

    Scenario: with just the keyword
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
      Feature: feature with rule

        Rule:
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
       * Feature: feature with rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule:")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

    Scenario: with the keyword and name
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
      Feature: feature with rule

        Rule: rule name
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
       * Feature: feature with rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: rule name")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

  Rule: rule description lines should be mapped to JavaDoc comment on the nested inner test class

    Scenario: with the keyword, name and description lines
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
      Feature: feature with rule
        Rule: rule name
          rule description line 1
          rule description line 2
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
       * Feature: feature with rule
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          /**
           * rule description line 1
           * rule description line 2
           */
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: rule name")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """