Feature: ShoppingCart

  A shopper can add items to the cart and view what they added.

  Scenario: Add a single item to an empty cart
    Given I have an empty shopping cart
    When I add an item to the cart
    Then the cart should contain one item
