Feature: Simulating transactions
  Background:
    Given an algod v2 client connected to "localhost" port 4001 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    And a kmd client
    And wallet information
    And suggested transaction parameters from the algod v2 client

  @simulate
  Scenario Outline: Simulating successful payment transactions
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I simulate the transaction
    Then the simulation should succeed

    Examples:
      | amt     | note         |
      | 0       | X4Bl4wQ9rCo= |
      | 1234523 | X4Bl4wQ9rCo= |

  @simulate
  Scenario: Simulating duplicate transactions in a group
    Given a new AtomicTransactionComposer
    And I create a new transient account and fund it with 100000000 microalgos.
    When I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
    And I make a transaction signer for the transient account.
    And I create a transaction with signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should succeed
    And I clone the composer.
    When I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should fail at path "1" with message "transaction already in ledger"
