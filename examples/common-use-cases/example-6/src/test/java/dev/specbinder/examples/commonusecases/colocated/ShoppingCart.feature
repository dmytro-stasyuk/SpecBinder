Feature: ShoppingCart

  The Feature file is co-located with its marker class in src/test/java.
  No path needed in @Feature2JUnit — convention-based discovery
  finds this file automatically in the same package.

  Scenario: Add item to cart
    Given I have an empty shopping cart
    When I add "Wireless Headphones" to the cart
    Then the cart should contain "1" item

  Scenario: Remove item from cart
    Given I have a cart with "Wireless Headphones"
    When I remove "Wireless Headphones" from the cart
    Then the cart should be empty
