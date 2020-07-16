Feature: Applications
   Background:
      Given an algod client
      And a kmd client
      And wallet information
      And an algod v2 client connected to "localhost" port 60000 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

   @applications
   Scenario: Use every applications feature in one scenario, do it!
      # TODO: This test is a subset of @applications.verify - once everyone implements that one, get rid of this one.
      # Make these tests 'standalone'.
      # This should create a new, random account and save the public/private key for future steps to use.
      Given I create a new transient account and fund it with 100000000 microalgos.
      # Create application
      # depends on the transient account, and also the application id.
      # Use suggested params
      And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/one.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 1, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      # If error is an empty string, there should be no error.
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      And I remember the new application ID.
      # Update approval program to 'loccheck'
      And I build an application transaction with the transient account, the current application, suggested params, operation "update", approval-program "programs/loccheck.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn - with error (missing argument)
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "invalid ApplicationArgs index 0".
      # OptIn - with error - wrong argument (program requires 'str:hello')
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:goodbye", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "stack len is 3 instead of 1".
      # OptIn - success
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:write' to put the application in write mode
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:check,str:write' - REJECTED, program expects 'str:check,str:bar'
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "transaction rejected by ApprovalProgram".
      # Call with args 'str:check,str:bar' write something to the local account
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      #TODO: query account information and check data? Cannot add this until we update the REST API.
      # Closeout with args 'str:hello' for approval program
      And I build an application transaction with the transient account, the current application, suggested params, operation "closeout", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn with args 'str:write' to make sure this works too?
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      #TODO: query account information and check data? Cannot add this until we update the REST API.
      # Call with args 'str:check,str:bar', another test to do something with the application
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Delete application with args 'str:hello' for approval
      And I build an application transaction with the transient account, the current application, suggested params, operation "delete", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:hello', this should fail with error 'only clearing out is supported' since the application was deleted.
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "only clearing out is supported".
      # Clear with no args should succeed.
      And I build an application transaction with the transient account, the current application, suggested params, operation "clear", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      #TODO: query account information and check data? Cannot add this until we update the REST API.


   @applications.verified
   Scenario: Use every applications feature in one scenario, do it!
      # Make these tests 'standalone'.
      # This should create a new, random account and save the public/private key for future steps to use.
      Given I create a new transient account and fund it with 100000000 microalgos.
      # Create application
      # depends on the transient account, and also the application id.
      # Use suggested params
      And I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "programs/one.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 1, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      # If error is an empty string, there should be no error.
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      And I remember the new application ID.
      # Update approval program to 'loccheck'
      And I build an application transaction with the transient account, the current application, suggested params, operation "update", approval-program "programs/loccheck.teal.tok", clear-program "programs/one.teal.tok", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn - with error (missing argument)
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "invalid ApplicationArgs index 0".
      # OptIn - with error - wrong argument (program requires 'str:hello')
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:goodbye", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "stack len is 3 instead of 1".
      # OptIn - success
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:write' to put the application in write mode
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:check,str:write' - REJECTED, program expects 'str:check,str:bar'
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "transaction rejected by ApprovalProgram".
      # Call with args 'str:check,str:bar' write something to the local account
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      #TODO: query account information and check data? Cannot add this until we update the REST API.
      Then The application should have some metadata: in created apps "true", if created then apps total schema byte-slices 1 and uints 0, contain key "foo" with value "bar"
      # Closeout with args 'str:hello' for approval program
      And I build an application transaction with the transient account, the current application, suggested params, operation "closeout", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # OptIn with args 'str:write' to make sure this works too?
      And I build an application transaction with the transient account, the current application, suggested params, operation "optin", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:write", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      #TODO: query account information and check data? Cannot add this until we update the REST API.
      Then The application should have some metadata: in created apps "true", if created then apps total schema byte-slices 1 and uints 0, contain key "foo" with value "bar"
      # Call with args 'str:check,str:bar', another test to do something with the application
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:check,str:bar", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Delete application with args 'str:hello' for approval
      And I build an application transaction with the transient account, the current application, suggested params, operation "delete", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      And I wait for the transaction to be confirmed.
      # Call with args 'str:hello', this should fail with error 'only clearing out is supported' since the application was deleted.
      And I build an application transaction with the transient account, the current application, suggested params, operation "call", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "only clearing out is supported".
      # Clear with no args should succeed.
      And I build an application transaction with the transient account, the current application, suggested params, operation "clear", approval-program "", clear-program "", global-bytes 0, global-ints 0, local-bytes 0, local-ints 0, app-args "", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      #TODO: query account information and check data? Cannot add this until we update the REST API.
      Then The application should have some metadata: in created apps "true", if created then apps total schema byte-slices 1 and uints 0, contain key "foo" with value "bar"
