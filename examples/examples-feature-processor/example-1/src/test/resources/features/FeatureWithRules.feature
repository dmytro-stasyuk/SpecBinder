Feature: NestedRules

  This example demonstrates how Gherkin Rules are converted to @Nested test classes.

  Rule: Guest checkout

    Scenario: Guest user adds item to cart
      Given I am not logged in
      When I add "Book" to the cart
      Then I should see "1" item in my cart

  Rule: Member checkout

    Background:
      Given I am logged in as a member

    Scenario: Member gets discount
      When I add "Book" priced at "20" to the cart
      Then the discounted price should be "18"

    Scenario: Member earns points
      When I add "Book" to the cart
      Then I should earn "10" reward points
