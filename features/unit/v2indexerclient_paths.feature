Feature: Indexer Client v2
  Background:
    Given mock server recording request paths

  Scenario Outline: LookupAssetBalances path
    When we make a Lookup Asset Balances call against asset index <index> with limit <limit> nextToken "<nextToken>" round <round> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan>
    Then expect the path used to be "<path>"
    Examples:
      |path   | index |limit| nextToken   | round | currencyGreaterThan | currencyLessThan|
      |TODO   | 0     |  0  | TODO        | 0     | 0                   | 0               |

  Scenario Outline: LookupAssetTransactions path
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txidB64>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime <beforeTime> afterTime <afterTime> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | index | notePrefixB64 | txType | sigType | txidB64 | round| minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | address | addressRole | excludeCloseTo |
      |TODO   | 0     | TODO          | TODO   | TODO    | TODO    | 0    |   0      | 0        |   0   |    0       |   0       | 0                   | 0                | TODO    |   TODO      |    false       |

  Scenario Outline: LookupAccountTransactions path
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txidB64>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime <beforeTime> afterTime <afterTime> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account | notePrefixB64 | txType | sigType | txidB64 | round| minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | index   | addressRole | excludeCloseTo |
      |TODO   | TODO    | TODO          | TODO   | TODO    | TODO    | 0    |   0      | 0        |   0   |    0       |   0       | 0                   | 0                | 0       |   TODO      |    false       |

  Scenario Outline: LookupBlock path
    When we make a Lookup Block call against round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path|round|
      |TODO|0    |

  Scenario Outline: LookupAccountByID path
    When we make a Lookup Account by ID call against account "<account>" with round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path|account|round|
      |TODO|TODO   |0    |

  Scenario Outline: LookupAssetByID path
    When we make a Lookup Asset by ID call against asset index <index>
    Then expect the path used to be "<path>"
    Examples:
      |path|index|
      |TODO|0    |

  Scenario Outline: SearchAccounts path
    When we make a Search Accounts call with assetID <index> limit <limit> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> and nextToken "<nextToken>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | index | nextToken| limit | currencyGreaterThan | currencyLessThan|
      |TODO   | 0     | TODO        | 0     | 0                   | 0               |

  Scenario Outline: SearchForTransactions path
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txidB64>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime <beforeTime> afterTime <afterTime> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account | notePrefixB64 | txType | sigType | txidB64 | round| minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | index   | addressRole | excludeCloseTo |
      |TODO   | TODO    | TODO          | TODO   | TODO    | TODO    | 0    |   0      | 0        |   0   |    0       |   0       | 0                   | 0                | 0       |   TODO      |    false       |


  Scenario Outline: SearchForAssets path
    When we make a SearchForAssets call with limit <limit> creator "<creator>" name "<name>" unit "<unit>" index <index> and nextToken "<nextToken>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | limit | index | nextToken| creator | name | unit|
      |TODO   | 0     | 0     | 0         | TODO    | TODO | 0   |