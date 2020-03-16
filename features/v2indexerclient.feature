Feature: Indexer Client v2
  Background:
    Given a mocked indexer client

  Scenario Outline: GetAssetHolders json check
    When we make any GetAssetHolders call, return mock response <jsonfile>
    Then the parsed GetAssetHolders response should be valid on round <roundNum>, and contain an array of len <len> and element number <idx> should have frozen state <frozenState>
    Examples:
      |jsonfile                |roundNum|len|idx|frozenState|
      |getassetholders_case1   |1       |0  |0  |0          |
      |getassetholders_case2   |2       |1  |0  |1          |
      |getassetholders_case3   |100     |100|50 |0          |

  Scenario: GetAssetTransactions json check
    When I get the asset transactions for asset id <id> with options <limit> <minRound> <maxRound> <afterTime> <beforeTime> <currencyGreaterThan> <currencyLessThan>
    Then the most recent response should match <jsonfile>
    |id|limit|minRound|maxRound|afterTime|beforeTime|offset|currencyGreaterThan|currencyLessThan|jsonfile|
    |0 |0    |0       |0       |0        |0         |0     |0                  |0               |TODO|

  Scenario: GetTransactionsByAccount json check
    When I get the transactions for account <account> with options <minRound> <maxRound> <beforeTime> <afterTime> <assetid> <offset> <limit> <algosGreaterThan> <algosLessThan>
    Then the most recent response should match <jsonfile>
    |account|minRound|maxRound|beforeTime|afterTime|assetid|offset|limit|algosGreaterThan|algosLessThan|jsonfile|
    |TODO   |0       |0       |0         |0        |0      |0     |0    |0               |0            |TODO    |

  Scenario: GetBlock json check
    When I get the block for round number <round>
    Then the most recent response should match <jsonfile>
    |round|jsonfile|
    |1    |TODO    |

  Scenario: GetAccountInfo json check
    When I get account info for account <account> with option <round>
    Then the most recent response should match <jsonfile>
    |account|round|jsonfile|
    |TODO   |0    |TODO    |

  Scenario: SearchAccounts json check
    When I search accounts with options <assetid> <assetParams> <limit> <algosGreaterThan> <algosLessThan> <addressGreaterThan>
    Then the most recent response should match <jsonfile>

  Scenario: SearchTransactions json check
    When I search transactions with options <notePrefix> <txType> <sigType> <transactionID> <round> <offset> <minRound> <maxRound> <assetID> <format> <limit> <beforeTime> <afterTime> <algosGreaterThan> <algosLessThan>
    Then the most recent response should match <jsonfile>
    |notePrefix|txType|sigType|transactionID|round|offset|minRound|maxRound|assetID|format|limit|beforeTime|afterTime|algosGreaterThan|algosLessThan|jsonfile|
    |TODO      |TODO  |TODO   |TODO         |0    |0     |0       |0       |0      |TODO  |0    |0         |0        |0               |0            |TODO    |

  Scenario: SearchAssets json check
    When I search assets with options <assetGreaterThan> <limit> <creator> <name> <unit> <assetID>
    Then the most recent response should match <jsonfile>
    |assetGreaterThan|limit|creator|name|unit|assetID|jsonfile|
    |0               |0    |TODO   |TODO|TODO|0      |TODO    |