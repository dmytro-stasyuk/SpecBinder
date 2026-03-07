Feature: EmptyScenarioBehavior
  As a test developer using Gherkin
  I want to configure how empty Scenarios (Scenarios without steps) behave in generated test classes
  So that I can choose whether empty Scenarios fail, are skipped, or pass silently depending on my workflow

  Rule: When emptyScenarioBehavior = FAIL, the empty Scenario generates a test method that fails with Assertions.fail()

    Scenario: empty Scenario with FAIL behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.FAIL;

        @Feature2JUnit
        @Feature2JUnitOptions(
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
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
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

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.SKIP;

        @Feature2JUnit
        @Feature2JUnitOptions(
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

        import dev.specbinder.annotations.output.FeatureFilePath;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
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

  Rule: When emptyScenarioBehavior = NONE, the empty Scenario generates a test method without any failing or skipping statement

    Scenario: empty Scenario with NONE behavior
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.NONE;

        @Feature2JUnit
        @Feature2JUnitOptions(
          emptyScenarioBehavior = NONE
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

        import dev.specbinder.annotations.output.FeatureFilePath;
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
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Test
            @Order(1)
            @Tag("new")
            @DisplayName("Scenario: Future implementation")
            public void scenario_1() {
            }
        }
        """

  Rule: By default (no explicit option), emptyScenarioBehavior defaults to FAIL

    Scenario: empty Scenario with default options (no explicit emptyScenarioBehavior)
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;

        @Feature2JUnit
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
         * Feature: feature with empty scenario
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
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
