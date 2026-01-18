Feature: ScenarioOutline

  This example demonstrates how Scenario Outline is converted to @ParameterizedTest.

  Scenario Outline: Discount calculation
    Given I have a product priced at "<price>"
    When I apply a discount of "<discount>" percent
    Then the final price should be "<finalPrice>"

    Examples:
      | price | discount | finalPrice |
      | 100   | 10       | 90         |
      | 200   | 20       | 160        |
      | 50    | 5        | 47.5       |
