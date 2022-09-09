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
    * Parse and save as ordered each "disassemble" request's route, path, verb, content-type, optional params and post-data with encoding info.
    Then Sanity check that "disassemble"'s request data matches its verbs.
    * Decode "disassemble"'s data as needed in preparation for making requests.
    * Parse and save as ordered each "disassemble" response body in the given format.
    * Infer each SDK method from "disassemble"'s requests and run it live each saving its response.
    Then Assert that each live "disassemble" response is essentially identical to the parsed fixture response.