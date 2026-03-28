Feature: EmptyScenarioBehavior
  As a test developer using Gherkin
  I want to configure how empty Scenarios (Scenarios without steps) behave in generated test classes
  So that I can choose whether empty Scenarios fail, are skipped, or pass silently depending on my workflow

  Rule: When emptyScenarioBehavior = FAIL, the empty Scenario generates a test method that fails with Assertions.fail()

    Scenario: empty Scenario with FAIL behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.FAIL;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          emptyScenarioBehavior = FAIL
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: feature with empty scenario

          Scenario: Future implementation
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
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Test
            @Order(1)
            @Tag("new")
            @DisplayName("Scenario: Future implementation")
            public void scenario_1() {
                Assertions.fail("Scenario has no steps");
            }
        }
        """

  Rule: When emptyScenarioBehavior = SKIP, the empty Scenario generates a test method that is skipped with Assumptions.assumeTrue()

    Scenario: empty Scenario with SKIP behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.SKIP;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          emptyScenarioBehavior = SKIP
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: feature with empty scenario

          Scenario: Future implementation
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
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Test
            @Order(1)
            @Tag("new")
            @DisplayName("Scenario: Future implementation")
            public void scenario_1() {
                Assumptions.assumeTrue(false, "Scenario has no steps");
            }
        }
        """

  Rule: When emptyScenarioBehavior = COMPILATION_ERROR, the empty Scenario generates a test method with an invalid statement that prevents compilation

    Scenario: empty Scenario with COMPILATION_ERROR behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import static dev.specbinder.annotations.Gherkin2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.COMPILATION_ERROR;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
          emptyScenarioBehavior = COMPILATION_ERROR
        )
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: feature with empty scenario

          Scenario: Future implementation
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
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Test
            @Order(1)
            @Tag("new")
            @DisplayName("Scenario: Future implementation")
            public void scenario_1() {
                Scenario has no steps
            }
        }
        """
      And the compilation error should contain the following text:
        """
        Scenario has no steps
        """

  Rule: By default (no explicit option), emptyScenarioBehavior defaults to FAIL

    Scenario: empty Scenario with default options (no explicit emptyScenarioBehavior)
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
        Feature: feature with empty scenario

          Scenario: Placeholder test
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
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Test
            @Order(1)
            @Tag("new")
            @DisplayName("Scenario: Placeholder test")
            public void scenario_1() {
                Assertions.fail("Scenario has no steps");
            }
        }
        """
