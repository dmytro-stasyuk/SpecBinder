Feature: AddCucumberStepAnnotations
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
         * Feature: Simple Given
         */
        @DisplayName("TestFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user exists$")
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @When("^user clicks button$")
            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user clicks button
                 */
                userClicksButton();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Then("^result is displayed$")
            public void resultIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then result is displayed
                 */
                resultIsDisplayed();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user exists$")
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^user is active$")
            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user logs in$")
            public void userLogsIn() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user navigates to dashboard$")
            public void userNavigatesToDashboard() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^dashboard is displayed$")
            public void dashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^user menu is visible$")
            public void userMenuIsVisible() {
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
                 * And user is active
                 */
                userIsActive();
                /*
                 * When user logs in
                 */
                userLogsIn();
                /*
                 * And user navigates to dashboard
                 */
                userNavigatesToDashboard();
                /*
                 * Then dashboard is displayed
                 */
                dashboardIsDisplayed();
                /*
                 * And user menu is visible
                 */
                userMenuIsVisible();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user is logged in$")
            public void userIsLoggedIn() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^user is not admin$")
            public void userIsNotAdmin() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user requests admin page$")
            public void userRequestsAdminPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^request is denied$")
            public void requestIsDenied() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^error message is shown$")
            public void errorMessageIsShown() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^user remains on current page$")
            public void userRemainsOnCurrentPage() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user is logged in
                 */
                userIsLoggedIn();
                /*
                 * But user is not admin
                 */
                userIsNotAdmin();
                /*
                 * When user requests admin page
                 */
                userRequestsAdminPage();
                /*
                 * But request is denied
                 */
                requestIsDenied();
                /*
                 * Then error message is shown
                 */
                errorMessageIsShown();
                /*
                 * But user remains on current page
                 */
                userRemainsOnCurrentPage();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^system is ready$")
            public void systemIsReady() {
                Assertions.fail("Step is not yet implemented");
            }

            @Given("^database is connected$")
            public void databaseIsConnected() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^user submits form$")
            public void userSubmitsForm() {
                Assertions.fail("Step is not yet implemented");
            }

            @When("^validation passes$")
            public void validationPasses() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^form is saved$")
            public void formIsSaved() {
                Assertions.fail("Step is not yet implemented");
            }

            @Then("^confirmation is sent$")
            public void confirmationIsSent() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given system is ready
                 */
                systemIsReady();
                /*
                 * * database is connected
                 */
                databaseIsConnected();
                /*
                 * When user submits form
                 */
                userSubmitsForm();
                /*
                 * * validation passes
                 */
                validationPasses();
                /*
                 * Then form is saved
                 */
                formIsSaved();
                /*
                 * * confirmation is sent
                 */
                confirmationIsSent();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^user (?<p1>.*) exists$")
            public void user$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "Alice" exists
                 */
                user$p1Exists("Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @When("^user (?<p1>.*) sends message (?<p2>.*) to (?<p3>.*)$")
            public void user$p1SendsMessage$p2To$p3(String p1, String p2, String p3) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user "Bob" sends message "Hello World" to "Alice"
                 */
                user$p1SendsMessage$p2To$p3("Bob", "Hello World", "Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Then("^balance is \\$100\\.50 \\(verified\\)$")
            public void balanceIs$10050Verified() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then balance is $100.50 (verified)
                 */
                balanceIs$10050Verified();
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/TestFeature.feature")
        public class TestFeatureTest extends MockedAnnotatedTestClass {
            @Given("^document contains:$")
            public void documentContains(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given document contains:
                 */
                documentContains(\"\"\"
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
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

      @Feature2JUnit
      @Feature2JUnitOptions(addCucumberStepAnnotations = true, dataTableParameterType = LIST_OF_MAPS)
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TestFeature.feature")
      public class TestFeatureTest extends MockedAnnotatedTestClass {
          @Given("^the following users exist:$")
          public void theFollowingUsersExist(List<Map<String, String>> data) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Test")
          public void scenario_1() {
              /*
               * Given the following users exist:
               */
              theFollowingUsersExist(createListOfMaps(\"\"\"
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
