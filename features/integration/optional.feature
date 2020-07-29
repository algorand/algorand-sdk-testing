Feature: Optional Tests (Algod Testing)
  # These are optional for the SDKs to implement
  # because their primary purpose is testing algod
  #
   Background:
      Given a kmd client
      And wallet information
      And an algod v2 client connected to "localhost" port 60000 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      And I create a new transient account and fund it with 100000000 microalgos.

  @optional
  Scenario Outline:Algod Apply Data (<state-location>)
      # Create app
      Given I build an application transaction with the transient account, the current application, suggested params, operation "create", approval-program "<program>", clear-program "programs/one.teal.tok", global-bytes <global-bytes>, global-ints 0, local-bytes <local-bytes>, local-ints 0, app-args "str:hello", foreign-apps "", app-accounts ""
      And I sign and submit the transaction, saving the txid. If there is an error it is "".
      Then the unconfirmed pending transaction by ID should have no apply data fields.
      And I wait for the transaction to be confirmed.
      Then the confirmed pending transaction by ID should have a "<state-location>" state change for "foo" to "bar"

    Examples:
      | program                     | state-location | global-bytes | local-bytes |
      | programs/locwrite.teal.tok  | local          | 0            | 1           |
      | programs/globwrite.teal.tok | global         | 1            | 0           |
