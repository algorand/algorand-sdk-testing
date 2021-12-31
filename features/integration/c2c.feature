@c2c
Feature: Contract to Contract Interaction
  Background:
    * an algod v2 client
    * a kmd client
    * wallet information
    * suggested transaction parameters from the algod v2 client
    * I create a new transient account and fund it with 100000000 microalgos.
    * I make a transaction signer for the transient account.


  # Scenario Outline: Compiled teals are as expected
  #   When I compile a teal program <teal>
  #   Then it is compiled with <status> and <result> and <hash>
  #   And base64 decoding the response <result> is the same as the binary <program>
  #   Examples:
  #     | teal                            | program                             | status | hash                                                         | result                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
  #     | "programs/one.teal"             | "programs/one.teal.tok"             | 200    | "YOE6C22GHCTKAN3HU4SE5PGIPN5UKXAJTXCQUPJ3KKF5HOAH646MKKCPDA" | "AiABASI="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
  #     | "programs/zero.teal"            | "programs/zero.teal.tok"            | 200    | "U4TBITSQWSG2G4IMJYBOJPEEC535YPRSFMR2JE3ZMXDGY27U3CCO4HPCKQ" | "AiABACI="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
  #     | "programs/abi_method_call.teal" | "programs/abi_method_call.teal.tok" | 200    | "EZD2SJS7UJI45CGG4GEVMCTPZCJ7GQNDUG74GU74C6WKOD2TEFAA7RNNBU" | "BSADAQACJgIEFR98dQRuYW1lMRgjEkAA4zEZgQQSNhoAgASg6BhyEhBAAMsxGSISNhoAgATPpo42EhBAALExGSQSNhoAgASp9Cs9EhBAAJoxGYEFEjYaAIAEJDeNPBIQQACCMRkjEjYaAIAE/mvfaRIQQABlMRkjEjYaAIAEqIwmpRIQQABOMRkjEjYaAIAEPjs9KBIQQAA0MRkjEjYaAIAEDfAFDxIQQAACI0M2GgE2GgI2GgM2GgQ2GgU2GgY2Ggc2Ggg2GgmIAPkiQzYaAYgAzCJDiACpIkM2GgE2GgKIAI4iQ4gAgiJDiABfIkM2GgGIADEiQ4gAKyJDMRsjDUAAAiJDNhoAgARDRkEBEkQ2GgGIAANC/+o1ACg0ABckCxZQsImJNQEjKTQBVwIAZoAGaGVsbG8gIyliUDUCKDQCFRZXBgJQNAJQsImACGdvb2RieWUgIyliUDUDKDQDFRZXBgJQNANQsIkxADIJEkSJNQU1BCg0BBc0BRcIFlCwiYAacmFuZG9tIGluY29uc2VxdWVudGlhbCBsb2ewiTUGMRYiCTgQIhJEKDEWIgk4CDQGFxJAAAaAAQBCAAOAAYBQsIk1DzUONQ01DDULNQo1CTUINQcoNAdQNAlQNAtQNAhQNA5QNA9QNApQNAxQNA1QsIk=" |
  #     | "programs/fake_random.teal"     | "programs/fake_random.teal.tok"     | 200    | "DOY24Q6DKONK356FOJ4ATH53DLKOUFDR4COCZHDXZ7HMCF4UDLCJOBDB2A" | "BTYaAIAEIGY1EBJAABUyBhYDgQBbNhoBGBaABBUffHVMULCBAQ=="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |


  # Scenario Outline: Compiled teals are as expected - skip the hash check
  #   When I compile a teal program <teal>
  #   Then base64 decoding the response <result> is the same as the binary <program>
  #   Examples:
  #     | teal                            | program                             | result |
  #     | "programs/one.teal"             | "programs/one.teal.tok"             | ""     |
  #     | "programs/zero.teal"            | "programs/zero.teal.tok"            | ""     |
  #     | "programs/abi_method_call.teal" | "programs/abi_method_call.teal.tok" | ""     |
  #     | "programs/fake_random.teal"     | "programs/fake_random.teal.tok"     | ""     |

  Scenario: Playing at the Casino using Contract to Contract Invocations
    When I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/fake_random.teal", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 1, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
    And I sign and submit the transaction, saving the txid. If there is an error it is "".
    And I wait for the transaction to be confirmed.
    Given I remember the new application ID.

    # ATC preface
    And a new AtomicTransactionComposer

    # randInt(42) -> (r, witness_string):
    * I create the Method object from method signature "randInt(uint64)(uint64,byte[17])"
    * I create a new method arguments array.
    * I append the encoded arguments "AAAAAAAAACo=" to the method arguments array.
    * I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # ATC finalization
    And I build the transaction group with the composer. If there is an error it is "".
    Then I gather signatures with the composer.
    And I execute the current transaction group with the composer.

    # ATC epilogue
    Then The composer should have a status of "COMMITTED".

    # Method analysis
    And The app should have returned ABI types "(uint64,byte[17])".
    And Ze atomic result at index 0 proves that randomness with input "AAAAAAAAACo=" was computed correctly for the ABI type.

