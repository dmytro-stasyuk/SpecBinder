Feature: ShoppingCart

  Demonstrates how Gherkin data tables map to type-safe
  generated Java classes with typed accessors.

  Background:
    Given my cart contains the following products:
      | name                | qty | unit price | in stock |
      | Wireless Headphones | 1   | 59.99      | true     |
      | Coffee Beans 1kg    | 3   | 12.50      | true     |
      | USB-C Cable         | 2   | 8.99       | false    |

  Scenario: Calculate cart subtotal from item list
    When I calculate the subtotal
    Then the cart subtotal should be "115.47"

  Scenario: Check stock availability
    When I check stock availability
    Then I should see the following out of stock products:
      | name        |
      | USB-C Cable |

  Rule: Bulk discounts apply to large orders

    Scenario: Apply bulk discount to qualifying items
      Given the following discount thresholds:
        | min qty | discount percent |
        | 3       | 10               |
        | 5       | 20               |
      When I apply bulk discounts
      Then I should see the following price adjustments:
        | name             | original price | discounted price |
        | Coffee Beans 1kg | 12.50          | 11.25            |
