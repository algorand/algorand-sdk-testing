Feature: Templates
  Background:
    Given an algod client
    And a kmd client
    And wallet information
    And contract test fixture

  Scenario Outline: Split
    Given a split contract with ratio <ratn> to <ratd> and minimum payment <min_pay>
    When I send the split transactions
    Then the transaction should go through

    Examples:
      | ratn | ratd | min_pay |
      | 123  | 456  | 2000 |

  Scenario Outline: HLTC
    Given an HTLC contract with hash preimage "<preimage>"
    When I fund the contract account
    And I claim the algos
    Then the transaction should go through

    Examples:
      | preimage |
      | hello |

  Scenario Outline: Periodic Payment
    Given a periodic payment contract with withdrawing window <wd_window> and period <period>
    When I fund the contract account
    And I claim the periodic payment
    Then the transaction should go through

    Examples:
      | wd_window | period |
      | 999 | 2 |
  
  Scenario Outline: Limit Order
    Given asset test fixture
    And default asset creation transaction with total issuance <total>
    When I sign the transaction with kmd
    And I send the kmd-signed transaction
    Then the transaction should go through
    Given a limit order contract with parameters <ratn> <ratd> <min_trade>
    When I fund the contract account
    And I swap assets for algos
    Then the transaction should go through
  
    Examples:
      | total | ratn | ratd | min_trade |
      | 1000000 | 2 | 3 | 1000 |

  Scenario Outline: Dynamic Fee
    Given a dynamic fee contract with amount <amt>
    When I send the group transaction
    Then the transaction should go through
    
    Examples:
      | amt |
      | 12345 |
    