Feature: ScenarioWithBackground

  This example demonstrates how Background is converted to @BeforeEach.

  Background:
    Given I have a shopping cart
    And the cart is empty

  Scenario: Adding a single item
    When I add "Laptop" to the cart
    Then the cart should contain "1" item

  Scenario: Adding multiple items
    When I add "Laptop" to the cart
    And I add "Mouse" to the cart
    Then the cart should contain "2" items
