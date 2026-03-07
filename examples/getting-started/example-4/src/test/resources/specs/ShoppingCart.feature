Feature: ShoppingCart

  Shopping cart business rules organized into logical groups.

  Scenario: View an empty cart
    Given I have an empty shopping cart
    When I view the cart
    Then the cart should display "Your cart is empty"

  Rule: Free shipping applies to orders over 50 euros
    Orders at or above 50 euros show a free shipping banner.

    Scenario: Show free shipping when threshold is met
      Given my cart subtotal is "55.00"
      When I view the cart
      Then I should see the "Free shipping" banner

    Scenario: Show shipping cost when below threshold
      Given my cart subtotal is "30.00"
      When I view the cart
      Then I should see the "Shipping: 5.99" banner

  Rule: Discount codes apply a percentage reduction

    Scenario: Apply a valid discount code
      Given my cart subtotal is "100.00"
      When I apply discount code "SAVE10"
      Then the cart subtotal should be "90.00"

    Scenario: Reject an expired discount code
      Given my cart subtotal is "100.00"
      When I apply discount code "EXPIRED"
      Then I should see the "Invalid discount code" message
