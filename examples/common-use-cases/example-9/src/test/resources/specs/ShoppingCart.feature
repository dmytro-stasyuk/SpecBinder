Feature: ShoppingCart

  Inherits shared options from BaseFeature and uses
  step keywords in method names.

  Scenario: Add item to cart
    Given I have an empty shopping cart
    When I add "Wireless Headphones" to the cart
    Then the cart should contain "1" item
