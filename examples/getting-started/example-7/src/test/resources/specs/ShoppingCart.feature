@cart @regression
Feature: ShoppingCart

  Demonstrates how Gherkin tags map to JUnit @Tag annotations
  for selective test execution.

  @smoke
  Scenario: View an empty cart
    Given I have an empty shopping cart
    When I view the cart
    Then I should see "Your cart is empty"

  @ui @shipping
  Rule: Free shipping applies to orders over 50 euros

    @smoke @happy-path
    Scenario: Show free shipping when threshold is met
      Given my cart subtotal is "55.00"
      When I view the cart
      Then I should see the "Free shipping" banner

    @edge-case
    Scenario: Exactly at the threshold
      Given my cart subtotal is "50.00"
      When I view the cart
      Then I should see the "Free shipping" banner

  @api @discount
  Rule: Discount codes apply a percentage reduction

    @smoke
    Scenario: Apply a valid discount code
      Given my cart subtotal is "100.00"
      When I apply discount code "SAVE10"
      Then the cart subtotal should be "90.00"
