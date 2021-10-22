Feature: Sending transactions
  Background: 
    Given an algod client
    And a kmd client
    And wallet information

  @send
  Scenario Outline: Sending transactions
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then the transaction should go through

    Examples: 
    | amt | note |
    | 0   | X4Bl4wQ9rCo= |
    | 1234523 | X4Bl4wQ9rCo= |

  @send
  Scenario Outline: Sending multisig transactions
    Given default multisig transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the multisig transaction with the private key
    And I send the multisig transaction
    Then the transaction should not go through

    Examples: 
    | amt | note |
    | 0   | X4Bl4wQ9rCo= |
    | 1234523 | X4Bl4wQ9rCo= |
  
  @send.keyregtxn
  Scenario Outline: Sending key registration transactions
    Given default V2 key registration transaction "<type>"
    And I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then the transaction should go through

    Examples:
    | type |
    | online |
    | offline |
    | nonparticipation|
