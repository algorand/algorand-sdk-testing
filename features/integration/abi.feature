@abi
Feature: ABI Interaction
  Background:
    Given an algod v2 client
    And a kmd client
    And wallet information
    And suggested transaction parameters from the algod v2 client

  Scenario Outline: AtomicTransactionComposer test
    Given a new AtomicTransactionComposer
    And I create a new transient account and fund it with 100000000 microalgos.
    # Application create with ARC-0004 compliant app should succeed with expected message.
    And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    And I remember the new application ID.
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
    And I make a transaction signer for the transient account.
    And I create a transaction with signer with the current transaction.
    And I add the current transaction with signer to the composer.
    # Try signing and compare the golden with the signed transaction
    Then I gather signatures with the composer.
    And The composer should have a status of "SIGNED".
    # Clone the composer and build with a method call
    And I clone the composer.
    # Create a payment method call with an address argument, and add it to the composer
    When I create the Method object from method signature "<method-signature>"
    And I create a new method arguments array.
    And I append the encoded arguments "<app-args>" to the method arguments array.
    And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    # Execute the group and check that the log contains the correct return value
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    # Check that the log contains the expected value.
    # Note that the <returns> is the exact log output, which is the base64 encoding
    # of the value, with the first four bytes being the hash of "return"
    And The app should have returned "<returns>".

    Examples:
      | method-signature         | app-args                  | returns      |
      | add(uint64,uint64)uint64 | AAAAAAAAAAE=,AAAAAAAAAAE= | AAAAAAAAAAI= |
      | empty()void              |                           |              |

  Scenario Outline: AtomicTransactionComposer with transaction arguments test
    Given a new AtomicTransactionComposer
    And I create a new transient account and fund it with 100000000 microalgos.
    # Application create with ARC-0004 compliant app should succeed with expected message.
    And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    And I remember the new application ID.
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the transient account.
    And I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    # Create a payment method call with an address argument, and add it to the composer
    And I create the Method object from method signature "<method-signature>"
    And I create a new method arguments array.
    And I append the current transaction with signer to the method arguments array.
    And I append the encoded arguments "<app-args>" to the method arguments array.
    And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    # Execute the group and check that the log contains the correct return value
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    And The app should have returned "<returns>".

    Examples:
      | method-signature         | app-args                                     | returns |
      | payment(pay,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gA==    |