# -- below still was a WIP
# Given I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 1, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
# #   Given I create a new transient account and fund it with 10000000 microalgos.
# #   And I make a transaction signer for the transient account.
# And a new AtomicTransactionComposer
# And an application id 0
# When I create the Method object from method signature "create(uint64)uint64"
# And I create a new method arguments array.
#   And I append the encoded arguments "AAAAAAAAAAQ=" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "<on-complete>", current transaction signer, current method arguments, approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, extra-pages 0.
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "AAAAAAAAAAg=".

# Examples:
#   | teal                      | program                       | status | result                                                 | hash                                                         |
#   | programs/fake_random.teal | programs/fake_random.teal.tok | 200    | "BTYaAIAEIGY1EBJAABUyBhYDgQBbNhoBGBaABBUffHVMULCBAQ==" | "DOY24Q6DKONK356FOJ4ATH53DLKOUFDR4COCZHDXZ7HMCF4UDLCJOBDB2A" |


# Scenario Outline: Method call execution with other transactions
#   Given a new AtomicTransactionComposer
#   # Create a pay transaction, create a TransactionSigner, and add it to the composer
#   When I build a payment transaction with sender "transient", receiver "transient", amount 100001, close remainder to ""
#   And I make a transaction signer for the transient account.
#   And I create a transaction with signer with the current transaction.
#   And I add the current transaction with signer to the composer.
#   # Try signing and compare the golden with the signed transaction
#   Then I gather signatures with the composer.
#   And The composer should have a status of "SIGNED".
#   # Clone the composer and build with a method call
#   And I clone the composer.
#   # Create a payment method call with an address argument, and add it to the composer
#   When I create the Method object from method signature "<method-signature>"
#   And I create a new method arguments array.
#   And I append the encoded arguments "<app-args>" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
#   # Build the group in the composer
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   # Execute the group and check that the log contains the correct return value
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   # Check that the log contains the expected value.
#   # Note that the <returns> is the exact log output, which is the base64 encoding
#   # of the value, with the first four bytes being the hash of "return"
#   And The app should have returned "<returns>".

#   Examples:
#     | method-signature         | app-args                  | returns      |
#     | add(uint64,uint64)uint64 | AAAAAAAAAAE=,AAAAAAAAAAI= | AAAAAAAAAAM= |
#     | empty()void              |                           |              |

# Scenario Outline: Method call noop execution
#   Given a new AtomicTransactionComposer
#   When I create the Method object from method signature "<method-signature>"
#   And I create a new method arguments array.
#   And I append the encoded arguments "<app-args>" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "<returns>".

#   Examples:
#     | method-signature | app-args | returns |
#     | empty()void      |          |         |
#     | add(uint64,uint64)uint64                                                                             | AAAAAAAAAAE=,AAAAAAAAAAI=                                                                                                                                                                                            | AAAAAAAAAAM= |
#     | add(uint64,uint64)uint64                                                                             | //////////4=,AAAAAAAAAAE=                                                                                                                                                                                            | //////////8= |
#     | referenceTest(account,application,account,asset,account,asset,asset,application,application)uint8[9] | Uabo7LuH+JfxYes3JwpJ4Fz3Kzoz5LYtZhWxaN8pa3g=,AAAAAAAAAAo=,Uabo7LuH+JfxYes3JwpJ4Fz3Kzoz5LYtZhWxaN8pa3g=,AAAAAAAAABQ=,1Hq2PnhdWWwQ3IvRrz0gZ8EZmoH68yc2DzLpab3P8uA=,AAAAAAAAABQ=,AAAAAAAAABU=,AAAAAAAAAAo=,AAAAAAAAAAs= | AQECAQECAAAB |

