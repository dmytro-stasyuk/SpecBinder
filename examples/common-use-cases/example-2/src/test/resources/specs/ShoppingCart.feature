Feature: ShoppingCart

  Demonstrates the CUCUMBER_DATA_TABLE mode where Gherkin data tables
  are passed as Cucumber DataTable objects, giving access to the full
  Cucumber DataTable API for type conversions and POJO mapping.

  Scenario: Add products to cart
    Given my cart contains the following products:
      | name                | qty | unit price |
      | Wireless Headphones | 1   | 59.99      |
      | Coffee Beans 1kg    | 3   | 12.50      |
    Then the cart should contain "2" products

  Scenario: Verify user accounts
    Given the following users exist:
      | username | email              | role  |
      | alice    | alice@example.com  | admin |
      | bob      | bob@example.com    | user  |
      | carol    | carol@example.com  | user  |
    Then the system should have "3" users
