Feature: ShoppingCart

  Demonstrates abstract mode where the generated class is abstract
  and step methods must be implemented in a concrete subclass.

  Scenario: Add item and verify cart contents
    Given I have an empty shopping cart
    When I add "Wireless Headphones" with quantity "2" and unit price "59.99"
    Then the cart should contain "1" item
    And the cart subtotal should be "119.98"

  Rule: Free shipping applies to orders over 50 euros

    Scenario: Show free shipping when threshold is met
      Given my cart subtotal is "55.00"
      When I view the cart
      Then I should see the "Free shipping" banner
