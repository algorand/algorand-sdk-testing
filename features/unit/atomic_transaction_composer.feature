@unit.atomic_transaction_composer
Feature: Atomic Transaction Composer
  Background:
    Given an algod v2 client
    And a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

  Scenario: AtomicTransactionComposer test
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Prepare a TransactionSigner
    When I make a transaction signer for the signing account.
    And I remember the transaction signer.
    # Create a method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transaction should equal "<golden>"

    Examples:
      | app-id | method-signature         | app-args       | golden |
      | 1      | add(uint64,uint64)uint64 | [int:1,int:1]  | RKOnhjF829416QxzYbn0Tho+5KhkXhTJjNjcDEXoYruaiKbxmJ1jBNj0C0wqW04RqsD8AsP1LucHED9Z8kRlBg== |
      | 1      | empty()void              | []             | OhzCAqT5JZdzcT4APT8flrTeNz/DRw3Cmo+k4o/HGw0pYqji9voeud69ZMrv7WbxaJGGp0azk9s05hbCPn4pDg== |

  Scenario: AtomicTransactionComposer with transaction arguments test
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the signing account.
    And I remember the transaction signer.
    And I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I remember the transaction with signer.
    # Create a method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the current transaction with signer and the "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transaction should equal "<golden>"

    Examples:
      | app-id | method-signature         | app-args                                                          | golden |
      | 1      | payment(pay,address)bool | [addr:BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4] | M9B18zJZybrzSZ80p4J+NgYqrYk6gkS2yac/397LauXhbPvYamPQXpM3os9iZv31uBMzg3x0yB9PsP5sL8MbCw== |
