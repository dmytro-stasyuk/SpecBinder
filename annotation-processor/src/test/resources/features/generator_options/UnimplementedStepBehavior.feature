Feature: UnimplementedStepBehavior
  As a test developer using Gherkin
  I want to configure how unimplemented step method stubs behave in generated concrete test classes
  So that I can choose whether unimplemented steps fail, are skipped, or prevent compilation depending on my workflow

  Rule: When unimplementedStepBehavior = FAIL, the step method stub contains Assertions.fail()

    Scenario: step method stub with FAIL behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.FAIL;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          shouldBeAbstract = false,
          unimplementedStepBehavior = FAIL
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Concrete Steps
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Concrete Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
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
            }
        }
        """

  Rule: When unimplementedStepBehavior = SKIP, the step method stub contains Assumptions.assumeTrue()

    Scenario: step method stub with SKIP behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.SKIP;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          shouldBeAbstract = false,
          unimplementedStepBehavior = SKIP
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Concrete Steps
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assumptions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Concrete Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void userExists() {
                Assumptions.assumeTrue(false, "Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }
        }
        """

  Rule: When unimplementedStepBehavior = COMPILATION_ERROR, the step method stub contains an invalid statement that prevents compilation

    Scenario: step method stub with COMPILATION_ERROR behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.COMPILATION_ERROR;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          shouldBeAbstract = false,
          unimplementedStepBehavior = COMPILATION_ERROR
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Concrete Steps
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Concrete Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            public void userExists() {
                Step is not yet implemented
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }
        }
        """
      And the compilation error should contain the following text:
        """
        Step is not yet implemented
        """

  Rule: By default (no explicit option), unimplementedStepBehavior defaults to FAIL

    Scenario: step method stub with default options (no explicit unimplementedStepBehavior)
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(shouldBeAbstract = false)
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Concrete Steps
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Concrete Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
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
            }
        }
        """

  Rule: unimplementedStepBehavior has no effect when shouldBeAbstract is true

    Scenario: abstract mode ignores unimplementedStepBehavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.SKIP;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          shouldBeAbstract = true,
          unimplementedStepBehavior = SKIP
        )
        public abstract class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Abstract Steps
          Scenario: Test
            Given user exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Abstract Steps
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public abstract class TestFeatureScenarios extends TestFeature {
            public abstract void userExists();

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
            }
        }
        """
