Feature: ShoppingCart

  Demonstrates Scenario Outline with Examples tables for data-driven testing.

  Scenario Outline: Subtotal updates when quantity changes
    Given my cart contains <name> with quantity <start qty> and unit price <price>
    When I change the quantity to <new qty>
    Then the cart subtotal should be <expected subtotal>

    Examples:
      | name                | start qty | price | new qty | expected subtotal |
      | Wireless Headphones | 1         | 60.00 | 2       | 120.00            |
      | Coffee Beans 1kg    | 2         | 15.50 | 3       | 46.50             |
      | USB-C Cable         | 1         | 8.99  | 5       | 44.95             |

  Scenario Outline: Shipping cost depends on order subtotal
    Given my cart subtotal is <subtotal>
    When I view the shipping options
    Then the shipping cost should be <shipping cost>

    Examples: Domestic orders
      | subtotal | shipping cost |
      | 30.00    | 5.99          |
      | 50.00    | 0.00          |
      | 75.00    | 0.00          |

    Examples: Small orders
      | subtotal | shipping cost |
      | 10.00    | 8.99          |
      | 5.00     | 8.99          |
