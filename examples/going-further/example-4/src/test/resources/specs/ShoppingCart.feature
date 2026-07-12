@cart
Feature: ShoppingCart

  Demonstrates the SpecBinder execution reporter. Running `mvn test` in this module
  produces target/specbinder-reports/specs/ShoppingCart.feature.json containing the
  hierarchical execution tree: top-level scenarios, a Scenario Outline with examples,
  and a Rule with its own scenarios.

  Scenario: A new cart is empty
    Given I have a new cart
    Then the cart total should be "0.00"

  @smoke
  Scenario: Adding an item updates the total
    Given I have a new cart
    When I add an item priced "9.99" with quantity "2"
    Then the cart total should be "19.98"

  @smoke
  Scenario: Intentional failure to populate the report's error block
    Given I have a new cart
    When I add an item priced "10.00" with quantity "1"
    Then the cart total should be "999.99"

  Scenario: Aborted because a precondition is unavailable
    Given the upstream pricing service is unavailable
    Then the cart total should be "0.00"

  Scenario Outline: Subtotal grows linearly with quantity
    Given I have a new cart
    When I add an item priced <unit price> with quantity <qty>
    Then the cart total should be <expected total>

    Examples:
      | qty | unit price | expected total |
      | 1   | 9.99       | 9.99           |
      | 3   | 10.00      | 30.00          |
      | 5   | 4.50       | 22.50          |

  Rule: Discount codes apply a percentage reduction

    A valid code reduces the subtotal by its percentage; unknown codes are
    ignored. This rule-level description shows up as a @Description annotation
    (and a description field in the JSON report) when descriptionAsAnnotation is on.

    Scenario: A valid discount applies the percentage
      Given I have a cart with subtotal "100.00"
      When I apply discount code "SAVE10"
      Then the cart total should be "90.00"

    Scenario: An invalid discount leaves the subtotal unchanged
      Given I have a cart with subtotal "100.00"
      When I apply discount code "BOGUS"
      Then the cart total should be "100.00"
