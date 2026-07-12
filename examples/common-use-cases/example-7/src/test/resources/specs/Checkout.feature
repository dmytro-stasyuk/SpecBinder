Feature: Checkout

  Inherits shared options from BaseFeature but overrides
  shouldBeAbstract to true for this specific feature.

  Scenario: Complete a purchase
    Given I have a cart with "3" items
    When I proceed to checkout
    And I pay with card "4111111111111111"
    Then the order should be confirmed
