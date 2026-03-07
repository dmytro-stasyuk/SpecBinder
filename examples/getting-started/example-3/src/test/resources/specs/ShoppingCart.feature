Feature: ShoppingCart

  A fully working example where step methods are implemented
  in the marker class with real assertions.

  Scenario: Add item and verify cart contents
    Given I have an empty shopping cart
    When I add "Wireless Headphones" with quantity "2" and unit price "59.99"
    Then the cart should contain "1" item
    And the cart subtotal should be "119.98"

  Scenario: Add multiple different items
    Given I have an empty shopping cart
    When I add "Wireless Headphones" with quantity "1" and unit price "59.99"
    And I add "Coffee Beans" with quantity "3" and unit price "12.50"
    Then the cart should contain "2" items
    And the cart subtotal should be "97.49"