# Scenario: Method call optin and closeout execution
#   Given a new AtomicTransactionComposer
#   When I create the Method object from method signature "optIn(string)string"
#   And I create a new method arguments array.
#   # "Algorand Fan"
#   And I append the encoded arguments "AAxBbGdvcmFuZCBGYW4=" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "optin", current transaction signer, current method arguments.
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   # "hello Algorand Fan"
#   And The app should have returned "ABJoZWxsbyBBbGdvcmFuZCBGYW4=".

#   Given a new AtomicTransactionComposer
#   When I create the Method object from method signature "closeOut()string"
#   And I create a new method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "closeout", current transaction signer, current method arguments.
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   # "goodbye Algorand Fan"
#   And The app should have returned "ABRnb29kYnllIEFsZ29yYW5kIEZhbg==".

# Scenario: Method call update execution
#   Given I create a new transient account and fund it with 10000000 microalgos.
#   And I make a transaction signer for the transient account.
#   And a new AtomicTransactionComposer
#   When I create the Method object from method signature "update()void"
#   And I create a new method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "update", current transaction signer, current method arguments, approval-program "programs/one.teal.tok", clear-program "programs/one.teal.tok".
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "".

# Scenario Outline: Method call with pay txn execution
#   Given a new AtomicTransactionComposer
#   And I build a payment transaction with sender "transient", receiver "transient", amount 1000000, close remainder to ""
#   And I create a transaction with signer with the current transaction.
#   # Create a payment method call with an address argument, and add it to the composer
#   And I create the Method object from method signature "<method-signature>"
#   And I create a new method arguments array.
#   And I append the current transaction with signer to the method arguments array.
#   And I append the encoded arguments "<app-args>" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
#   # Build the group in the composer
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   # Execute the group and check that the log contains the correct return value
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "<returns>".

#   Examples:
#     | method-signature        | app-args     | returns |
#     | payment(pay,uint64)bool | AAAAAAAPQkA= | gA==    |
#     | payment(pay,uint64)bool | AAAAAAAPQkE= | AA==    |

# Scenario: Multiple method calls in one atomic group
#   Given a new AtomicTransactionComposer

#   # optIn(string)string
#   When I create the Method object from method signature "optIn(string)string"
#   And I create a new method arguments array.
#   And I append the encoded arguments "AAxBbGdvcmFuZCBGYW4=" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "optin", current transaction signer, current method arguments.

#   # payment(pay,uint64)bool
#   And I create the Method object from method signature "payment(pay,uint64)bool"
#   And I create a new method arguments array.
#   And I build a payment transaction with sender "transient", receiver "transient", amount 1234567, close remainder to ""
#   And I create a transaction with signer with the current transaction.
#   And I append the current transaction with signer to the method arguments array.
#   And I append the encoded arguments "AAAAAAAS1oc=" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

#   # empty()void
#   When I create the Method object from method signature "empty()void"
#   And I create a new method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

#   # add(uint64,uint64)uint64
#   When I create the Method object from method signature "add(uint64,uint64)uint64"
#   And I create a new method arguments array.
#   And I append the encoded arguments "AAAAAAAAAAE=,AAAAAAAAAAI=" to the method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

#   # closeOut()string
#   And I create the Method object from method signature "closeOut()string"
#   And I create a new method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "closeout", current transaction signer, current method arguments.

#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "ABJoZWxsbyBBbGdvcmFuZCBGYW4=,gA==,,AAAAAAAAAAM=,ABRnb29kYnllIEFsZ29yYW5kIEZhbg==".


# ________________

# Scenario: Method call delete execution
#   Given I create a new transient account and fund it with 100000000 microalgos.
#   And I make a transaction signer for the transient account.
#   And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/abi_method_call.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 1, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0
#   And I sign and submit the transaction, saving the txid. If there is an error it is "".
#   And I wait for the transaction to be confirmed.
#   And I remember the new application ID.
#   And a new AtomicTransactionComposer
#   When I create the Method object from method signature "delete()void"
#   And I create a new method arguments array.
#   And I add a method call with the transient account, the current application, suggested params, on complete "delete", current transaction signer, current method arguments.
#   And I build the transaction group with the composer. If there is an error it is "".
#   Then The composer should have a status of "BUILT".
#   And I gather signatures with the composer.
#   Then The composer should have a status of "SIGNED".
#   And I execute the current transaction group with the composer.
#   Then The composer should have a status of "COMMITTED".
#   And The app should have returned "".
