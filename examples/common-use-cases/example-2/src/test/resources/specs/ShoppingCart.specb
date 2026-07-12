Feature: ShoppingCart

  Demonstrates how Gherkin doc strings map to String parameters
  with formatting preserved via Java text blocks.

  Scenario: Submit a shipping address as JSON
    Given I have a shopping cart with items
    When I submit the following shipping address:
      """
      {
        "line1": "Baker St 221B",
        "city": "London",
        "postcode": "NW1 6XE",
        "country": "UK"
      }
      """
    Then the order should be ready for checkout

  Scenario: Add item with JSON options
    Given I have a shopping cart with items
    When I add item "Wireless Headphones" with options:
      """
      {
        "color": "Black",
        "warranty": "2 years",
        "gift_wrap": true
      }
      """
    Then the cart should contain "1" customized item

  Scenario: Display order confirmation as plain text
    Given I have completed a purchase
    Then I should receive the following confirmation:
      """
      Thank you for your order!

      Order #12345
      Items: 3
      Total: €97.49

      Your order will be shipped within 2 business days.
      """
