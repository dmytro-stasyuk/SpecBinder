Feature: ShoppingCart

  Demonstrates feature-level and rule-level backgrounds.

  Background: Start with a signed-in shopper
    Ensures the user is authenticated and has a clean cart before each scenario.
    Given I am signed in as "alice@example.com"
    And I have an empty shopping cart

  Scenario: View empty cart message
    When I view the cart
    Then I should see "Your cart is empty"

  Rule: Free shipping applies to orders over 50 euros

    Background: Cart near the shipping threshold
      Given my cart subtotal is "45.00"

    Scenario: Adding an item pushes subtotal over the threshold
      When I add an item priced at "10.00"
      Then I should see the "Free shipping" banner

    Scenario: Staying below the threshold shows shipping cost
      When I add an item priced at "3.00"
      Then I should see the "Shipping: 5.99" banner

  Rule: Loyalty points are earned on every purchase

    Background: Customer has existing points
      Given I have "100" loyalty points

    Scenario: Earn points on a new purchase
      When I purchase items totalling "25.00"
      Then I should have "125" loyalty points
