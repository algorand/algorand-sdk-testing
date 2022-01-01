@c2c
Feature: Contract to Contract Interaction
  Background:
    * an algod v2 client
    * a kmd client
    * wallet information
    * suggested transaction parameters from the algod v2 client
    * I create a new transient account and fund it with 100000000 microalgos.
    * I make a transaction signer for the transient account.

  Scenario: Playing at the Casino using Contract to Contract Invocations

    # Application creation phase

    # application 0: FakeRandom
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/fake_random.teal", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # application 1: RandomByte
    And I create a new method arguments array.
    * I append the encoded arguments "b64:JA0vZw==" to the method arguments array.
    * I append the app-id of the 0th app to the method arguments array.
    * I build an application transaction with the transient account, the current application with method args, suggested params, operation "create", approval-program "programs/random_byte.teal", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # Composer preface
    And a new AtomicTransactionComposer

    # Build-up phase

    # randInt(42) -> (r, witnessString)
    * I create the Method object from method signature "randInt(uint64)(uint64,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAAAAAAAACo=" to the method arguments array.
    * I add a method call with the transient account, the 0th app, suggested params, on complete "noop", current transaction signer, current method arguments.

    # Composer finalization
    And I build the transaction group with the composer. If there is an error it is "".
    Then I gather signatures with the composer.
    And I execute the current transaction group with the composer.

    # Composer epilogue
    Then The composer should have a status of "COMMITTED".

    # Method analysis
    And The app should have returned ABI types "(uint64,byte[17])".
    And Ze atomic result at index 0 proves that randomness with input "AAAAAAAAACo=" was computed correctly for the ABI type.
