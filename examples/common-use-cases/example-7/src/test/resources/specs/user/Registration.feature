Feature: Registration

  Scenario: Register a new account
    Given I am on the registration page
    When I register with email "bob@example.com" and password "secure456"
    Then my account should be created
    And I should receive a welcome email

  Scenario: Reject duplicate email
    Given a user with email "alice@example.com" already exists
    When I register with email "alice@example.com" and password "secure456"
    Then I should see "Email already in use"
