Feature: Algod REST API v2
  Background:
    Given an algod client pointing at a mock server

  Scenario: Shutdown
    When I call algodclient Shutdown with option <timeout>
    Then the most recent error should be nil

  Scenario: Register Participation Keys
    When I register participation keys with account <account> and options <fee> <keyDilution> <roundLastValid> <noWait>
    Then the most recent error should be nil

  Scenario: Pending Transaction Information
    When I get pending transaction information about txid <txid>
    Then the most recent error should be nil

  Scenario: Send Raw Transaction
    When I send raw transaction with b64 transaction <b64tx>
    Then the most recent error should be nil

  Scenario: Pending Transactions By Address
    When I get pending transactions for address <address> with max <max>
    Then the most recent error should be nil

  Scenario: Node Status
    When I get node status
    Then the most recent error should be nil

  Scenario: Ledger Supply
    When I get the ledger supply
    Then the most recent error should be nil

  Scenario: Status After Block
    When I get the node status after block <round>
    Then the most recent error should be nil

  Scenario: Account Information
    When I get account information about address <address>
    Then the most recent error should be nil

  Scenario: Get Block
    When I get block for round <round>
    Then the most recent error should be nil

  Scenario: Pending Transactions
    When I get pending transactions with maximum <max>
    Then the most recent error should be nil

  Scenario: Suggested Transaction Parameters
    When I get the suggested transaction parameters
    Then the most recent error should be nil
