Feature: ShoppingCart

  As a shopper
  I want to add items to my cart
  So that I can see everything I picked before I pay

  Scenario: Add a single item to an empty cart
    Given I have an empty shopping cart
    When I add an item to the cart
    Then the cart should contain one item
