Feature: Sending transactions
  Background:
    Given an algod v2 client connected to "localhost" port 60000 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    And a kmd client
    And wallet information

  @send
  Scenario Outline: Sending transactions
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then I wait for the transaction to be confirmed.

    Examples:
      | amt     | note         |
      | 0       | X4Bl4wQ9rCo= |
      | 1234523 | X4Bl4wQ9rCo= |

  @send
  Scenario Outline: Sending multisig transactions
    Given default multisig transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the multisig transaction with the private key
    And I send the multisig transaction
    Then the transaction should not go through

    Examples:
      | amt     | note         |
      | 0       | X4Bl4wQ9rCo= |
      | 1234523 | X4Bl4wQ9rCo= |

  @send.keyregtxn
  Scenario Outline: Sending key registration transactions
    Given default V2 key registration transaction "<type>"
    When I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then I wait for the transaction to be confirmed.

    Examples:
      | type             |
      | online           |
      | offline          |
      | nonparticipation |
