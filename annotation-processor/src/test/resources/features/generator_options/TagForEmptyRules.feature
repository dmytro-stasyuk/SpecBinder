Feature: TagForEmptyRules
  As a test developer using Gherkin
  I want to configure the tag applied to empty Rules (Rules without scenarios)
  So that I can categorize incomplete specifications with custom tags

  Rule: Empty Rules can be tagged with a custom tag using the "tagForEmptyRules" option

    Scenario: Empty rule with custom tag
      Given the following base class:
      """
      package com.example.payment;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(
        tagForEmptyRules = "incomplete"
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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/payment/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @Tag("incomplete")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Authorization rules")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

  Rule: When "tagForEmptyRules" is not set, empty Rules get a default tag "new"

    Scenario: Empty rule with default tag
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty rule

        Rule: Payment rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Payment rules")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

    Scenario: Empty rule with tag disabled
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(
        tagForEmptyRules = ""
      )
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with empty rule

        Rule: Payment rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

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
       * Feature: feature with empty rule
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Payment rules")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """

    Scenario: Multiple empty rules with default tag
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public class TestFeature {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: feature with multiple empty rules

        Rule: Payment rules

        Rule: Shipping rules
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

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
       * Feature: feature with multiple empty rules
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestClassOrder(ClassOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          @Nested
          @Order(1)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Payment rules")
          public class Rule_1 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }

          @Nested
          @Order(2)
          @Tag("new")
          @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
          @DisplayName("Rule: Shipping rules")
          public class Rule_2 {
              @Test
              public void noScenariosInRule() {
                  Assertions.fail("Rule doesn't have any scenarios");
              }
          }
      }
      """