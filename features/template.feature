Feature: Templates
  Background:
    Given an algod client
    And a kmd client
    And wallet information

  Scenario Outline: Split
    Given a split contract with ratio <ratn> to <ratd>
    When I send the split transactions
    Then the transaction should go through

    Examples:
      | ratn | ratd |
      | 123  | 456  |

  Scenario Outline: HLTC
    Given an HTLC contract with hash image "<hash_image>" and max fee <max_fee>
    When I fund the contract account
    And I claim the algos
    Then the transaction should go through

    Examples:
      | hash_image | max_fee |
      | f4OxZX/x/FO5LcGBSKHWXfwtSx+j1ncoSt3SABJtkGk= | 2345 |

  Scenario Outline: Periodic Payment
    Given a periodic payment contract with withdrawing window <wd_window> and period <period>
    When I fund the contract account
    And I claim the periodic payment
    Then the transaction should go through

    Examples:
      | wd_window | period |
      | 999 | 2 |
  
  Scenario Outline: Limit Order
    Given a limit order contract with parameters <ratn> <ratd> <min_trade> <max_fee>
    When I fund the contract account
    And I swap assets for algos
    Then the transaction should go through
  
    Examples:
      | ratn | ratd | min_trade | max_fee |
      | 2 | 3 | 1000 | 2345 |

  Scenario Outline: Dynamic Fee
    Given a dynamic fee contract with amount "<amt>"
    When send the group transaction
    Then the transaction should go through
    
    Examples:
      | amt |
      | 12345 |
    