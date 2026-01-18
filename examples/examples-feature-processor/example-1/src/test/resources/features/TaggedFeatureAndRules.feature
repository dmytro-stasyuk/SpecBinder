@integration @api
Feature: TaggedFeatureAndRules

  This example demonstrates how tags can be applied at Feature and Rule levels,
  in addition to Scenario level.

  @payment
  Rule: Payment processing

    Scenario: Credit card payment
      Given I have a valid credit card
      When I process a payment of "100"
      Then the payment should be successful

    @fast
    Scenario: Quick payment validation
      Given I have a payment request
      When I validate the payment
      Then validation should complete quickly

  @shipping @external
  Rule: Shipping calculations

    @domestic
    Scenario: Domestic shipping cost
      Given I have a domestic address
      When I calculate shipping cost
      Then the cost should be "10"

    @international
    Scenario: International shipping cost
      Given I have an international address
      When I calculate shipping cost
      Then the cost should be "50"
