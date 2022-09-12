Feature: Easy Integration Testing
  Background:
    * a kmd client
    * an algod v2 client
    * suggested transaction parameters from the algod v2 client
    * I create a new transient account and fund it with 100000000 microalgos.
    * I make a transaction signer for the transient account.

  @ez.disassemble
  Scenario: 
    Given an ez request/response array fixture "disassemble.json" to save in "disassemble"'s context.
    * Unmarshal and save as ordered each "disassemble" object for request and response information.
    Then Sanity check that each "disassemble" request data matches its verb and encoding.
    * Decode each "disassemble" request information as needed in preparation for making requests.
    * Parse and save as ordered each "disassemble" raw response and assert in comparison with the parsed response.
    * Infer each SDK method from "disassemble"'s requests and run it live saving its response.
    Then Assert that each live "disassemble" response is essentially identical to the parsed fixture response.
