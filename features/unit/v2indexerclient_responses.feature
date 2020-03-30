Feature: Indexer Client v2

  Scenario Template: LookupAssetBalances response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupAssetBalances call
    Then expect error string to contain "<err>"
    And the parsed LookupAssetBalances response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have address "<address>" amount <amount> and frozen state <frozenState>
    Examples:
      |jsonfile                |directory|err|roundNum|len|idx|address|amount|frozenState|
      |getassetholders_case1   |         |nil|1       |0  |0  |0      |0     |          0|

  Scenario Template: LookupAssetTransactions response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupAssetTransactions call
    Then expect error string to contain "<err>"
    And the parsed LookupAssetTransactions response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|roundNum|len|idx|sender|
      |TODO     |         |nil|0       |0  |0  |TODO  |

  Scenario Template: LookupAccountTransactions response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupAccountTransactions call
    Then expect error string to contain "<err>"
    And the parsed LookupAccountTransactions response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|roundNum|len|idx|sender|
      |TODO     |         |nil|0       |0  |0  |TODO  |
    
  Scenario Template: LookupBlock response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupBlock call
    Then expect error string to contain "<err>"
    And the parsed LookupBlock response should have proposer "<proposer>"
    Examples:
      |jsonfiles|directory|err|proposer|
      |TODO     |         |nil|TODO    |

  Scenario Template: LookupAccountByID response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupAccountByID call
    Then expect error string to contain "<err>"
    And the parsed LookupAccountByID response should have address "<address>"
    Examples:
      |jsonfiles|directory|err|address|
      |TODO     |         |nil|TODO    |

  Scenario Template: LookupAssetByID response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any LookupAssetByID call
    Then expect error string to contain "<err>"
    And the parsed LookupAssetByID response should have index <index>
    Examples:
      |jsonfiles|directory|err|index  |
      |TODO     |         |nil|0      |

  Scenario Template: SearchAccounts response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any SearchAccounts call
    Then expect error string to contain "<err>"
    And the parsed SearchAccounts response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have address "<address>"
    Examples:
      |jsonfiles|directory|err|roundNum  | len | index | address |
      |TODO     |         |nil|0         |0    |0      |TODO     |

  Scenario Template: SearchForTransactions response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any SearchForTransactions call
    Then expect error string to contain "<err>"
    And the parsed SearchForTransactions response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|roundNum  | len | index | sender  |
      |TODO     |         |nil|0         |0    |0      |TODO     |

  Scenario Template: SearchForAssets response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any SearchForAssets call
    Then expect error string to contain "<err>"
    And the parsed SearchForAssets response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have asset index <assetIndex>
    Examples:
      |jsonfiles|directory|err|roundNum  | len | index | assetIndex  |
      |TODO     |         |nil|0         |0    |0      | 0           |