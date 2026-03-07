Feature: GeneratorOptionsDefaults
  As a developer configuring the code generator for my project
  I want default option values to be applied when no options are specified in the class hierarchy
  So that the generator produces sensible output even without explicit configuration

  Rule: Default options are used when no inheritance chain provides them
    The following default values are applied:
      | Option                                  | Default Value |
      | shouldBeAbstract                        | false         |
      | classSuffixIfConcrete                   | "Test"        |
      | classSuffixIfAbstract                   | "Scenarios"   |
      | addSourceLineNumbers                    | false         |
      | emptyScenarioBehavior                   | FAIL          |
      | emptyRuleBehavior                       | FAIL          |
      | tagForEmptyScenarios                    | "new"         |
      | tagForEmptyRules                        | "new"         |
      | addCucumberStepAnnotations              | false         |
      | placeGeneratedClassNextToAnnotatedClass | false         |
      | dataTableParameterType                  | LIST_OF_OBJECT_PARAMS |
      | enableCompositeSteps                    | false         |
      | useQualifiedEnumConstants               | false         |
      | useStepKeywordInStepMethodName          | false         |

    Scenario: No options defined in hierarchy
      Given the following base class:
      """
      package com.example;

      public abstract class BaseFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class TestFeature extends BaseFeature {
      }
      """
      And the following feature file:
      """
      Feature: Test
        Scenario: Simple test
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Test
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends TestFeature {
          public void userExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              userExists();
          }
      }
      """
