@unit
@unit.indexer.rekey
Feature: Indexer Client v2 Responses
  Scenario Outline: SearchForAccounts response, authorizing address
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any SearchAccounts call
    Then expect error string to contain "<err>"
    And the parsed SearchAccounts response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have authorizing address "<authaddr>"
    Examples:
      |jsonfiles                |directory                      |err|roundNum  | len | index | authaddr |
      |searchForAccounts_0.json |  v2indexerclient_responsejsons||6222956   |1    |0      |PRIC4GIQTJFD2SZIEQGAYBV2KUJ7YQR3EV3KSOZKLOHPDNRDXXVWMHDAQA|

  Scenario Outline: SearchForTransactions response, rekey-to
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any SearchForTransactions call
    Then expect error string to contain "<err>"
    And the parsed SearchForTransactions response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have rekey-to "<rekeyto>"
    Examples:
      |jsonfiles                    |directory                    |err|roundNum        | len  | index | rekeyto |
      |searchForTransactions_0.json |v2indexerclient_responsejsons||6222958         |10    |1      |PRIC4GIQTJFD2SZIEQGAYBV2KUJ7YQR3EV3KSOZKLOHPDNRDXXVWMHDAQA     |
