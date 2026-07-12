Feature: Checkout

  Scenario: Checkout with valid payment
    Given I have a cart with "3" items
    When I proceed to checkout
    And I pay with card "4111111111111111"
    Then the order should be confirmed

  Scenario: Checkout with empty cart
    Given I have an empty shopping cart
    When I proceed to checkout
    Then I should see "Cannot checkout with an empty cart"
