Feature: Simulating transactions
  Background:
    Given an algod v2 client
    And a kmd client
    And wallet information
    And suggested transaction parameters from the algod v2 client
    And I create a new transient account and fund it with 1000000 microalgos.
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
    Then the simulation should report a failure at group "0", path "0" with message "signedtxn has no sig"

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
    Then the simulation should report a failure at group "0", path "0" with message "signedtxn has no sig"

    # Add another unsigned transaction
    And I clone the composer.
    When I build a payment transaction with sender "transient", receiver "transient", amount 100002, close remainder to ""
    And I create a transaction with an empty signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    Then the simulation should report a failure at group "0", path "0" with message "signedtxn has no sig"

    # Check for an overspending error in addition to the unsigned transaction
    # Add another unsigned transaction
    And I clone the composer.
    When I build a payment transaction with sender "transient", receiver "transient", amount 999999999, close remainder to ""
    And I create a transaction with an empty signer with the current transaction.
    And I add the current transaction with signer to the composer.
    Then I simulate the current transaction group with the composer
    Then the simulation should report a failure at group "0", path "0" with message "signedtxn has no sig"

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

  @simulate.lift_log_limits
  Scenario: Simulate app call that logs more than 1024 bytes
    Given a new AtomicTransactionComposer
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/logs-a-lot.teal", clear-program "programs/six.teal", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # First we simulate without lifting log limits
    Given I add the nonce "simulate-without-log-limits"
    When I create the Method object from method signature "unlimited_log_test()void"
    * I create a new method arguments array.
    * I append the encoded arguments "" to the method arguments array.
    * I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    Then I simulate the current transaction group with the composer
    And the simulation should report a failure at group "0", path "0" with message "logic eval error: too many log calls in program. up to 32 is allowed."

    # Now we simulate with lifting log limits
    When I make a new simulate request.
    Then I allow more logs on that simulate request.
    Then I simulate the transaction group with the simulate request.

    # Final step to check log in simulation result
    Then I check the simulation result has power packs allow-more-logging.
    And the simulation should succeed without any failure message

  @simulate.extra_opcode_budget
  Scenario: Simulate app call that uses more than 700 opcode budgets
    Given a new AtomicTransactionComposer
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/int-pop-700.teal", clear-program "programs/eight.teal", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # First we simulate without extra budget
    Given I add the nonce "simulate-without-extra-budget"
    When I create the Method object from method signature "int_pop_700()void"
    * I create a new method arguments array.
    * I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    Then I simulate the current transaction group with the composer
    And the simulation should report a failure at group "0", path "0" with message "local program cost was 700."

    # Now we simulate with extra budget
    When I make a new simulate request.
    Then I allow 2000 more budget on that simulate request.
    Then I simulate the transaction group with the simulate request.

    # Final step to check extra budgets in simulation result
    Then I check the simulation result has power packs extra-opcode-budget with extra budget 2000.
    And the simulation should succeed without any failure message

  @simulate.exec_trace_with_stack_scratch
  Scenario: Simulate app with response containing stack and scratch changes
    Given a new AtomicTransactionComposer
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/stack-scratch.teal", clear-program "programs/eight.teal", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    Given I add the nonce "simulate-with-exec-trace-stack-scratch"
    When I make a new simulate request.
    When I create the Method object from method signature "manipulation(uint64)uint64"
    * I create a new method arguments array.
    * I append the encoded arguments "AAAAAAAAAAo=" to the method arguments array.
    * I add a nonced method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    Then I allow exec trace options "stack,scratch" on that simulate request.
    Then I simulate the transaction group with the simulate request.
    And the simulation should succeed without any failure message

    Then 4th unit in the "approval" trace at txn-groups path "0" should add value "uint64:1" to stack, pop 2 values from stack, write value "" to scratch slot "".
    Then 29th unit in the "approval" trace at txn-groups path "0" should add value "bytes:MSE=,bytes:NSE=" to stack, pop 0 values from stack, write value "" to scratch slot "".
    Then 31th unit in the "approval" trace at txn-groups path "0" should add value "" to stack, pop 1 values from stack, write value "uint64:18446744073709551615" to scratch slot "1".

  @simulate.exec_trace_with_state_change_and_hash
  Scenario Outline: Simulate app with response containing state changes and hash of executed byte code
    Given a new AtomicTransactionComposer
    When I build an application transaction with the transient account, the current application, suggested params, operation "create-and-optin", approval-program "programs/state-changes.teal", clear-program "programs/eight.teal", global-bytes 1, global-ints 1, local-bytes 1, local-ints 1, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.
    And I fund the current application's address with 1000000 microalgos.

    When I make a new simulate request.
    And I create the Method object from method signature "<method>"
    And I create a new method arguments array.
    And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments, boxes "0,str:box-key-1,0,str:box-key-2".

    Then I allow exec trace options "state" on that simulate request.
    And I simulate the transaction group with the simulate request.
    And the simulation should succeed without any failure message

    Then the current application initial "<state>" state should be empty.

    Then "approval" hash at txn-groups path "0" should be "elIoqp1XgWrLCBLPmaZlDsKE3sEMZBY1dlxOvBXPtak=".
    And <index1>th unit in the "approval" trace at txn-groups path "0" should write to "<state>" state "<key1>" with new value "<value1>".
    And <index2>th unit in the "approval" trace at txn-groups path "0" should write to "<state>" state "<key2>" with new value "<value2>".

    # Submit the group to the actual network
    Then I execute the current transaction group with the composer.

    # Simulate again so we can check the reported initial state.
    Given a new AtomicTransactionComposer
    When I make a new simulate request.
    And I create the Method object from method signature "<method>"
    And I create a new method arguments array.
    And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments, boxes "0,str:box-key-1,0,str:box-key-2,0,str:nonce-box".

    Then I allow exec trace options "state" on that simulate request.
    And I simulate the transaction group with the simulate request.
    And the simulation should succeed without any failure message

    Then the current application initial "<state>" state should contain "<key1>" with value "<value1>".
    And the current application initial "<state>" state should contain "<key2>" with value "<value2>".

    Examples:
      | method       | state  | index1 | key1           | value1                 | index2 | key2             | value2                     |
      | global()void | global | 14     | global-int-key | uint64:3735928559      | 17     | global-bytes-key | bytes:d2VsdCBhbSBkcmFodA== |
      | local()void  | local  | 15     | local-int-key  | uint64:3405689018      | 19     | local-bytes-key  | bytes:eHFjTA==             |
      | box()void    | box    | 14     | box-key-1      | bytes:Ym94LXZhbHVlLTE= | 17     | box-key-2        | bytes:                     |

  @simulate.populate_resources
  Scenario: Simulate with populate-resources set to true returns populated resource arrays for transactions and group
    # Create app
    Given a new AtomicTransactionComposer
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/resources.teal", clear-program "programs/resources.teal", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.
    And I fund the current application's address with 1000000 microalgos.

    # Call with simulate
    Given a new AtomicTransactionComposer
    When I add a app call with the transient account, the current application, suggested params, on complete "noop", current transaction signer
    And I make a new simulate request
    And I set populate-resources "true"
    And I simulate the transaction group with the transaction request
    Then the simulation should succeed without any failure message
    And the response should include populated-resource-arrays for the transaction
    And the response should include extra-resource-arrays for the group

