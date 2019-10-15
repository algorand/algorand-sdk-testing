Feature: Assets
  Background:
    Given an algod client
    And a kmd client
    And wallet information
    And asset test fixture

  Scenario Outline: Asset creation
    Given default asset creation transaction with total issuance <total>
    When I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then the transaction should go through
    When I get the asset info
    Then the asset info should match the creation transaction

    Examples:
      | total |
      | 1 |