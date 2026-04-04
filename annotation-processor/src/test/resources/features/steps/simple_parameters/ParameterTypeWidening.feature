Feature: ParameterTypeWidening
  As a test developer using Gherkin steps with parameters
  I want step parameter types to be widened when the same step appears across multiple scenarios with incompatible values
  So that the generated step method uses a type that accommodates all parameter values
  - When the same step pattern appears in multiple scenarios, the parameter type must accommodate all values
  - Type inference considers all occurrences of the same step across all scenarios in a feature
  - The widest common type is selected so that every occurrence's value is valid for the method signature
  - Type checking follows precedence order: Boolean, Integer, Long, Double, Character, then String
  - A type is selected only if ALL values across all occurrences can convert to it

  Rule: Character is widened to String when a multi-character value appears in another scenario
  - A single-character value alone would infer Character
  - But if the same step also appears with a multi-character value, String is used instead

    Scenario: Same step with single-character value first and multi-character value later
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
      Feature: Character Then String Mismatch
        Scenario: First scenario
          Given output directory is "."
        Scenario: Second scenario
          Given output directory is "target/generated-test-sources"
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
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Character Then String Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void outputDirectoryIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given output directory is "."
               */
              outputDirectoryIs$p1(".");
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given output directory is "target/generated-test-sources"
               */
              outputDirectoryIs$p1("target/generated-test-sources");
          }
      }
      """

    Scenario: Same step with multi-character value first and single-character value later
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
      Feature: String Then Character Mismatch
        Scenario: First scenario
          Given output directory is "target/generated-test-sources"
        Scenario: Second scenario
          Given output directory is "."
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
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: String Then Character Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void outputDirectoryIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given output directory is "target/generated-test-sources"
               */
              outputDirectoryIs$p1("target/generated-test-sources");
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given output directory is "."
               */
              outputDirectoryIs$p1(".");
          }
      }
      """

  Rule: Integer is widened to String when a non-numeric value appears in another scenario
  - A numeric value alone would infer Integer
  - But if the same step also appears with a non-numeric value, String is used instead

    Scenario: Same step with integer value and string value widens to String
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
      Feature: Integer Then String Mismatch
        Scenario: First scenario
          Given retry count is "3"
        Scenario: Second scenario
          Given retry count is "unlimited"
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
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Integer Then String Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void retryCountIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given retry count is "3"
               */
              retryCountIs$p1("3");
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given retry count is "unlimited"
               */
              retryCountIs$p1("unlimited");
          }
      }
      """

  Rule: Integer is widened to Long when a value exceeds Integer range in another scenario
  - An int-range value alone would infer Integer
  - But if the same step also appears with a value that exceeds Integer range but fits Long, Long is used

    Scenario: Same step with integer value and long value widens to Long
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
      Feature: Integer Then Long Mismatch
        Scenario: First scenario
          Given record count is "42"
        Scenario: Second scenario
          Given record count is "9999999999"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Long;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Integer Then Long Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void recordCountIs$p1(Long p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given record count is "42"
               */
              recordCountIs$p1(42L);
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given record count is "9999999999"
               */
              recordCountIs$p1(9999999999L);
          }
      }
      """

  Rule: Integer is widened to Double when a decimal value appears in another scenario
  - An integer value alone would infer Integer
  - But if the same step also appears with a decimal value, Double is used

    Scenario: Same step with integer value and double value widens to Double
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
      Feature: Integer Then Double Mismatch
        Scenario: First scenario
          Given threshold is "5"
        Scenario: Second scenario
          Given threshold is "3.14"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Double;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Integer Then Double Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void thresholdIs$p1(Double p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given threshold is "5"
               */
              thresholdIs$p1(5.0);
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given threshold is "3.14"
               */
              thresholdIs$p1(3.14);
          }
      }
      """

  Rule: Boolean is widened to String when a non-boolean value appears in another scenario
  - A boolean value alone would infer Boolean
  - But if the same step also appears with a non-boolean value, String is used

    Scenario: Same step with boolean value and string value widens to String
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
      Feature: Boolean Then String Mismatch
        Scenario: First scenario
          Given verbose mode is "true"
        Scenario: Second scenario
          Given verbose mode is "auto"
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
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Boolean Then String Mismatch
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void verboseModeIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given verbose mode is "true"
               */
              verboseModeIs$p1("true");
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given verbose mode is "auto"
               */
              verboseModeIs$p1("auto");
          }
      }
      """

  Rule: No widening occurs when all occurrences have compatible values
  - If all values across scenarios convert to the same type, no widening is needed
  - The narrowest common type is preserved

    Scenario: Same step with all integer values keeps Integer type
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
      Feature: All Integer Values
        Scenario: First scenario
          Given max retries is "3"
        Scenario: Second scenario
          Given max retries is "10"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Integer;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: All Integer Values
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void maxRetriesIs$p1(Integer p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given max retries is "3"
               */
              maxRetriesIs$p1(3);
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given max retries is "10"
               */
              maxRetriesIs$p1(10);
          }
      }
      """

    Scenario: Same step with all single-character values keeps Character type
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
      Feature: All Character Values
        Scenario: First scenario
          Given delimiter is "."
        Scenario: Second scenario
          Given delimiter is ","
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.Character;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: All Character Values
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void delimiterIs$p1(Character p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: First scenario")
          public void scenario_1() {
              /*
               * Given delimiter is "."
               */
              delimiterIs$p1('.');
          }

          @Test
          @Order(2)
          @DisplayName("Scenario: Second scenario")
          public void scenario_2() {
              /*
               * Given delimiter is ","
               */
              delimiterIs$p1(',');
          }
      }
      """
