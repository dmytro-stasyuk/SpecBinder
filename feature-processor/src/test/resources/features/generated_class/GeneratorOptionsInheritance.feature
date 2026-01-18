Feature: GeneratorOptionsInheritance
  As a developer configuring the code generator for my project
  I want to be able to specify generator options via annotations on a superclass of the class which is directly annotated with @Feature2JUnit
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
          }
      }
      """

    Scenario: Partial override - some options inherited, some overridden
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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
          }
      }
      """

  Rule: Default options are used when no inheritance chain provides them

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
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Simple test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
          }
      }
      """

