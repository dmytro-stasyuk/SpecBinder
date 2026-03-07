Feature: ShoppingCart

  Demonstrates the TDD workflow with Spec Binder.
  Start with rule and scenario titles only — no steps yet.
  Each empty rule/scenario generates a failing test tagged @new,
  giving you a red test to drive development.

  Rule: Cannot checkout with an empty cart

  Rule: Free shipping applies to orders over 50 euros

    Scenario: Free shipping when subtotal exceeds threshold

    Scenario: Shipping fee when subtotal is below threshold

  Rule: Discount codes apply a percentage reduction

    Scenario: Apply a valid discount code
      Given my cart subtotal is "100.00"
      When I apply discount code "SAVE10"
      Then the cart subtotal should be "90.00"

    Scenario: Reject an expired discount code
