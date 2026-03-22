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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user exists
                 */
                userExists();
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
         * Feature: Duplicate Steps
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                user$p1Exists("Alice");
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user "Bob" exists
                 */
                user$p1Exists("Bob");
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

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1WithAge$p2Exists(String p1, Integer p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: First scenario")
            public void scenario_1() {
                /*
                 * Given user "Alice" with age "30" exists
                 */
                user$p1WithAge$p2Exists("Alice", 30);
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second scenario")
            public void scenario_2() {
                /*
                 * Given user "Bob" with age "25" exists
                 */
                user$p1WithAge$p2Exists("Bob", 25);
            }
        }
        """

  Rule: same step method text used with different keywords should not generate duplicate methods
  - When useStepKeywordInStepMethodName is false (default), Given/When/Then keywords are stripped from method names
  - Steps like "Given user exists" and "When user exists" produce the same method name "userExists()"
  - The generator deduplicates these and reuses the single method declaration

    Scenario: Same step text with Given and When keywords
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
        Feature: Different Keywords Same Step
          Scenario: Test
            Given user exists
            When user exists
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
         * Feature: Different Keywords Same Step
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
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When user exists
                 */
                userExists();
            }
        }
        """

    Scenario: Same step text with Given, When, and Then keywords
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
        Feature: All Three Keywords
          Scenario: Test
            Given user exists
            When user exists
            Then user exists
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
         * Feature: All Three Keywords
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
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * When user exists
                 */
                userExists();
                /*
                 * Then user exists
                 */
                userExists();
            }
        }
        """

    Scenario: Same parameterized step text with different keywords
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
        Feature: Parameterized Different Keywords
          Scenario: Test
            Given user "Alice" is active
            When user "Bob" is active
            Then user "Charlie" is active
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
         * Feature: Parameterized Different Keywords
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1IsActive(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "Alice" is active
                 */
                user$p1IsActive("Alice");
                /*
                 * When user "Bob" is active
                 */
                user$p1IsActive("Bob");
                /*
                 * Then user "Charlie" is active
                 */
                user$p1IsActive("Charlie");
            }
        }
        """

    Scenario: All keyword variants including And and But
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
        Feature: All Keyword Variants
          Scenario: Test
            Given user exists
            And user exists
            When user exists
            And user exists
            Then user exists
            And user exists
            But user exists
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
         * Feature: All Keyword Variants
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
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user exists
                 */
                userExists();
                /*
                 * When user exists
                 */
                userExists();
                /*
                 * And user exists
                 */
                userExists();
                /*
                 * Then user exists
                 */
                userExists();
                /*
                 * And user exists
                 */
                userExists();
                /*
                 * But user exists
                 */
                userExists();
            }
        }
        """

    Scenario: Different keywords across different scenarios
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
        Feature: Cross Scenario Keywords
          Scenario: First
            Given user exists

          Scenario: Second
            When user exists

          Scenario: Third
            Then user exists
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
         * Feature: Cross Scenario Keywords
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
            @DisplayName("Scenario: First")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }

            @Test
            @Order(2)
            @DisplayName("Scenario: Second")
            public void scenario_2() {
                /*
                 * When user exists
                 */
                userExists();
            }

            @Test
            @Order(3)
            @DisplayName("Scenario: Third")
            public void scenario_3() {
                /*
                 * Then user exists
                 */
                userExists();
            }
        }
        """
