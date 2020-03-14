Feature: Algod REST API v2
  Background:
    Given an algod client pointing at a mock server

  Scenario: Shutdown
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Register Participation Keys
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Pending Transaction Information
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Send Raw Transaction
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Pending Transactions By Address
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Node Status
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Ledger Supply
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Status After Block
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Account Information
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Get Block
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Pending Transactions
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Suggested Transaction Parameters
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil
