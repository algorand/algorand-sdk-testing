Feature: Applications
   Background:
      Given an algod client
      And a kmd client
      And wallet information
      And an algod v2 client connected to "localhost" port 60000 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

   @applications.verified
   Scenario Outline: <state-location> test - Use every applications feature!
      # Make these tests 'standalone'.
      # This should create a new, random account and save the public/private key for future steps to use.
      Given I create a new transient account and fund it with 100000000 microalgos.
      # Application create with extra pages should succeed with expected message.
      And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/big_app_program.teal.tok", clear-program "programs/big_app_program.teal.tok", global-bytes <global-bytes>, global-ints 0, local-bytes <local-bytes>, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 3, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "logic eval error: pc=704 dynamic cost budget exceeded, executing intc_1: local program cost was 700. Details: pc=704, opcodes=intc_1 // 1".

      # Create application
      # depends on the transient account, and also the application id.
      # Use suggested params
      And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/one.teal.tok", clear-program "programs/one.teal.tok", global-bytes <global-bytes>, global-ints 0, local-bytes <local-bytes>, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      # If error is an empty string, there should be no error.
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      And I remember the new application ID.
      Then I get the account address for the current application and see that it matches the app id's hash
      # Update approval program to 'loccheck'
      Given I build an application transaction with the transient account, the current application, suggested params, operation "update", approval-program "<program>", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn - with error (missing argument)
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "invalid ApplicationArgs index 0".
      # OptIn - with error - wrong argument (program requires 'str:hello')
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:goodbye", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "stack len is 3 instead of 1".
      # OptIn - success
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # App should be listed in created apps list with schema settings, with no local/global state.
      Then The transient account should have the created app "true" and total schema byte-slices 1 and uints 0, the application "<state-location>" state contains key "" with value ""
      # Call with args 'str:write' to put the application in write mode
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:check,str:write' - REJECTED, program expects 'str:check,str:bar'
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:write", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "transaction rejected by ApprovalProgram".
      # Call with args 'str:check,str:bar' write something to the local account
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Local state should now include foo bar
      Then The transient account should have the created app "true" and total schema byte-slices 1 and uints 0, the application "<state-location>" state contains key "Zm9v" with value "YmFy"
      # Closeout with args 'str:hello' for approval program
      And I build an application transaction with the transient account, the current application, suggested params, operation "closeout", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn with args 'str:write' to make sure this works too?
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # The key/value should still be there.
      Then The transient account should have the created app "true" and total schema byte-slices 1 and uints 0, the application "<state-location>" state contains key "Zm9v" with value "YmFy"
      # Call with args 'str:check,str:bar', another test to do something with the application
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Delete application with args 'str:hello' for approval
      And I build an application transaction with the transient account, the current application, suggested params, operation "delete", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:hello', this should fail with error 'only clearing out is supported' since the application was deleted.
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "only clearing out is supported".
      # Clear with no args should succeed.
      And I build an application transaction with the transient account, the current application, suggested params, operation "clear", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Verify that the data has been removed from the total schema and the app list.
      Then The transient account should have the created app "false" and total schema byte-slices 0 and uints 0, the application "<state-location>" state contains key "" with value ""

      Examples:
         | program                     | state-location | global-bytes | local-bytes |
         | programs/loccheck.teal.tok  | local          | 0            | 1           |
         | programs/globcheck.teal.tok | global         | 1            | 0           |

   @applications.boxes
   Scenario: Exercise box features
      # Make these tests 'standalone'.
      # This should create a new, random account and save the public/private key for future steps to use.
      Given I create a new transient account and fund it with 10000000000 microalgos.
      # Create application
      # depends on the transient account, and also the application id.
      # Use suggested params
      And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/box_app.teal.tok", clear-program "programs/box_app.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes ""
      # If error is an empty string, there should be no error.
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      And I remember the new application ID.
      And I fund the current application's address with 100000000 microalgos.
      Then I get the account address for the current application and see that it matches the app id's hash
      # app call to create box
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:create,str:name", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes "0,str:name"
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      Then the contents of the box with name "str:name" should be "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA". If there is an error it is "".
      # app call to set box value
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:set,str:name,str:value", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes "0,str:name"
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      Then the contents of the box with name "str:name" should be "dmFsdWUAAAAAAAAAAAAAAAAAAAAAAAAA". If there is an error it is "".
      # app call to delete the box
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:delete,str:name", foreign-apps "", foreign-assets "", app-accounts "", extra-pages 0, boxes "0,str:name"
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      Then the contents of the box with name "str:name" should be "". If there is an error it is "box not found".
