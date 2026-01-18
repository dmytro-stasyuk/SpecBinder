Feature: CucumberStepAnnotations
  As a developer
  I want Cucumber step annotations to be optionally added to the generated step method signatures
  So that IDE plugins can provide navigation between feature files and step implementations

  Rule: When addCucumberStepAnnotations option is enabled, step methods are annotated with @Given/@When/@Then
  - each annotation includes a regex pattern matching the original step text
  - all step annotation regex patterns start with ^ (caret) and end with $ (dollar sign), this ensures exact matching of the entire step text

    Scenario: Given step generates @Given annotation with simple regex
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Simple Given
          Scenario: Test
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
         * Feature: Simple Given
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user exists$")
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
            }
        }
        """

    Scenario: When step generates @When annotation with simple regex
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      Given the following feature file:
        """
        Feature: Simple When
          Scenario: Test
            When user clicks button
        """
      When the generator is run
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.When;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Simple When
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @When("^user clicks button$")
            public void whenUserClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user clicks button
                 */
                whenUserClicksButton();
            }
        }
        """

    Scenario: Then step generates @Then annotation with simple regex
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Simple Then
          Scenario: Test
            Then result is displayed
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Then;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Simple Then
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Then("^result is displayed$")
            public void thenResultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then result is displayed
                 */
                thenResultIsDisplayed();
            }
        }
        """

  Rule: Steps with And/But/* keywords inherit annotation from the previous step

    Scenario: And step generates annotation according to the keyword from previous step
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: And Inherits Annotation
          Scenario: Test
            Given user exists
            And user is active
            When user logs in
            And user navigates to dashboard
            Then dashboard is displayed
            And user menu is visible
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: And Inherits Annotation
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user exists$")
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^user is active$")
            public void givenUserIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user logs in$")
            public void whenUserLogsIn() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user navigates to dashboard$")
            public void whenUserNavigatesToDashboard() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^dashboard is displayed$")
            public void thenDashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^user menu is visible$")
            public void thenUserMenuIsVisible() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
                /*
                 * And user is active
                 */
                givenUserIsActive();
                /*
                 * When user logs in
                 */
                whenUserLogsIn();
                /*
                 * And user navigates to dashboard
                 */
                whenUserNavigatesToDashboard();
                /*
                 * Then dashboard is displayed
                 */
                thenDashboardIsDisplayed();
                /*
                 * And user menu is visible
                 */
                thenUserMenuIsVisible();
            }
        }
        """

    Scenario: But step generates annotation according to the keyword from previous step
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: But Inherits Annotation
          Scenario: Test
            Given user is logged in
            But user is not admin
            When user requests admin page
            But request is denied
            Then error message is shown
            But user remains on current page
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: But Inherits Annotation
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user is logged in$")
            public void givenUserIsLoggedIn() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^user is not admin$")
            public void givenUserIsNotAdmin() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user requests admin page$")
            public void whenUserRequestsAdminPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^request is denied$")
            public void whenRequestIsDenied() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^error message is shown$")
            public void thenErrorMessageIsShown() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^user remains on current page$")
            public void thenUserRemainsOnCurrentPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user is logged in
                 */
                givenUserIsLoggedIn();
                /*
                 * But user is not admin
                 */
                givenUserIsNotAdmin();
                /*
                 * When user requests admin page
                 */
                whenUserRequestsAdminPage();
                /*
                 * But request is denied
                 */
                whenRequestIsDenied();
                /*
                 * Then error message is shown
                 */
                thenErrorMessageIsShown();
                /*
                 * But user remains on current page
                 */
                thenUserRemainsOnCurrentPage();
            }
        }
        """

    Scenario: * step generates annotation according to the keyword from previous step
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Asterisk Inherits Annotation
          Scenario: Test
            Given system is ready
            * database is connected
            When user submits form
            * validation passes
            Then form is saved
            * confirmation is sent
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import io.cucumber.java.en.Then;
        import io.cucumber.java.en.When;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Asterisk Inherits Annotation
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^system is ready$")
            public void givenSystemIsReady() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^database is connected$")
            public void givenDatabaseIsConnected() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user submits form$")
            public void whenUserSubmitsForm() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^validation passes$")
            public void whenValidationPasses() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^form is saved$")
            public void thenFormIsSaved() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^confirmation is sent$")
            public void thenConfirmationIsSent() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given system is ready
                 */
                givenSystemIsReady();
                /*
                 * * database is connected
                 */
                givenDatabaseIsConnected();
                /*
                 * When user submits form
                 */
                whenUserSubmitsForm();
                /*
                 * * validation passes
                 */
                whenValidationPasses();
                /*
                 * Then form is saved
                 */
                thenFormIsSaved();
                /*
                 * * confirmation is sent
                 */
                thenConfirmationIsSent();
            }
        }
        """

  Rule: Steps with quoted parameters generate regex with named capture groups: (?<p1>.*), (?<p2>.*), etc.

    Scenario: with one quoted parameter
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Parameter Capture
          Scenario: Test
            Given user "Alice" exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Parameter Capture
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user (?<p1>.*) exists$")
            public void givenUser$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                givenUser$p1Exists("Alice");
            }
        }
        """

    Scenario: Step with multiple quoted parameters
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Multiple Captures
          Scenario: Test
            When user "Bob" sends message "Hello World" to "Alice"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.When;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Captures
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @When("^user (?<p1>.*) sends message (?<p2>.*) to (?<p3>.*)$")
            public void whenUser$p1SendsMessage$p2To$p3(String p1, String p2, String p3) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user "Bob" sends message "Hello World" to "Alice"
                 */
                whenUser$p1SendsMessage$p2To$p3("Bob", "Hello World", "Alice");
            }
        }
        """

  Rule: Steps with special regex characters generate regex with those characters escaped

    Scenario: Step with special regex characters
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: Regex Escaping
          Scenario: Test
            Then balance is $100.50 (verified)
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Then;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Regex Escaping
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Then("^balance is \\$100\\.50 \\(verified\\)$")
            public void thenBalanceIs$10050Verified() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then balance is $100.50 (verified)
                 */
                thenBalanceIs$10050Verified();
            }
        }
        """

  Rule: DocString steps generate regex without any marker for the DocString

    Scenario: Step with DocString
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = true)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: DocString Annotation
          Scenario: Test
            Given document contains:
              \"\"\"
              Sample content
              \"\"\"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import io.cucumber.java.en.Given;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: DocString Annotation
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^document contains:$")
            public void givenDocumentContains(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given document contains:
                 */
                givenDocumentContains(\"\"\"
                        Sample content
                        \"\"\");
            }
        }
        """

  Rule: steps with a data table parameter generate regex without any marker for the data table

    Scenario: Step with DataTable
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(addCucumberStepAnnotations = true)
      public abstract class MockedAnnotatedTestClass {
      }
      """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
      """
      Feature: DataTable Annotation
        Scenario: Test
          Given the following users exist:
            | name  | age |
            | Alice | 30  |
            | Bob   | 25  |
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import io.cucumber.java.en.Given;
      import java.lang.Math;
      import java.lang.String;
      import java.util.ArrayList;
      import java.util.HashMap;
      import java.util.List;
      import java.util.Map;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: DataTable Annotation
       */
      @DisplayName("TestFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends MockedAnnotatedTestClass {
          @Given("^the following users exist:$")
          public void givenTheFollowingUsersExist(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Test")
          public void scenario_1() {
              /*
               * Given the following users exist:
               */
              givenTheFollowingUsersExist(createListOfMaps(\"\"\"
                      | name  | age |
                      | Alice | 30  |
                      | Bob   | 25  |
                      \"\"\"));
          }

          protected List<Map<String, String>> createListOfMaps(String tableLines) {

              String[] tableRows = tableLines.split("\\n");
              List<Map<String, String>> listOfMaps = new ArrayList<>();

              if (tableRows.length < 2) {
                  return listOfMaps;
              }

              String[] headers = null;
              for (int i = 0; i < tableRows.length; i++) {
                  String trimmedLine = tableRows[i].trim();
                  if (!trimmedLine.isEmpty()) {
                      String[] columns = trimmedLine.split("\\|");
                      List<String> rowColumns = new ArrayList<>(columns.length);
                      for (int j = 1; j < columns.length; j++) {
                          String column = columns[j].trim();
                          rowColumns.add(column);
                      }

                      if (headers == null) {
                          headers = rowColumns.toArray(new String[0]);
                      } else {
                          Map<String, String> rowMap = new HashMap<>();
                          for (int j = 0; j < Math.min(headers.length, rowColumns.size()); j++) {
                              rowMap.put(headers[j], rowColumns.get(j));
                          }
                          listOfMaps.add(rowMap);
                      }
                  }
              }

              return listOfMaps;
          }
      }
      """

  Rule: when the addCucumberStepAnnotations option is disabled, step methods are not annotated

    Scenario: option is disabled
      Given the following base class:
        """
        package com.example;

        import dev.specbinder.annotations.Feature2JUnit;
        import dev.specbinder.annotations.Feature2JUnitOptions;

        @Feature2JUnit
        @Feature2JUnitOptions(addCucumberStepAnnotations = false)
        public abstract class MockedAnnotatedTestClass {
        }
        """
      And a feature file under path "com/example/TestFeature.feature" with the following content:
        """
        Feature: No Annotations
          Scenario: Test
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
         * Feature: No Annotations
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            public void givenUserExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                givenUserExists();
            }
        }
        """
