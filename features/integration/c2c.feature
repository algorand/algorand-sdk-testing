@c2c
Feature: Contract to Contract Interaction
  Scenario:
    * an algod v2 client
    * a kmd client
    * wallet information
    * suggested transaction parameters from the algod v2 client
    * I create a new transient account and fund it with 100000000 microalgos.
    * I make a transaction signer for the transient account.

    ###### ------ app at context index 0: FakeRandom ------ ######
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/fake_random.teal", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    Given a new AtomicTransactionComposer
    # randInt(42) -> (r, witnessString)
    When I create the Method object from method signature "randInt(uint64)(uint64,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAAAAAAAACo=" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # randInt(1337) -> (r, witnessString)
    When I create the Method object from method signature "randInt(uint64)(uint64,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAAAAAAABTk=" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    Then I build the transaction group with the composer. If there is an error it is "".
    Then I gather signatures with the composer.
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    And The app should have returned ABI types "(uint64,byte[17])#(uint64,byte[17])".
    And Ze 0th atomic result for randomInt(42) proves correct
    And Ze 1th atomic result for randomInt(1337) proves correct
    And I can retrieve all inner transactions that were called from the atomic transaction with call graph "['randInt(uint64)(uint64,byte[17])','randInt(uint64)(uint64,byte[17])']".

    ###### ------ app at context index 1: RandomByte ------ ######
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/random_byte.teal", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.
    # Need to fund RandomByte because it pays for calling RandomInteger:
    And I fund the current application's address with 100000000 microalgos.

    Given a new AtomicTransactionComposer
    # randElement("hello",RandomByte) -> (c, witnessString)
    When I create the Method object from method signature "randElement(string,application)(byte,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAVoZWxsbw==,ctxAppIdx:0" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # randElement("goodbye",RandomByte) -> (c, witnessString)
    When I create the Method object from method signature "randElement(string,application)(byte,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAdnb29kYnll,ctxAppIdx:0" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    Then I build the transaction group with the composer. If there is an error it is "".

    Then I gather signatures with the composer.
    And I execute the current transaction group with the composer.
    Then The composer should have a status of "COMMITTED".
    And The app should have returned ABI types "(byte,byte[17])#(byte,byte[17])".
    And Ze 0th atomic result for randElement("hello") proves correct
    And Ze 1th atomic result for randElement("goodbye") proves correct
    And I can retrieve all inner transactions that were called from the atomic transaction with call graph "[{'randElement(string,application)(byte,byte[17])':'appl'},{'randElement(string,application)(byte,byte[17])':'appl'}]".

    ###### ----- app at context index 2: SlotMachine ----- ######
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/slot_machine.teal", clear-program "programs/one.teal.tok", global-bytes 3, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.
    # Need to fund SlotMachine because it pays for calling RandomByte:
    And I fund the current application's address with 100000000 microalgos.

    Given a new AtomicTransactionComposer

    # 2 X spin() -> (result, witness0, witness1, witness2)
    # First Spin:
    When I create the Method object from method signature "spin(application,application)(byte[3],byte[17],byte[17],byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "ctxAppIdx:0,ctxAppIdx:1" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # Spin #2:
    When I create the Method object from method signature "spin(application,application)(byte[3],byte[17],byte[17],byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "ctxAppIdx:0,ctxAppIdx:1" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # Atomic Transaction Execution and Analysis
    Then I build the transaction group with the composer. If there is an error it is "".
    And I gather signatures with the composer.
    And I execute the current transaction group with the composer.
    And The composer should have a status of "COMMITTED".
    And The app should have returned ABI types "(byte[3],byte[17],byte[17],byte[17])#(byte[3],byte[17],byte[17],byte[17])".
    And I can dig into the resulting atomic transaction execution tree with path "0,0,0"
    And I can dig into the resulting atomic transaction execution tree with path "0,2,0"
    And I can dig into the resulting atomic transaction execution tree with path "1,2,0"
    And I dig into the paths "0,0#0,1#0,2" of the resulting atomic transaction tree I see group ids and they are all the same
    And I can retrieve all inner transactions that were called from the atomic transaction with call graph "[{'spin(application,application)(byte[3],byte[17],byte[17],byte[17])':[{'appl':'appl'},{'appl':'appl'},{'appl':'appl'}]},{'spin(application,application)(byte[3],byte[17],byte[17],byte[17])':[{'appl':'appl'},{'appl':'appl'},{'appl':'appl'}]}]".
