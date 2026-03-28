Feature: FeatureFileWithErrorsHandling
  As a developer
  I want to be informed of parsing errors in feature files in case of invalid step keywords or other issues
  So that I can quickly identify and fix issues in my feature files

  Rule: Invalid step keywords that are not Given/When/Then/And/But/* result in error
  - Any unrecognized keyword should throw a ProcessingException
  - Error message should indicate the invalid keyword

    Scenario: Invalid step keyword
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Gherkin2JUnit;

      @Gherkin2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Invalid Keyword
          Scenario: Test
            Given user exists
            Invalid user clicks button
        """
      When the generator is run
      Then the generator should report an error:
        """
        Unable to parse Feature from the specified gherkin document: features/MyFeature.feature
        """
