Feature: ShoppingCart

  Demonstrates generating Cucumber @Given/@When/@Then annotations
  on step methods, useful for teams migrating from Cucumber or
  wanting step matching documentation on generated methods.

  Scenario: Add item and verify cart
    Given I have an empty shopping cart
    When I add "Wireless Headphones" to the cart
    And I add "Coffee Beans" to the cart
    Then the cart should contain "2" items

  Scenario: Apply discount code
    Given I have a cart with subtotal "100.00"
    When I apply discount code "SAVE10"
    Then the cart subtotal should be "90.00"
