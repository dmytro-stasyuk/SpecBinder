Feature: TaggedScenarios

  This example demonstrates how Gherkin tags are converted to JUnit @Tag annotations.

  @smoke @critical
  Scenario: User login
    Given I am on the login page
    When I enter valid credentials
    Then I should be logged in successfully

  @regression
  Scenario: Password reset
    Given I am on the login page
    When I click "Forgot Password"
    Then I should see the password reset page
