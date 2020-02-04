Feature: Templates
  Background:
    Given an algod client
    And a kmd client
    And wallet information
    And contract test fixture

  Scenario Outline: Limit Order
    Given asset test fixture
    And default asset creation transaction with total issuance <total>
    When I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I update the asset index
    Given a limit order contract with parameters <ratn> <ratd> <min_trade>
    When I create a transaction for a second account, signalling asset acceptance
    And I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I create a transaction transferring <amount> assets from creator to a second account
    And I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I fund the contract account
    And I swap assets for algos
    Then the transaction should go through

    Examples:
      | total   | ratn | ratd | min_trade | amount
      | 1000000 | 2 | 3 | 1000 | 500000

  Scenario Outline: Dynamic Fee
    Given a dynamic fee contract with amount <amt>
    When I fund the contract account
    And I send the dynamic fee transactions
    Then the transaction should go through
    
    Examples:
      | amt |
      | 12345 |
    