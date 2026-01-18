Feature: StepMethodDeduplication
  As a developer
  I want the generator to detect and skip duplicate step method declarations
  So that I can reuse steps across scenarios and inherit step implementations from base classes without compilation errors

  Rule: same steps do not generate duplicate methods
  - Before adding a step method to the generated class, the generator checks if a method with the same name already exists
  - If the method exists in the current class, and if so it calls the already existing method
  - This prevents duplicate method declarations

    Scenario: Same step appears multiple times in one feature
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
        Feature: Duplicate Steps
          Scenario: First scenario
            Given user exists

          Scenario: Second scenario
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Duplicate Steps
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user exists
                 */
                givenUserExists();
            }
        }
        """

    Example: Step with 1 parameter appears multiple times in one feature
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
        Feature: Duplicate Steps
          Scenario: First scenario
            Given user "Alice" exists

          Scenario: Second scenario
            Given user "Bob" exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Duplicate Steps
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUser$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                givenUser$p1Exists("Alice");
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user "Bob" exists
                 */
                givenUser$p1Exists("Bob");
            }
        }
        """

    Example: Step with 2 parameters appears multiple times in one feature
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
        Feature: Duplicate Steps
          Scenario: First scenario
            Given user "Alice" with age "30" exists

          Scenario: Second scenario
            Given user "Bob" with age "25" exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Duplicate Steps
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUser$p1WithAge$p2Exists(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user "Alice" with age "30" exists
                 */
                givenUser$p1WithAge$p2Exists("Alice", "30");
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user "Bob" with age "25" exists
                 */
                givenUser$p1WithAge$p2Exists("Bob", "25");
            }
        }
        """
