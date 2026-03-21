Feature: EmptyRuleBehavior
  As a test developer using Gherkin
  I want to configure how empty Rules (Rules without Scenarios) behave in generated test classes
  So that I can choose whether empty Rules fail, are skipped, or pass silently depending on my workflow

  Rule: When emptyRuleBehavior = FAIL, the empty Rule generates a test method that fails with Assertions.fail()

    Scenario: empty Rule with FAIL behavior
      Given the following base class:
        """
        package com.example.payment;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.FAIL;

        @Feature2JUnit
        @Feature2JUnitOptions(
          emptyRuleBehavior = FAIL
        )
        public class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: feature with empty rule

          Rule: Processing rules
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example.payment;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty rule
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/payment/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Nested
            @Order(1)
            @Tag("new")
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule: Processing rules")
            public class Rule_1 {
                @Test
                public void noScenariosInRule() {
                    Assertions.fail("Rule doesn't have any scenarios");
                }
            }
        }
        """

  Rule: When emptyRuleBehavior = SKIP, the empty Rule generates a test method that is skipped with Assumptions.assumeTrue()

    Scenario: empty Rule with SKIP behavior
      Given the following base class:
        """
        package com.example.payment;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.SKIP;

        @Feature2JUnit
        @Feature2JUnitOptions(
          emptyRuleBehavior = SKIP
        )
        public class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: feature with empty rule

          Rule: Processing rules
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example.payment;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assumptions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty rule
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/payment/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Nested
            @Order(1)
            @Tag("new")
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule: Processing rules")
            public class Rule_1 {
                @Test
                public void noScenariosInRule() {
                    Assumptions.assumeTrue(false, "Rule has no scenarios");
                }
            }
        }
        """

  Rule: When emptyRuleBehavior = COMPILATION_ERROR, the empty Rule generates a test method with an invalid statement that prevents compilation

    Scenario: empty Rule with COMPILATION_ERROR behavior
      Given the following base class:
        """
        package com.example.payment;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;
        import static dev.specbinder.annotations.Feature2JUnitOptions.EMPTY_ELEMENT_BEHAVIOUR.COMPILATION_ERROR;

        @Feature2JUnit
        @Feature2JUnitOptions(
          emptyRuleBehavior = COMPILATION_ERROR
        )
        public class TestFeature {
        }
        """
      And the following feature file:
        """
        Feature: feature with empty rule

          Rule: Processing rules
        """
      When the generator is run
      Then the following java source file should be be generated:
        """
        package com.example.payment;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty rule
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/payment/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Nested
            @Order(1)
            @Tag("new")
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule: Processing rules")
            public class Rule_1 {
                @Test
                public void noScenariosInRule() {
                    Rule doesn't have any scenarios
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        Rule doesn't have any scenarios
        """

  Rule: By default (no explicit option), emptyRuleBehavior defaults to FAIL

    Scenario: empty Rule with default options (no explicit emptyRuleBehavior)
      Given the following base class:
        """
        package com.example.payment;

        import dev.specbinder.annotations.Feature2JUnit;

        @Feature2JUnit
        public class TestFeature {
        }
        """
      And a feature file under path "com/example/payment/TestFeature.feature" with the following content:
        """
        Feature: feature with empty rule

          Rule: Validation rules
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example.payment;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.ClassOrderer;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Nested;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Tag;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestClassOrder;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: feature with empty rule
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestClassOrder(ClassOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/payment/TestFeature.feature")
        public class TestFeatureTest extends TestFeature {
            @Nested
            @Order(1)
            @Tag("new")
            @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
            @DisplayName("Rule: Validation rules")
            public class Rule_1 {
                @Test
                public void noScenariosInRule() {
                    Assertions.fail("Rule doesn't have any scenarios");
                }
            }
        }
        """
