Feature: ReceiptWriter

  Demonstrates JUnit parameter resolution in step methods:
  - `@TempDir Path` gives each test a fresh receipt output directory
  - `TestInfo` enriches the failure message with the test display name
  - A custom `@JUnitResolved Clock` (resolved by `FixedClockResolver`) makes
    the receipt timestamp deterministic and independent of system time

  Scenario: Write a timestamped receipt for an order
    Given an order "ORD-001" with items has been placed
    Then the receipt file exists
    And the receipt is timestamped with the test clock
