Feature: DataTables

  This example demonstrates how Gherkin data tables are converted to DataTable parameters.

  Scenario: Creating multiple users
    Given I create the following users:
      | username | email              | role  |
      | john     | john@example.com   | admin |
      | jane     | jane@example.com   | user  |
      | bob      | bob@example.com    | user  |
    Then the system should have "3" users

  Scenario: Verifying product inventory
    When I check the inventory:
      | product | quantity |
      | Laptop  | 10       |
      | Mouse   | 50       |
    Then all products should be in stock
