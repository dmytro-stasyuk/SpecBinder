Feature: ShoppingCart

  Demonstrates compile-time safety for data table values
  by refining generated String fields to enum types.
  If a feature file value doesn't match a valid enum constant,
  you get a compiler error — not a runtime failure.

  Scenario: Cart with categorized products
    Given my cart contains the following products:
      | name                | qty | unit price | category    |
      | Wireless Headphones | 1   | 59.99      | electronics |
      | Coffee Beans 1kg    | 3   | 12.50      | grocery     |
      | Running Shoes       | 1   | 89.99      | sports      |
    When I calculate the subtotal
    Then the cart subtotal should be "187.48"

  Scenario: Filter cart by category
    Given my cart contains the following products:
      | name                | qty | unit price | category    |
      | Wireless Headphones | 1   | 59.99      | electronics |
      | USB-C Cable         | 2   | 8.99       | electronics |
      | Coffee Beans 1kg    | 1   | 12.50      | grocery     |
    When I filter by category "electronics"
    Then the filtered items should total "77.97"
