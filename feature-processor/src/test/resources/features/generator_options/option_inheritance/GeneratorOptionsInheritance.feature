Feature: GeneratorOptionsInheritance
  As a developer configuring the code generator for my project
  I want to be able to specify generator options via annotations on an ancestor of the class which is directly annotated with @Feature2JUnit
  So that I can maintain consistent generator configurations across multiple feature test classes by centralizing the options in a common base class

  Rule: Options defined on a superclass are inherited by subclasses

    Scenario: Single option inherited from direct superclass
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
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
      import io.cucumber.java.en.Given;
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
          @Given("^user exists$")
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

    Scenario: Multiple options inherited from direct superclass
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(
        addCucumberStepAnnotations = true,
        classSuffixIfAbstract = "TestCases"
      )
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
      import io.cucumber.java.en.Given;
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
          @Given("^user exists$")
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

    Scenario: Options inherited through multiple inheritance levels
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
      public abstract class GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      public abstract class ParentFeature extends GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class TestFeature extends ParentFeature {
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
      import io.cucumber.java.en.Given;
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
          @Given("^user exists$")
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

  Rule: Options on the annotated class override inherited options

    Scenario: Direct annotation overrides superclass option
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
      public abstract class BaseFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(addCucumberStepAnnotations = false)
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

    Scenario: Closer superclass takes precedence over distant ancestors
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
      public abstract class GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = false)
      public abstract class ParentFeature extends GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class TestFeature extends ParentFeature {
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

  Rule: Options can be partially overridden, with non-overridden options still inherited from the annotations on ancestor(s)
    For string-valued options (classSuffixIfConcrete, classSuffixIfAbstract, tagForEmptyScenarios,
    tagForEmptyRules), partial inheritance is supported: if a child annotation leaves a string
    option at its annotation-level default value, the parent's non-default value is preserved.
    Boolean options always take the value from the closest annotation in the hierarchy.

    Scenario: String option inherited when child annotation only changes boolean options
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(
        addCucumberStepAnnotations = true,
        classSuffixIfConcrete = "Spec"
      )
      public abstract class BaseFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(addCucumberStepAnnotations = false)
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
      public class TestFeatureSpec extends TestFeature {
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

    Scenario: String option from grandparent preserved through intermediate boolean-only annotation
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(classSuffixIfConcrete = "Spec")
      public abstract class GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
      public abstract class ParentFeature extends GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class TestFeature extends ParentFeature {
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
      import io.cucumber.java.en.Given;
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
      public class TestFeatureSpec extends TestFeature {
          @Given("^user exists$")
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

    Scenario: Child's non-default string value overrides one ancestor option while inheriting another
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(
        classSuffixIfConcrete = "Spec",
        tagForEmptyScenarios = "pending"
      )
      public abstract class GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      public abstract class ParentFeature extends GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(classSuffixIfConcrete = "Cases")
      public abstract class TestFeature extends ParentFeature {
      }
      """
      And the following feature file:
      """
      Feature: Test
        Scenario: Simple test
          Given user exists
        Scenario: Empty test
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
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Test
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureCases extends TestFeature {
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

          @Test
          @Order(2)
          @Tag("pending")
          @DisplayName("Scenario: Empty test")
          public void scenario_2() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

    Scenario: Options from three levels merge with child overriding one option from grandparent and one from parent
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(
        classSuffixIfConcrete = "Spec",
        addCucumberStepAnnotations = true
      )
      public abstract class GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnitOptions(
        tagForEmptyScenarios = "draft",
        addSourceLineNumbers = true
      )
      public abstract class ParentFeature extends GrandparentFeature {
      }
      """
      And the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(
        classSuffixIfConcrete = "Cases",
        tagForEmptyScenarios = "addSteps"
      )
      public abstract class TestFeature extends ParentFeature {
      }
      """
      And the following feature file:
      """
      Feature: Test
        Scenario: Simple test
          Given user exists
        Scenario: Empty test
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import io.cucumber.java.en.Given;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Test
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureCases extends TestFeature {
          @Given("^user exists$")
          public void userExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario [2]: Simple test")
          public void scenario_1() {
              /*
               * [3] Given user exists
               */
              userExists();
          }

          @Test
          @Order(2)
          @Tag("addSteps")
          @DisplayName("Scenario [4]: Empty test")
          public void scenario_2() {
              Assertions.fail("Scenario has no steps");
          }
      }
      """

