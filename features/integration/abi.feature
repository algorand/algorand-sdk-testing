@abi
Feature: ABI Interaction
  Background:
    Given an algod v2 client
    And a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"
    And suggested transaction parameters from the algod v2 client

  Scenario: AtomicTransactionComposer test
    Given a new AtomicTransactionComposer
    And I fund the signing account with 100000000 microalgos.
    # Application create with ARC-0004 compliant app should succeed with expected message. 
    And I build an application transaction with the signing account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    And I remember the new application ID.
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 100001, close remainder to ""
    And I remember the payment transaction.
    And I make a transaction signer for the signing account.
    And I remember the transaction signer.
    And I add the current transaction and current transaction signer to the composer.
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    # Clone the composer and build with a method call
    And I clone the composer.
    # Create a payment method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And I submit the current transaction group with the composer.
    Then The composer should have a status of "SUBMITTED".
    # Execute the group and check that the log contains the correct return value
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    And The app should have returned "<returns>" in the log.

    Examples:
      | method-signature         | app-args                                                  | returns |
      | add(uint64,uint64)uint64 | [int:1,int:1]                                             | 151f7c750000000000000002 |
      | empty()void              | []                                                        | 151f7c75 |

  Scenario: AtomicTransactionComposer with transaction arguments test
    Given a new AtomicTransactionComposer
    And I fund the signing account with 100000000 microalgos.
    # Application create with ARC-0004 compliant app should succeed with expected message. 
    And I build an application transaction with the signing account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    And I remember the new application ID.
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the signing account.
    And I remember the transaction signer.
    And I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I remember the transaction with signer.
    # Create a payment method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the current transaction with signer and the "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, app-args "<app-args>".
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And I submit the current transaction group with the composer.
    Then The composer should have a status of "SUBMITTED".
    # Execute the group and check that the log contains the correct return value
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    And The app should have returned "<returns>" in the log.

    Examples:
      | method-signature         | app-args                                                           | returns |
      | payment(pay,address)bool | [addr:BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4]  | 151f7c7580 |
