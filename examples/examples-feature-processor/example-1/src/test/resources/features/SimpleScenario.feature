Feature: SimpleScenario

  This is the simplest example demonstrating basic Given/When/Then steps.

  Scenario: Adding two numbers
    Given I have a calculator
    And I have entered "5" into the calculator
    And I have entered "3" into the calculator
    When I press add
    Then the result should be "8"
