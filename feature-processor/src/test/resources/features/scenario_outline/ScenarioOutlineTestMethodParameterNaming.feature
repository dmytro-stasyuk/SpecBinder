Feature: ScenarioOutlineTestMethodParameterNaming
  As a developer writing data-driven BDD tests
  I want Examples table column headers automatically converted to clean, Java-compliant parameter names
  So that generated test methods have readable, maintainable parameters regardless of the naming convention used in feature files

  Rule: Parameters are named like this:
  - Column headers from Examples table are split by whitespace or dots
  - First letter of the first word is converted to lowercase, unless the whole word is uppercase or non letter character (in which case it is left as-is)
  - Subsequent words have their first character capitalized, rest unchanged
  - since the method argument names are positional when using @CSVSource, so the values are propagated based on position
  - so the names of the method arguments don't have to match the column names in @CSVSource table exactly

    Scenario: examples table column headers with spaces
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
      Feature: Naming
        Scenario Outline: Column name conversion
          Given user <first name> has <last name> and <user id>
          Examples:
            | first name | last name | user id   |
            | John       | Doe       | user123   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Naming
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1Has$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first name | last name | user id
                          John       | Doe       | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column name conversion")
          public void scenario_1(String firstName, String lastName, String userId) {
              /*
               * Given user <first name> has <last name> and <user id>
               */
              user$p1Has$p2And$p3(firstName, lastName, userId);
          }
      }
      """

    Scenario: examples table column headers with dots
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
      Feature: Naming
        Scenario Outline: Column name conversion
          Given user <first.name> has <last.name> and <user.id>
          Examples:
            | first.name | last.name | user.id   |
            | John       | Doe       | user123   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Naming
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1Has$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first.name | last.name | user.id
                          John       | Doe       | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column name conversion")
          public void scenario_1(String firstName, String lastName, String userId) {
              /*
               * Given user <first.name> has <last.name> and <user.id>
               */
              user$p1Has$p2And$p3(firstName, lastName, userId);
          }
      }
      """

    Scenario: Column names with numbers are handled correctly
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
      Feature: Numbers
        Scenario Outline: Column names containing numbers
          Given <value1> and <user 2 id> and <test_3_name>
          Examples:
            | value1 | user 2 id | test_3_name |
            | abc    | user456   | xyz         |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Numbers
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          value1 | user 2 id | test_3_name
                          abc    | user456   | xyz
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names containing numbers")
          public void scenario_1(String value1, String user2Id, String test_3_name) {
              /*
               * Given <value1> and <user 2 id> and <test_3_name>
               */
              $p1And$p2And$p3(value1, user2Id, test_3_name);
          }
      }
      """

    Scenario: Mixed separators are handled correctly
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
      Feature: Mixed Separators
        Scenario Outline: Column names with mixed separator types
          Given <first-name_value> and <user.id-number>
          Examples:
            | first-name_value | user.id-number |
            | John             | user789        |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Mixed Separators
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first-name_value | user.id-number
                          John             | user789
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with mixed separator types")
          public void scenario_1(String firstname_value, String userIdnumber) {
              /*
               * Given <first-name_value> and <user.id-number>
               */
              $p1And$p2(firstname_value, userIdnumber);
          }
      }
      """

  Rule: minimum of one valid java identifier character is required for a column header name

    Scenario: Single valid character column names are converted to method parameter names fine
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
      Feature: Single Chars
        Scenario Outline: Single character column names
          Given <a> and <x y z>
          Examples:
            | a   | x y z |
            | abc | xyz   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Single Chars
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          a   | x y z
                          abc | xyz
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Single character column names")
          public void scenario_1(String a, String xYZ) {
              /*
               * Given <a> and <x y z>
               */
              $p1And$p2(a, xYZ);
          }
      }
      """

    # counter example
    Scenario: column name with no valid identifier characters

  Rule: Underscores are retained in parameter names.

    Scenario: examples table column headers with underscores
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
      Feature: Naming
        Scenario Outline: Column name conversion
          Given user <first_name> has <last_name> and <user_id>
          Examples:
            | first_name | last_name | user_id  |
            | John       | Doe       | user123  |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Naming
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1Has$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first_name | last_name | user_id
                          John       | Doe       | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column name conversion")
          public void scenario_1(String first_name, String last_name, String user_id) {
              /*
               * Given user <first_name> has <last_name> and <user_id>
               */
              user$p1Has$p2And$p3(first_name, last_name, user_id);
          }
      }
      """

    Scenario: with headers that have multiple consecutive spaces and underscores as word separators
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
      Feature: Multiple Separators
        Scenario Outline: Column names with multiple consecutive separators
          Given <first  name> and <user__id>
          Examples:
            | first  name | user__id |
            | John        | user123  |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Multiple Separators
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          first  name | user__id
                          John        | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with multiple consecutive separators")
          public void scenario_1(String firstName, String user__id) {
              /*
               * Given <first  name> and <user__id>
               */
              $p1And$p2(firstName, user__id);
          }
      }
      """

  Rule: Only Java identifier-compliant characters are retained.

    Scenario: Non-identifier characters are removed from argument names but continue to be present in @CSVSource
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
      Feature: Special Characters
        Scenario Outline: Column names with special characters
          Given user <user-id> has <user.name> and <order#number>
          Examples:
            | user-id  | user.name | order#number |
            | user123  | John      | order456     |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Special Characters
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void user$p1Has$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          user-id | user.name | order#number
                          user123 | John      | order456
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with special characters")
          public void scenario_1(String userid, String userName, String ordernumber) {
              /*
               * Given user <user-id> has <user.name> and <order#number>
               */
              user$p1Has$p2And$p3(userid, userName, ordernumber);
          }
      }
      """

    Scenario: Leading and trailing non-identifier characters are removed
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
      Feature: Leading Trailing
        Scenario Outline: Column names with leading/trailing characters
          Given <!firstName> and <lastName@> and <_userId_>
          Examples:
            |  !firstName | lastName@  | _userId_ |
            | John        | Doe        | user123  |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Leading Trailing
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          !firstName | lastName@ | _userId_
                          John       | Doe       | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with leading/trailing characters")
          public void scenario_1(String firstName, String lastName, String _userId_) {
              /*
               * Given <!firstName> and <lastName@> and <_userId_>
               */
              $p1And$p2And$p3(firstName, lastName, _userId_);
          }
      }
      """

  Rule: camel case conversion - only first letter of each word (apart from first) is converted to uppercase
  - the rest of letters in each word remain unchanged

    Scenario: Mixed case words preserve internal capitalization
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
      Feature: Mixed Case Preservation
        Scenario Outline: Column names with mixed case in words
          Given <user iD> and <first NaMe> and <order ToTal>
          Examples:
            | user iD  | first NaMe | order ToTal |
            | user123  | John       | total99     |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Mixed Case Preservation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          user iD | first NaMe | order ToTal
                          user123 | John       | total99
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with mixed case in words")
          public void scenario_1(String userID, String firstNaMe, String orderToTal) {
              /*
               * Given <user iD> and <first NaMe> and <order ToTal>
               */
              $p1And$p2And$p3(userID, firstNaMe, orderToTal);
          }
      }
      """

    Scenario: PascalCase words with spaces preserve case
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
      Feature: PascalCase Preservation
        Scenario Outline: Column names in PascalCase format
          Given <First Name> and <Last Name> and <User ID>
          Examples:
            | First Name | Last Name | User ID  |
            | John       | Doe       | user123  |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: PascalCase Preservation
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          First Name | Last Name | User ID
                          John       | Doe       | user123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names in PascalCase format")
          public void scenario_1(String firstName, String lastName, String userID) {
              /*
               * Given <First Name> and <Last Name> and <User ID>
               */
              $p1And$p2And$p3(firstName, lastName, userID);
          }
      }
      """

    Scenario: Lowercase words with internal capitals are preserved
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
      Feature: Internal Capitals
        Scenario Outline: Column names with lowercase start but internal capitals
          Given <xml Data> and <json Payload> and <http Request>
          Examples:
            | xml Data | json Payload | http Request |
            | abc      | xyz          | request123   |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Internal Capitals
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          xml Data | json Payload | http Request
                          abc      | xyz          | request123
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names with lowercase start but internal capitals")
          public void scenario_1(String xmlData, String jsonPayload, String httpRequest) {
              /*
               * Given <xml Data> and <json Payload> and <http Request>
               */
              $p1And$p2And$p3(xmlData, jsonPayload, httpRequest);
          }
      }
      """



  Rule: camel case conversion - if the whole word is uppercase then it is left untouched (assumption here is caps are
  - appropriate for the domain/use case)

    Scenario: All uppercase column names are left as is
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
      Feature: Uppercase Names
        Scenario Outline: SCREAMING_SNAKE_CASE column names
          Given <USER_ID> and <FIRST_NAME> and <LAST NAME>
          Examples:
            | USER_ID  | FIRST_NAME | LAST NAME |
            | USER123  | John       | Smith     |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: Uppercase Names
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          USER_ID | FIRST_NAME | LAST NAME
                          USER123 | John       | Smith
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: SCREAMING_SNAKE_CASE column names")
          public void scenario_1(String USER_ID, String FIRST_NAME, String LASTNAME) {
              /*
               * Given <USER_ID> and <FIRST_NAME> and <LAST NAME>
               */
              $p1And$p2And$p3(USER_ID, FIRST_NAME, LASTNAME);
          }
      }
      """




    Scenario: Already camelCase column names remain unchanged
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
      Feature: CamelCase
        Scenario Outline: Column names already in camelCase
          Given <firstName> and <userId> and <orderTotal>
          Examples:
            | firstName | userId   | orderTotal  |
            | John      | user123  | total99     |
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
      import org.junit.jupiter.api.TestMethodOrder;
      import org.junit.jupiter.params.ParameterizedTest;
      import org.junit.jupiter.params.provider.CsvSource;

      /**
       * Feature: CamelCase
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void $p1And$p2And$p3(String p1, String p2, String p3) {
              Assertions.fail("Step is not yet implemented");
          }

          @ParameterizedTest(
                  name = "Example {index}: [{arguments}]"
          )
          @CsvSource(
                  useHeadersInDisplayName = true,
                  delimiter = '|',
                  textBlock = \"\"\"
                          firstName | userId  | orderTotal
                          John      | user123 | total99
                          \"\"\"
          )
          @Order(1)
          @DisplayName("Scenario Outline: Column names already in camelCase")
          public void scenario_1(String firstName, String userId, String orderTotal) {
              /*
               * Given <firstName> and <userId> and <orderTotal>
               */
              $p1And$p2And$p3(firstName, userId, orderTotal);
          }
      }
      """



