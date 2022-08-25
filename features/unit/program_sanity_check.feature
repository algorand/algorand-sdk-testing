@unit.program_sanity_check
Feature: HeursticSanityCheck
  Scenario Outline: Read a slice of bytes and heuristically decide if it look like program bytes
    Given a base64 encoded program bytes for heuristic sanity check "<bytes>"
    When I start heuristic sanity check over the bytes
    Then if the heuristic sanity check throws an error, the error contains "<error>"

    Examples:
      | bytes                                                                            | error                          |
      |                                                                                  | empty program                  |
      | RE43TUJNQ0w1SlEzUEZVUVM3VE1YNUFINEVFS09CSlZEVUY0VENWNldFUkFUS0ZMUUY0TVFVUFpUQQ== | get Algorand address           |
      | U0dPMUdLU3p5RTdJRVBJdFR4Q0J5dzl4OEZtbnJDRGV4aTkvY09VSk9pST0=                     | should not be b64 encoded      |
      | Q2FzdCBhIGNvbGQgZXllCm9uIGxpZmUsIG9uIGRlYXRoLgpIb3JzZW1hbiwgcGFzcyBieQ==         | all ASCII printable characters |
      | ASABASI=                                                                         |                                |
