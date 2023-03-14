Feature: Simulating transactions
  Background:
    Given an algod v2 client
    And a kmd client
    And wallet information
    And suggested transaction parameters from the algod v2 client
    And I create a new transient account and fund it with 10000000 microalgos.
    And I make a transaction signer for the transient account.

  @simulate
  Scenario Outline: Simulating successful payment transactions
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I simulate the transaction
    Then the simulation should succeed without any failure message

    Examples:
      | amt     | note         |
      | 0       | X4Bl4wQ9rCo= |
      | 1234523 | X4Bl4wQ9rCo= |

  @simulate
  Scenario: Simulating unsigned payment transaction
    Given default transaction with parameters 100001 "X4Bl4wQ9rCo="
    When I prepare the transaction without signatures for simulation
    And I simulate the transaction
    Then the simulation should report missing signatures at group "0", transactions "0"

  @simulate
  Scenario: Simulating duplicate transactions in a group and overspending errors
    Given a new AtomicTransactionComposer
    When I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I build the transaction group with the composer. If there is an error it is "".
    And I gather signatures with the composer.
    And I simulate the current transaction group with the composer
    And the simulation should succeed without any failure message

    # Check for duplicate transaction errors
    And I clone the composer.
    When I add the current transaction with signer to the composer.
    Then I build the transaction group with the composer. If there is an error it is "".
    And I gather signatures with the composer.
    And I simulate the current transaction group with the composer
    And the simulation should report a failure at group "0", path "1" with message "transaction already in ledger"

    # Check for overspending errors
    Given a new AtomicTransactionComposer
    When I build a payment transaction with sender "transient", receiver "transient", amount 999999999, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should report a failure at group "0", path "0" with message "overspend"

  @simulate
  Scenario: Simulating unsigned transactions in the ATC group
    Given a new AtomicTransactionComposer
    When I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
    And I create a transaction with an empty signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should report missing signatures at group "0", transactions "0"
    
    # Add another unsigned transaction
    And I clone the composer.
    When I build a payment transaction with sender "transient", receiver "transient", amount 100002, close remainder to ""
    And I create a transaction with an empty signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should report missing signatures at group "0", transactions "0,1"

    # Check for an overspending error in addition to the unsigned transaction
    # Add another unsigned transaction
    And I clone the composer.
    When I build a payment transaction with sender "transient", receiver "transient", amount 999999999, close remainder to ""
    And I create a transaction with an empty signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    And the simulation should report missing signatures at group "0", transactions "0,1,2"
    And the simulation should report a failure at group "0", path "2" with message "overspend"

  @simulate
  Scenario: Simulating bad inner transactions in the ATC
    Given a new AtomicTransactionComposer
    # Create an app at context index 0: FakeRandom
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/fake_random.teal", clear-program "programs/six.teal", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.
    
    # Create another app at context index 1: RandomByte
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/random_byte.teal", clear-program "programs/six.teal", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # Need to fund RandomByte because it pays for calling RandomInteger in FakeRandom:
    And I fund the current application's address with 10000000 microalgos.

    # First, check that inner transaction simulation is okay.
    # The following two steps are taken from c2c.feature
    # randElement("hello",RandomByte) -> (c, witnessString)
    Given I add the nonce "Thing One"
    When I create the Method object from method signature "randElement(string,application)(byte,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAVoZWxsbw==,ctxAppIdx:0" to the method arguments array.
    * I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # randElement("goodbye",RandomByte) -> (c, witnessString)
    Given I add the nonce "Thing Two"
    When I create the Method object from method signature "randElement(string,application)(byte,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAdnb29kYnll,ctxAppIdx:0" to the method arguments array.
    * I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # The simulation should succeed with an ABI return
    Then I simulate the current transaction group with the composer
    And The app should have returned ABI types "(byte,byte[17]):(byte,byte[17])".
    And The 0th atomic result for randElement("hello") proves correct
    And The 1th atomic result for randElement("goodbye") proves correct

    # Clone the composer and add a bad inner transaction call.
    Then I clone the composer.
    Given I add the nonce "Thing Three"
    When I create the Method object from method signature "badMethod(string,application)void"
    And I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # The simulation should fail at the third transaction's first inner transaction (2,0) due to no app args being passed into the app.
    Then I simulate the current transaction group with the composer
    And the simulation should report a failure at group "0", path "2,0" with message "invalid ApplicationArgs"
