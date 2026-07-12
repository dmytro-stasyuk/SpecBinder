Feature: Login

  Scenario: Successful login
    Given I am on the login page
    When I enter username "alice@example.com"
    And I enter password "secret123"
    And I click the login button
    Then I should be redirected to the dashboard

  Scenario: Failed login with wrong password
    Given I am on the login page
    When I enter username "alice@example.com"
    And I enter password "wrong"
    And I click the login button
    Then I should see "Invalid credentials"
