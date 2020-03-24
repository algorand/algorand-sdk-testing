Feature: Indexer Client v2

  Scenario Template: LookupAssetBalances json check
    When we make any LookupAssetBalances call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupAssetBalances response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have address "<address>" amount <amount> and frozen state <frozenState>
    Examples:
      |jsonfile                |err|roundNum|len|idx|address|amount|frozenState|
      |getassetholders_case1   |nil|1       |0  |0  |0      |0     |          0|

  Scenario Template: LookupAssetTransactions json check
    When we make any LookupAssetTransactions call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupAssetTransactions response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfile|err|roundNum|len|idx|sender|
      |TODO    |nil|0       |0  |0  |TODO  |

  Scenario Template: LookupAccountTransactions json check
    When we make any LookupAccountTransactions call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupAccountTransactions response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfile|err|roundNum|len|idx|sender|
      |TODO    |nil|0       |0  |0  |TODO  |
    
  Scenario Template: LookupBlock json check
    When we make any LookupBlock call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupBlock response should have proposer "<proposer>"
    Examples:
      |jsonfile|err|proposer|
      |TODO    |nil|TODO    |

  Scenario Template: LookupAccountByID json check
    When we make any LookupAccountByID call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupAccountByID response should have address "<address>"
    Examples:
      |jsonfile|err|address|
      |TODO    |nil|TODO    |

  Scenario Template: LookupAssetByID json check
    When we make any LookupAssetByID call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed LookupAssetByID response should have index <index>
    Examples:
      |jsonfile|err|index  |
      |TODO    |nil|0      |

  Scenario Template: SearchAccounts json check
    When we make any SearchAccounts call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed SearchAccounts response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have address "<address>"
    Examples:
      |jsonfile|err|roundNum  | len | index | address |
      |TODO    |nil|0         |0    |0      |TODO     |

  Scenario Template: SearchForTransactions json check
    When we make any SearchForTransactions call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed SearchForTransactions response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have sender "<sender>"
    Examples:
      |jsonfile|err|roundNum  | len | index | sender  |
      |TODO    |nil|0         |0    |0      |TODO     |

  Scenario Template: SearchForAssets json check
    When we make any SearchForAssets call, return mock response "<jsonfile>" and expect error string to contain "<err>"
    Then the parsed SearchForAssets response should be valid on round <roundNum> and the array should be of len <len> and the element at index <index> should have asset index <assetIndex>
    Examples:
      |jsonfile|err|roundNum  | len | index | assetIndex  |
      |TODO    |nil|0         |0    |0      | 0           |