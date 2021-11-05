@abi
Feature: ABI Interaction
  Background:
    Given an algod v2 client

  Scenario Outline: AtomicTransactionComposer test
    Given I create a new transient account and fund it with 100000000 microalgos.
    # Application create with ARC-0004 compliant app should succeed with expected message. 
    And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    And I remember the new application ID.
    # Call with args '[subtract]' - REJECTED, program expects a method selector hash from a method signature.
    And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "[subtract]", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "transaction rejected by ApprovalProgram".
    # Call with method args should succeed, where the first arg is the method selector hash of the method signature, and the subsequent args are the method arguments.
    And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args <app-args>, foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    # The result should be logged and should be decoded into the expected result
    Then The app should have returned <returns> in the log.
    
    Examples:
      | app-args                                              | returns |
      | [0x8aa3b61f, 0x0000000000000001, 0x0000000000000001]  | 0x00000000000000000000000000000002 |
      | [0xe395f262]  | 0x00000000 |
      | [0x535a47ba, BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4]  | 0x0000000080 |

