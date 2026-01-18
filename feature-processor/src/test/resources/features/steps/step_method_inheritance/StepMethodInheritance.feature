Feature: StepMethodInheritance
  As a developer writing BDD tests with shared step implementations
  I want the generator to detect and reuse existing step methods from base classes
  So that I can define common step implementations in parent classes and avoid duplicate method declarations

  Rule: existing step methods in a class hierarchy do not generate duplicate methods
  - Before adding a step method to the generated class, the generator checks if a method with the same name already exists in the current class
  or on the class hierarchy, and if so it calls the already existing method
  - this enables specifying method implementation on a more abstract level in the class hierarchy

    Scenario: Step method already exists in base class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserExists() {
              // Implementation provided in base class
          }
      }
      """
      Given the following feature file:
        """
        Feature: Reuse Base Step
          Scenario: Login scenario
            Given user exists
            When user logs in
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
         * Feature: Reuse Base Step
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUserLogsIn() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Login scenario")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * When user logs in
                 */
                whenUserLogsIn();
            }
        }
        """

    Scenario: Multiple step methods exist in base class
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserExists() {
              // Implementation provided in base class
          }

          protected void whenUserLogsIn() {
              // Implementation provided in base class
          }
      }
      """
      Given the following feature file:
        """
        Feature: Reuse Multiple Base Steps
          Scenario: Complete workflow
            Given user exists
            When user logs in
            Then dashboard is displayed
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
         * Feature: Reuse Multiple Base Steps
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void thenDashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Complete workflow")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * When user logs in
                 */
                whenUserLogsIn();
                /*
                 * Then dashboard is displayed
                 */
                thenDashboardIsDisplayed();
            }
        }
        """

    Scenario: Step method exists in intermediate base class in hierarchy
      Given the following base class:
      """
      package features;

      public abstract class BaseSteps {
          protected void givenUserExists() {
              // Implementation in grandparent class
          }
      }
      """
      And the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature extends BaseSteps {
      }
      """
      Given the following feature file:
        """
        Feature: Multi-level Inheritance
          Scenario: Use inherited step
            Given user exists
            When user performs action
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
         * Feature: Multi-level Inheritance
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenUserPerformsAction() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Use inherited step")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * When user performs action
                 */
                whenUserPerformsAction();
            }
        }
        """

  Rule: step methods on the class hierarchy are considered a match only if that method has same number of parameters

    Scenario: Step with parameters matches base class method with same name and same number of parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserWithName$p1(String name) {
              // Implementation with parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Parameter Matching
          Scenario: Use step with parameter
            Given user with name "Alice"
            When action is performed
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
         * Feature: Parameter Matching
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void whenActionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Use step with parameter")
            public void scenario_1() {
                /*
                 * Given user with name "Alice"
                 */
                givenUserWithName$p1("Alice");
                /*
                 * When action is performed
                 */
                whenActionIsPerformed();
            }
        }
        """

    Scenario: Step with different parameter count creates new method
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
          protected void givenUserWithName(String name) {
              // Implementation with one parameter
          }
      }
      """
      Given the following feature file:
        """
        Feature: Different Parameter Count
          Scenario: Step with two parameters
            Given user with name "Bob" and age "30"
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
         * Feature: Different Parameter Count
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void givenUserWithName$p1AndAge$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Step with two parameters")
            public void scenario_1() {
                /*
                 * Given user with name "Bob" and age "30"
                 */
                givenUserWithName$p1AndAge$p2("Bob", "30");
            }
        }
        """





