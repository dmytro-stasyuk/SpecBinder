Feature: EmptyRule
  As a test developer using Gherkin
  I want to configure how empty Rules (Rules without scenarios) are handled
  So that I can control test behavior and tag incomplete specifications

  Rule: Empty Rules generate a failing test method when failRulesWithNoScenarios option is enabled which by default
  is tagged with "new", or do not generate any test method when the option is disabled

    Scenario: where failRulesWithNoScenarios = enabled
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        failRulesWithNoScenarios = true
      )
      public class TestFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature with empty rule

        Rule: Processing rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.payment;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assumptions;
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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Processing rules")
          public class Rule_1 {
              @Test
              @Tag("new")
              public void noScenariosInRule() {
                  Assumptions.assumeTrue(false, "Rule has no scenarios");
              }
          }
      }
      """

    Scenario: where failRulesWithNoScenarios = disabled
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        failRulesWithNoScenarios = false
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/payment/TestFeature.feature" with the following content:
      """
      Feature: feature with empty rule

        Rule: Processing rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.payment;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.ClassOrderer;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Nested;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.TestClassOrder;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Processing rules")
          public class Rule_1 {
          }
      }
      """

  Rule: By default, empty Rules generate a failing test method

    Scenario: base class with default options i.e. no explicit Feature2JUnitOptions
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/payment/TestFeature.feature" with the following content:
      """
      Feature: feature with empty rule

        Rule: Validation rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.payment;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assumptions;
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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Validation rules")
          public class Rule_1 {
              @Test
              @Tag("new")
              public void noScenariosInRule() {
                  Assumptions.assumeTrue(false, "Rule has no scenarios");
              }
          }
      }
      """

  Rule: Empty Rules can be tagged with a custom tag using the tagForRulesWithNoScenarios option

    Scenario: Empty rule with custom tag
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        tagForRulesWithNoScenarios = "incomplete"
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/payment/TestFeature.feature" with the following content:
      """
      Feature: feature with empty rule

        Rule: Authorization rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.payment;
      
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assumptions;
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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Authorization rules")
          public class Rule_1 {
              @Test
              @Tag("incomplete")
              public void noScenariosInRule() {
                  Assumptions.assumeTrue(false, "Rule has no scenarios");
              }
          }
      }
      """