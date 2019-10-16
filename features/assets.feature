Feature: Assets
  Background:
    Given an algod client
    And a kmd client
    And wallet information
    And asset test fixture

  Scenario Outline: Asset creation
    Given default asset creation transaction with total issuance <total>
    When I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I get the asset info
    Then the asset info should match the expected asset info

    Examples:
      | total |
      | 1 |

  Scenario Outline: Asset reconfigure
    Given default asset creation transaction with total issuance <total>
    When I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I get the asset info
    Then the asset info should match the transaction
    When I create a no-managers asset reconfigure transaction
    And I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I get the asset info
    Then the asset info should match the expected asset info

    Examples:
      | total |
      | 1 |

  Scenario Outline: Asset destroy
    Given default asset creation transaction with total issuance <total>
    When I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I create an asset destroy transaction
    And I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    When I get the asset info
    Then the asset info should match the expected asset info

    Examples:
      | total |
      | 1 |