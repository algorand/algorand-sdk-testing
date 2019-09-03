Feature: Algod
  Background:
    Given an algod client

  Scenario: Node health
    Then the node should be healthy

  Scenario: Status check
    When I get the status
    And I get status after this block
    Then I can get the block info

  Scenario: Ledger supply
    When I get the ledger supply
    Then the ledger supply should tell me the total money

  Scenario: Getting transactions
    Given a kmd client
    And wallet information
    Then I get transactions by address and round
    And I get pending transactions
    And I get transactions by address only
    And I get transactions by address and date

  Scenario Outline: Get Transactions By Address and Limit Count
    Given a kmd client
    And wallet information
    When I get recent transactions, limited by <cnt> transactions
    Examples:
      | cnt |
      | 0   |
      | 1   |
    
  Scenario: Suggested params
    When I get the suggested params
    And I get the suggested fee
    Then the fee in the suggested params should equal the suggested fee

  Scenario: Version
    When I get versions with algod
    Then v1 should be in the versions

  Scenario: Account information
    Given a kmd client
    And wallet information
    Then I get account information
