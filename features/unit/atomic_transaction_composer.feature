@unit.atomic_transaction_composer
Feature: Atomic Transaction Composer
  Background:
    Given an algod v2 client
    And a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

  Scenario Outline: AtomicTransactionComposer test
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Prepare a TransactionSigner
    When I make a transaction signer for the signing account.
    # Create a method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the app args "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | app-id | method-signature         | app-args                   | goldens |
      | 1      | add(uint64,uint64)uint64 | AAAAAAAAAAE=,AAAAAAAAAAE=  | gqNzaWfEQKPkHrOtBMTPm7qTZMRooHVd6RlY4JPBmTLxAkK/S3XXxbMxdgjgamBSMnggCcfDkBEBs1DQ4uUJtqk0i9NuBQ+jdHhuiqRhcGFhk8QE/mvfacQIAAAAAAAAAAHECAAAAAAAAAABpGFwaWQBo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDo2dycMQgj5pOhWq3iIfFuofhPkafjYa/74vyjNorHGo0OQcfbMqibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= |
      | 1      | empty()void              |                            | gqNzaWfEQPOa36RN6DijPn6IiPgxdLT7y10QtSxOrPIos5+b9tydz0/qh57Sll2XDGiWIbfKVALQvGh4mLL+zmqVhx2yNQWjdHhuiqRhcGFhkcQEqIwmpaRhcGlkAaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEINsh+E1abNTn1+PNpQu7tLDLPJ1XQ3PTOiKOI3m/wJayomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs |

  Scenario Outline: AtomicTransactionComposer with transaction arguments test
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the signing account.
    And I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    # Create a method call with an address argument, and add it to the composer
    And I build a method with signature "<method-signature>".
    And I prepare the method arguments with the current transaction with signer and the app args "<app-args>".
    And I add a method call with the signing account, the current application, suggested params, operation "call", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | app-id | method-signature         | app-args                                     | goldens |
      | 1      | payment(pay,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gqNzaWfEQCv0jOhwTJjQfJ9KXm6SJdeGAFea7brEq0BbwBDVMA577Rx3rooi9Ck/ZnExT66+a/kJpUGoPcjdrZoR7QLHHQSjdHhuiqNhbXTOAAGGoaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIN9TXFmEUnoCj+aTGTY6FrNbiCumYIoSgBhMZBZ1/HwOomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQDujKdRruRn6Xg46ZPBIfnL6eooQBqwTRyt9s05bDnc9I3NNqK7SBTuzKcvMes5PTbHxUw/GaNRbQo750PTtCgGjdHhuiqRhcGFhksQEU1pHusQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kYXBpZAGjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCDfU1xZhFJ6Ao/mkxk2OhazW4grpmCKEoAYTGQWdfx8DqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
