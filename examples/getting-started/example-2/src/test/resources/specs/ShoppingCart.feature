Feature: ShoppingCart

  Demonstrates how quoted values in steps become typed method parameters.
  The generator infers types from the quoted values automatically.

  Scenario: Add item with quantity and price
    Given my cart contains "Wireless Headphones" with quantity "1" and unit price "59.99"
    When I change the quantity to "3"
    Then the cart subtotal should be "179.97"

  Scenario: Apply a discount flag
    Given my cart contains "Coffee Beans" with quantity "2" and unit price "15.50"
    And the discount applied is "true"
    When I view the cart summary
    Then the discount badge shows "Y"
