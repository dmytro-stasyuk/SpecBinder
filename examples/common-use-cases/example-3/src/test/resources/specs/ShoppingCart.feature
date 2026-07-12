Feature: ShoppingCart

  Demonstrates sharing common step implementations via a base class: the cart
  setup steps live in BaseShopSteps, while the feature-specific assertion steps
  are implemented in the concrete test class.

  Scenario: Add an item and verify the cart
    Given I have an empty shopping cart
    When I add "Wireless Headphones" with quantity "2" and unit price "59.99"
    Then the cart should contain "1" item
    And the cart subtotal should be "119.98"
