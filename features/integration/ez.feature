Feature: Easy Integration Testing
  Background:
    * an algod v2 client
    * a kmd client
    * wallet information
    * suggested transaction parameters from the algod v2 client
    * I create a new transient account and fund it with 100000000 microalgos.
    * I make a transaction signer for the transient account.

  @ez.disassemble
  Scenario: 
    Given an ez request and response array fixture "disassemble.json" to unmarshal and save in the "disassemble" context.
    # The following step probably cannot be resurrected sensibly. For now, just a console.log()...
    Then Sanity check that each "disassemble" request data matches its verb and encoding.
    # The next step should only be added when the client cannot use the b64 encoded request as is:
    * Base64 decode each "disassemble" query info to prepare for making an http request.
    * Sanity check the "disassemble" response information for b64 encoding, status code, and error state.
    # The next step is the only one that should need customization:
    * Infer each SDK method from the "disassemble" route and call the method live saving its response.
    # Then Assert that each live "disassemble" response is essentially identical to the parsed fixture response.
