Feature: UseCucumberAnnotationsForStepMatching
  As a developer writing BDD tests with Cucumber step annotations on base class methods
  I want the generator to optionally match steps by their @Given/@When/@Then annotation values
  So that I can use descriptive method names that differ from the step text while still having the generator detect them as existing implementations

  Rule: When useCucumberAnnotationsForStepMatching is true (default), methods annotated with @Given/@When/@Then are matched by annotation value
  - The generator checks if a method in the class hierarchy has a Cucumber step annotation whose value matches the step text
  - If a match is found, the annotated method is called from the generated scenario method without being re-declared

    Scenario: Method with @Given annotation matching step text is reused
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user exists$")
            protected void setupUser() {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Annotation Matching
          Scenario: Test
            Given user exists
            When action is performed
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
         * Feature: Annotation Matching
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                setupUser();
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

    Scenario: Method with @When annotation matching step text is reused
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.When;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @When("^user clicks button$")
            protected void handleButtonClick() {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: When Annotation Matching
          Scenario: Test
            Given user exists
            When user clicks button
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
         * Feature: When Annotation Matching
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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
                 * When user clicks button
                 */
                handleButtonClick();
            }
        }
        """

    Scenario: Method with @Then annotation matching step text is reused
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("^result is displayed$")
            protected void verifyResult() {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Then Annotation Matching
          Scenario: Test
            Given user exists
            Then result is displayed
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
         * Feature: Then Annotation Matching
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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
                 * Then result is displayed
                 */
                verifyResult();
            }
        }
        """

  Rule: Methods without Cucumber annotations are still matched by method name when the option is enabled
  - Annotation-based and name-based matching work together
  - A method without any @Given/@When/@Then annotation is matched by its method name as usual

    Scenario: Mix of annotation-matched and name-matched methods
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user exists$")
            protected void setupUser() {
                // matched by annotation value
            }

            protected void actionIsPerformed() {
                // matched by method name
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Mixed Matching
          Scenario: Test
            Given user exists
            When action is performed
            Then result is displayed
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
         * Feature: Mixed Matching
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                setupUser();
                /*
                 * When action is performed
                 */
                actionIsPerformed();
                /*
                 * Then result is displayed
                 */
                resultIsDisplayed();
            }
        }
        """

  Rule: When both an annotation-matched and a name-matched method exist for the same step, the annotation match takes precedence

    Scenario: Annotation match takes precedence over name match
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user exists$")
            protected void setupUser() {
                // annotation value matches the step text
            }

            protected void userExists() {
                // method name matches the step text
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Annotation Precedence
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
         * Feature: Annotation Precedence
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                setupUser();
            }
        }
        """

  Rule: When useCucumberAnnotationsForStepMatching is false, annotation values are ignored and only method names are used for matching

    Scenario: Annotated method is not matched when option is disabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = false)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user exists$")
            protected void setupUser() {
                // annotation value matches, but option is disabled so method name is used instead
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Option Disabled
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
         * Feature: Option Disabled
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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

    Scenario: Name-matched method still works when option is disabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = false)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user exists$")
            protected void setupUser() {
                // not matched - annotation matching is disabled
            }

            protected void userExists() {
                // matched by method name
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Name Matching Only
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
         * Feature: Name Matching Only
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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

  Rule: Annotation values are treated as regex patterns for matching step text
  - The annotation value from @Given/@When/@Then is compiled as a java.util.regex.Pattern
  - The pattern is matched against the step text using regex matching
  - This allows flexible matching using regex features like capture groups, alternation, and quantifiers

    Scenario: Annotation regex with capture group matches parameterized step
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("^user \"([^\"]+)\" exists$")
            protected void setupUserByName(String name) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Regex Capture Group
          Scenario: Test
            Given user "Alice" exists
            When action is performed
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
         * Feature: Regex Capture Group
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                setupUserByName("Alice");
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

    Scenario: Annotation regex with multiple capture groups matches step with multiple parameters
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.When;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @When("^user \"([^\"]+)\" sends message to \"([^\"]+)\"$")
            protected void sendMessage(String from, String to) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Regex Multiple Capture Groups
          Scenario: Test
            Given setup is done
            When user "Alice" sends message to "Bob"
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
         * Feature: Regex Multiple Capture Groups
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * When user "Alice" sends message to "Bob"
                 */
                sendMessage("Alice", "Bob");
            }
        }
        """

    Scenario: Annotation regex with alternation matches step text
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.When;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @When("^user (clicks|taps|presses) button$")
            protected void handleButtonAction() {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Regex Alternation
          Scenario: Test
            Given setup is done
            When user taps button
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
         * Feature: Regex Alternation
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * When user taps button
                 */
                handleButtonAction();
            }
        }
        """

    Scenario: Annotation regex that does not match step text is not used
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("^admin exists$")
            protected void setupAdmin() {
                // regex does not match "user exists"
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Regex No Match
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
         * Feature: Regex No Match
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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

  Rule: Cucumber expressions with {string} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {string}, it matches single- or double-quoted text in the step
  - The matched text (without quotes) is passed as a String argument to the method

    Scenario: Annotation with {string} Cucumber expression matches step with double-quoted text
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a user named {string}")
            protected void aUserNamed(String name) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression String
          Scenario: Test
            Given a user named "Alice"
            When action is performed
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
         * Feature: Cucumber Expression String
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a user named "Alice"
                 */
                aUserNamed("Alice");
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

    Scenario: Annotation with {string} Cucumber expression matches step with single-quoted text
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a user named {string}")
            protected void aUserNamed(String name) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression String Single Quoted
          Scenario: Test
            Given a user named 'Alice'
            When action is performed
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
         * Feature: Cucumber Expression String Single Quoted
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a user named 'Alice'
                 */
                aUserNamed("Alice");
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

  Rule: Cucumber expressions with {int} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {int}, it matches integer values in the step text
  - The matched integer is passed as an int argument to the method

    Scenario: Annotation with {int} Cucumber expression matches step with integer value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.When;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @When("the user buys {int} items")
            protected void theUserBuysItems(int count) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Int
          Scenario: Test
            Given setup is done
            When the user buys 5 items
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
         * Feature: Cucumber Expression Int
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * When the user buys 5 items
                 */
                theUserBuysItems(5);
            }
        }
        """

    Scenario: Annotation with {int} Cucumber expression matches step with negative integer
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the balance changes by {int}")
            protected void theBalanceChangesBy(int amount) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Negative Int
          Scenario: Test
            Given setup is done
            Then the balance changes by -19
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
         * Feature: Cucumber Expression Negative Int
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the balance changes by -19
                 */
                theBalanceChangesBy(-19);
            }
        }
        """

  Rule: Cucumber expressions with {float} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {float}, it matches floating-point values in the step text
  - The matched value is passed as a float argument to the method

    Scenario: Annotation with {float} Cucumber expression matches step with float value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the weight is {float}")
            protected void theWeightIs(float weight) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Float
          Scenario: Test
            Given setup is done
            Then the weight is 3.14
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
         * Feature: Cucumber Expression Float
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the weight is 3.14
                 */
                theWeightIs(3.14F);
            }
        }
        """

  Rule: Cucumber expressions with {word} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {word}, it matches a single word without whitespace
  - The matched word is passed as a String argument to the method

    Scenario: Annotation with {word} Cucumber expression matches step with single word
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("the color is {word}")
            protected void theColorIs(String color) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Word
          Scenario: Test
            Given the color is red
            When action is performed
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
         * Feature: Cucumber Expression Word
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the color is red
                 */
                theColorIs("red");
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

  Rule: Cucumber expressions with {double} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {double}, it matches floating-point values in the step text
  - The matched value is passed as a double argument to the method

    Scenario: Annotation with {double} Cucumber expression matches step with decimal value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the total is {double}")
            protected void theTotalIs(double total) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Double
          Scenario: Test
            Given setup is done
            Then the total is 99.99
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
         * Feature: Cucumber Expression Double
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the total is 99.99
                 */
                theTotalIs(99.99);
            }
        }
        """

  Rule: Cucumber expressions with {long} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {long}, it matches integer values in the step text
  - The matched value is passed as a long argument with an L suffix

    Scenario: Annotation with {long} Cucumber expression matches step with long integer value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a timestamp of {long}")
            protected void aTimestampOf(long timestamp) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Long
          Scenario: Test
            Given a timestamp of 1234567890
            When action is performed
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
         * Feature: Cucumber Expression Long
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a timestamp of 1234567890
                 */
                aTimestampOf(1234567890L);
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

  Rule: Cucumber expressions with {byte} and {short} parameter types are supported for annotation-based step matching
  - When a Cucumber annotation value uses {byte} or {short}, it matches integer values in the step text
  - The matched value is passed with an explicit cast since Java has no byte or short literals

    Scenario: Annotation with {byte} Cucumber expression matches step with byte value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a priority of {byte}")
            protected void aPriorityOf(byte priority) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Byte
          Scenario: Test
            Given a priority of 5
            When action is performed
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
         * Feature: Cucumber Expression Byte
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a priority of 5
                 */
                aPriorityOf((byte) 5);
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

    Scenario: Annotation with {short} Cucumber expression matches step with short value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a port number of {short}")
            protected void aPortNumberOf(short port) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Short
          Scenario: Test
            Given a port number of 8080
            When action is performed
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
         * Feature: Cucumber Expression Short
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a port number of 8080
                 */
                aPortNumberOf((short) 8080);
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

  Rule: Cucumber expressions with {bigdecimal} and {biginteger} parameter types are supported for annotation-based step matching
  - When a Cucumber annotation value uses {bigdecimal}, the matched value is passed as new BigDecimal(...)
  - When a Cucumber annotation value uses {biginteger}, the matched value is passed as new BigInteger(...)

    Scenario: Annotation with {bigdecimal} Cucumber expression matches step with decimal value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;
        import java.math.BigDecimal;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the balance is {bigdecimal}")
            protected void theBalanceIs(BigDecimal balance) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression BigDecimal
          Scenario: Test
            Given setup is done
            Then the balance is 1234.56
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.math.BigDecimal;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Cucumber Expression BigDecimal
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the balance is 1234.56
                 */
                theBalanceIs(new BigDecimal("1234.56"));
            }
        }
        """

    Scenario: Annotation with {biginteger} Cucumber expression matches step with large integer value
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;
        import java.math.BigInteger;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a population of {biginteger}")
            protected void aPopulationOf(BigInteger population) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression BigInteger
          Scenario: Test
            Given a population of 7800000000
            When action is performed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.math.BigInteger;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Cucumber Expression BigInteger
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void actionIsPerformed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given a population of 7800000000
                 */
                aPopulationOf(new BigInteger("7800000000"));
                /*
                 * When action is performed
                 */
                actionIsPerformed();
            }
        }
        """

  Rule: Cucumber expressions with anonymous {} parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value uses {}, it matches any text at that position
  - The matched text is passed as a String argument to the method

    Scenario: Annotation with anonymous {} Cucumber expression matches any text
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the result is {}")
            protected void theResultIs(String result) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Anonymous
          Scenario: Test
            Given setup is done
            Then the result is success
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
         * Feature: Cucumber Expression Anonymous
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the result is success
                 */
                theResultIs("success");
            }
        }
        """

  Rule: Cucumber expressions with multiple parameter types in a single annotation match steps with multiple values
  - Parameter types can be mixed freely in a single Cucumber expression
  - Each parameter is passed with the appropriate type literal

    Scenario: Annotation with mixed {string}, {int}, and {float} Cucumber expression parameters
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.When;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @When("user {string} buys {int} items at {float} each")
            protected void userBuysItemsAtPrice(String user, int count, float price) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Multiple Parameters
          Scenario: Test
            Given setup is done
            When user "Alice" buys 3 items at 9.99 each
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
         * Feature: Cucumber Expression Multiple Parameters
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * When user "Alice" buys 3 items at 9.99 each
                 */
                userBuysItemsAtPrice("Alice", 3, 9.99F);
            }
        }
        """

    Scenario: Annotation with mixed {word} and {double} Cucumber expression parameters
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Then("the {word} costs {double}")
            protected void theItemCosts(String item, double price) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression Word And Double
          Scenario: Test
            Given setup is done
            Then the laptop costs 999.99
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
         * Feature: Cucumber Expression Word And Double
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the laptop costs 999.99
                 */
                theItemCosts("laptop", 999.99);
            }
        }
        """

  Rule: Cucumber expression that does not match step text is not used for step matching
  - If the Cucumber expression does not match the step text, the method is not reused
  - The step is generated as a new method, just as with non-matching regex patterns

    Scenario: Non-matching Cucumber expression does not match step text
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)
        public abstract class MockedAnnotatedTestClass {
            @Given("a user named {string}")
            protected void aUserNamed(String name) {
                // Cucumber expression does not match "user exists"
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Cucumber Expression No Match
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
         * Feature: Cucumber Expression No Match
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
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

  Rule: Cucumber expressions with literal dollar sign before a parameter type are supported for annotation-based step matching
  - When a Cucumber annotation value contains a literal $ immediately before a parameter type placeholder (e.g. ${double}, ${int}),
  the $ is treated as literal text and the parameter type is matched normally
  - This is common in step definitions dealing with currency values like $29.99 or $100

    Scenario: Annotation with literal $ before {double} Cucumber expression matches step with dollar amount
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Then;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
            useCucumberAnnotationsForStepMatching = true,
            addCucumberStepAnnotations = true
        )
        public abstract class MockedAnnotatedTestClass {
            @Then("the cart total should be ${double}")
            protected void theCartTotalShouldBe(double total) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Dollar Before Double Param
          Scenario: Test
            Given setup is done
            Then the cart total should be $29.99
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.SourceFilePath;
        import io.cucumber.java.en.Given;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Dollar Before Double Param
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^setup is done$")
            public void setupIsDone() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given setup is done
                 */
                setupIsDone();
                /*
                 * Then the cart total should be $29.99
                 */
                theCartTotalShouldBe(29.99);
            }
        }
        """

    Scenario: Annotation with literal $ before {int} Cucumber expression matches step with dollar amount
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.annotations.Gherkin2JUnitOptions;
        import io.cucumber.java.en.Given;

        @Gherkin2JUnit
        @Gherkin2JUnitOptions(
            useCucumberAnnotationsForStepMatching = true,
            addCucumberStepAnnotations = true
        )
        public abstract class MockedAnnotatedTestClass {
            @Given("the product {string} exists with price ${int}")
            protected void theProductExistsWithPrice(String product, int price) {
                // custom implementation
            }
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Dollar Before Int Param
          Scenario: Test
            Given the product "Laptop" exists with price $999
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
         * Feature: Dollar Before Int Param
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given the product "Laptop" exists with price $999
                 */
                theProductExistsWithPrice("Laptop", 999);
            }
        }
        """
