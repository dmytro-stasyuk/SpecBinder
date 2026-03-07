Feature: AddToCart

  Scenario: Add a single item
    Given I have an empty shopping cart
    When I add "Wireless Headphones" to the cart
    Then the cart should contain "1" item

  Scenario: Add multiple items
    Given I have an empty shopping cart
    When I add "Wireless Headphones" to the cart
    And I add "Coffee Beans" to the cart
    Then the cart should contain "2" items
