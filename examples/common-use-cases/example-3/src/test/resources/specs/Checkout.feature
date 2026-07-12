Feature: Checkout

  A second feature whose marker also extends BaseShopSteps. The cart setup steps
  ("I have an empty shopping cart", "I add …") are reused straight from the base
  class — only the checkout-specific steps are implemented in CheckoutTest.

  Scenario: Check out an order
    Given I have an empty shopping cart
    When I add "Coffee Beans" with quantity "3" and unit price "12.50"
    And I check out
    Then the order total should be "37.50"
