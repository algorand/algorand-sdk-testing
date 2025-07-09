@unit
Feature: Indexer Client v2 Paths
  Background:
    Given mock server recording request paths

  @unit.indexer
  Scenario Outline: LookupAssetBalances path
    When we make a Lookup Asset Balances call against asset index <index> with limit <limit> afterAddress "<afterAddress>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan>
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                            | index | limit | currencyGreaterThan | currencyLessThan | afterAddress |
      | /v2/assets/100/balances?currency-greater-than=0                                 | 100   | 0     | 0                   | 0                |              |
      | /v2/assets/100/balances?currency-greater-than=0&limit=1                         | 100   | 1     | 0                   | 0                |              |
      | /v2/assets/100/balances?currency-greater-than=3                                 | 100   | 0     | 3                   | 0                |              |
      | /v2/assets/100/balances?currency-greater-than=0&currency-less-than=4            | 100   | 0     | 0                   | 4                |              |

  @unit.indexer
  Scenario Outline: LookupAssetTransactions path
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                                   | index | notePrefixB64 | txType | sigType | txid                                                 | round | minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | address                                                    | addressRole | excludeCloseTo |
      | /v2/assets/0/transactions?currency-greater-than=0                                                                      | 0     |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0                                                                    | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&currency-greater-than=0 | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |             |                |
      | /v2/assets/100/transactions?address-role=sender&currency-greater-than=0                                                | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            | sender      |                |
      | /v2/assets/100/transactions?after-time=2019-10-13T07%3A20%3A50.52Z&currency-greater-than=0                             | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         | 2019-10-13T07:20:50.52Z | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?before-time=2019-10-12T07%3A20%3A50.52Z&currency-greater-than=0                            | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     | 2019-10-12T07:20:50.52Z |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=12                                                                   | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 12                  | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&currency-less-than=10000000                                        | 100   |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 10000000         |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&limit=60                                                           | 100   |               |        |         |                                                      | 0     | 0        | 0        | 60    |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&max-round=52                                                       | 100   |               |        |         |                                                      | 0     | 0        | 52       | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&min-round=51                                                       | 100   |               |        |         |                                                      | 0     | 51       | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&note-prefix=6gAVR0Nsv5Y%3D                                         | 100   | 6gAVR0Nsv5Y=  |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&round=102                                                          | 100   |               |        |         |                                                      | 102   | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&sig-type=sig                                                       | 100   |               |        | sig     |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&txid=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A          | 100   |               |        |         | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |
      | /v2/assets/100/transactions?currency-greater-than=0&tx-type=acfg                                                       | 100   |               | acfg   |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                |                                                            |             |                |

  @unit.indexer
  Scenario Outline: LookupAccountTransactions path
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index>
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                                                                                    | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round | minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0                                                           | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?after-time=2019-10-13T07%3A20%3A50.52Z&currency-greater-than=0                    | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         | 2019-10-13T07:20:50.52Z | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?asset-id=100&currency-greater-than=0                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 100   |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?before-time=2019-10-12T07%3A20%3A50.52Z&currency-greater-than=0                   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     | 2019-10-12T07:20:50.52Z |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=12                                                           | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 12                  | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&currency-less-than=10000000                               | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 10000000         | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&limit=60                                                  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 60    |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&max-round=52                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 52       | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&min-round=51                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 51       | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&note-prefix=6gAVR0Nsv5Y%3D                                | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 6gAVR0Nsv5Y=  |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&round=102                                                 | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 102   | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&sig-type=sig                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        | sig     |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&txid=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&tx-type=acfg                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               | acfg   |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |

  @unit.indexer
  Scenario Outline: LookupBlock path
    When we make a Lookup Block call against round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path         | round |
      | /v2/blocks/3 | 3     |

  @unit.indexer
  Scenario Outline: LookupAccountByID path
    When we make a Lookup Account by ID call against account "<account>" with round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                             | account                                                    | round |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI          | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 0     |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI?round=15 | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 15    |

  @unit.indexer
  Scenario Outline: LookupAssetByID path
    When we make a Lookup Asset by ID call against asset index <index>
    Then expect the path used to be "<path>"
    Examples:
      | path          | index |
      | /v2/assets/15 | 15    |

  @unit.indexer
  Scenario Outline: SearchAccounts path
    When we make a Search Accounts call with assetID <index> limit <limit> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> and round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                                                              | index | round | limit | currencyGreaterThan | currencyLessThan |
      | /v2/accounts?currency-greater-than=0                              | 0     | 0     | 0     | 0                   | 0                |
      | /v2/accounts?asset-id=23&currency-greater-than=0                  | 23    | 0     | 0     | 0                   | 0                |
      | /v2/accounts?currency-greater-than=1000                           | 0     | 0     | 0     | 1000                | 0                |
      | /v2/accounts?currency-greater-than=0&currency-less-than=100000000 | 0     | 0     | 0     | 0                   | 100000000        |
      | /v2/accounts?currency-greater-than=0&limit=50                     | 0     | 0     | 50    | 0                   | 0                |
      | /v2/accounts?currency-greater-than=0&round=15                     | 0     | 15    | 0     | 0                   | 0                |

  @unit.indexer
  Scenario Outline: SearchAccounts path with OnlineOnly
    When we make a Search Accounts call with onlineOnly "<onlineOnly>"
    Then expect the path used to be "<path>"
    Examples:
      | path                           | onlineOnly |
      | /v2/accounts?online-only=true  | true       |
      | /v2/accounts                   | false      |

  @unit.indexer
  Scenario Outline: SearchForTransactions path
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>" groupid "<groupid>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                        | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round | minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo | groupid                                      | 
      | /v2/transactions?currency-greater-than=0                                                                    |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&currency-greater-than=0 | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?address-role=sender&currency-greater-than=0                                                |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     | sender      |                |                                              |
      | /v2/transactions?after-time=2019-10-13T07%3A20%3A50.52Z&currency-greater-than=0                             |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         | 2019-10-13T07:20:50.52Z | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?asset-id=100&currency-greater-than=0                                                       |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 100   |             |                |                                              |
      | /v2/transactions?before-time=2019-10-12T07%3A20%3A50.52Z&currency-greater-than=0                            |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     | 2019-10-12T07:20:50.52Z |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=12                                                                   |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 12                  | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&currency-less-than=10000000                                        |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 10000000         | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&exclude-close-to=true                                              |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             | true           |                                              |
      | /v2/transactions?currency-greater-than=0&limit=60                                                           |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 60    |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&max-round=52                                                       |                                                            |               |        |         |                                                      | 0     | 0        | 52       | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&min-round=51                                                       |                                                            |               |        |         |                                                      | 0     | 51       | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&note-prefix=6gAVR0Nsv5Y%3D                                         |                                                            | 6gAVR0Nsv5Y=  |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&round=102                                                          |                                                            |               |        |         |                                                      | 102   | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&sig-type=sig                                                       |                                                            |               |        | sig     |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&tx-type=acfg                                                       |                                                            |               | acfg   |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&txid=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A          |                                                            |               |        |         | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                |                                              |
      | /v2/transactions?currency-greater-than=0&group-id=A62qVigWtWo0laUzcE1iZY8%2BKXWzK1vSkgwN%2FeKgvjc%3D        |                                                            |               |        |         |                                                      | 0     | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             |                | A62qVigWtWo0laUzcE1iZY8+KXWzK1vSkgwN/eKgvjc= |

  @unit.indexer.blockheaders
  Scenario Outline: SearchForBlockHeaders path
    When we make a Search For BlockHeaders call with minRound <minRound> maxRound <maxRound> limit <limit> nextToken "<nextToken>" beforeTime "<beforeTime>" afterTime "<afterTime>" proposers "<proposers>" expired "<expired>" absent "<absent>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                        | minRound | maxRound | limit | nextToken        | beforeTime              | afterTime               | proposers                                                                                                      | expired                                                                                                        | absent                                                                                                         |
      | /v2/block-headers?min-round=51                                                                   | 51      | 0        | 0     |                  |                         |                         |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?max-round=55&min-round=51                                                      | 51      | 55       | 0     |                  |                         |                         |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?limit=10&min-round=51                                                          | 51      | 0        | 10    |                  |                         |                         |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?min-round=51&next=token                                                        | 51      | 0        | 0     | token            |                         |                         |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?before-time=2019-10-12T07%3A20%3A50.52Z&min-round=51                           | 51      | 0        | 0     |                  | 2019-10-12T07:20:50.52Z |                         |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?after-time=2019-10-13T07%3A20%3A50.52Z&min-round=51                            | 51      | 0        | 0     |                  |                         | 2019-10-13T07:20:50.52Z |                                                                                                        |                                                                                                        |                                                                                                        |
      | /v2/block-headers?proposers=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI%2C7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 0        | 0        | 0     |                  |                         |                               | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI,7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q |                                                                                                        |                                                                                                        |
      | /v2/block-headers?expired=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI%2C7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 0        | 0        | 0     |                  |                         |                               |                                                                                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI,7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q      |                                                                                                        |
      | /v2/block-headers?absent=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI%2C7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 0        | 0        | 0     |                  |                         |                               |                                                                                                        |                                                                                                              | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI,7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q |

  @unit.indexer
  Scenario Outline: SearchForAssets path
    When we make a SearchForAssets call with limit <limit> creator "<creator>" name "<name>" unit "<unit>" index <index>
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                          | limit | index | creator                                                    | name      | unit     |
      | /v2/assets                                                                    | 0     | 0     |                                                            |           |          |
      | /v2/assets?asset-id=22                                                        | 0     | 22    |                                                            |           |          |
      | /v2/assets?creator=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 0     | 0     | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |           |          |
      | /v2/assets?limit=30                                                           | 30    | 0     |                                                            |           |          |
      | /v2/assets?name=assetname                                                     | 0     | 0     |                                                            | assetname |          |
      | /v2/assets?unit=unitname                                                      | 0     | 0     |                                                            |           | unitname |

  @unit.indexer.rekey
  Scenario Outline: LookupAssetTransactions path for rekey
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>" RekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                      | index | notePrefixB64 | txType | sigType | txid | round | minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | address | addressRole | excludeCloseTo | rekeyTo |
      | /v2/assets/100/transactions?currency-greater-than=0&rekey-to=true         | 100   |               |        |         |      | 0     | 0        | 0        | 0     |            |           | 0                   | 0                |         |             |                | true    |

  @unit.indexer.rekey
  Scenario Outline: LookupAccountTransactions path for rekey
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> rekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                                       | account                                                    | notePrefixB64 | txType | sigType | txid | round | minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | index | rekeyTo |
      | /v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=0&rekey-to=true | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |               |        |         |      | 0     | 0        | 0        | 0     |            |           | 0                   | 0                | 0     | true    |

  @unit.indexer.rekey
  Scenario Outline: SearchAccounts path for rekey
    When we make a Search Accounts call with assetID <index> limit <limit> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> round <round> and authenticating address "<authAddr>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                      | index | round | limit | currencyGreaterThan | currencyLessThan | authAddr                                                   |
      | /v2/accounts?auth-addr=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&currency-greater-than=0 | 0     | 0     | 0     | 0                   | 0                | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |

  @unit.indexer.rekey
  Scenario Outline: SearchForTransactions path for rekey
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>" groupid "<groupid>" rekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                   | account | notePrefixB64 | txType | sigType | txid | round | minRound | maxRound | limit | beforeTime | afterTime | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo | groupid | rekeyTo |
      | /v2/transactions?currency-greater-than=0&rekey-to=true |         |               |        |         |      | 0     | 0        | 0        | 0     |            |           | 0                   | 0                | 0     |             |                |         | true    |

  @unit.applications
  Scenario Outline: SearchForApplications path
    When we make a SearchForApplications call with applicationID <application-id>
    Then expect the path used to be "<path>"

    Examples:
      | path                                 | application-id |
      | /v2/applications?application-id=1234 | 1234           |

  @unit.applications
  Scenario Outline: LookupApplications path
    When we make a LookupApplications call with applicationID <application-id>
    Then expect the path used to be "<path>"

    Examples:
      | path                  | application-id |
      | /v2/applications/1234 | 1234           |

  @unit.applications.boxes
  Scenario Outline: LookupApplicationBoxByIDandName path
    When we make a LookupApplicationBoxByIDandName call with applicationID <application-id> with encoded box name "<encoded-box-name>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                | application-id | encoded-box-name     |
      | /v2/applications/1234/box?name=b64%3AaGVsbG8%3D     | 1234           | b64:aGVsbG8=         |
      | /v2/applications/1234/box?name=b64%3A%2Fw%3D%3D     | 1234           | b64:/w==             |
      | /v2/applications/1234/box?name=b64%3A8J%2BSqQ%3D%3D | 1234           | b64:8J+SqQ==         |
      | /v2/applications/1234/box?name=b64%3AYS96           | 1234           | b64:YS96             |

  @unit.applications.boxes
  Scenario Outline: SearchForApplicationBoxes path
    When we make a SearchForApplicationBoxes call with applicationID <application-id> with max <max> nextToken "<nextToken>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                            | application-id | max | nextToken        |
      | /v2/applications/1234/boxes                                     | 1234           | 0   |                  |
      | /v2/applications/1234/boxes?limit=2                             | 1234           | 2   |                  |
      | /v2/applications/1234/boxes?limit=2&next=token                  | 1234           | 2   | token            |
      | /v2/applications/1234/boxes?limit=2&next=b64%3AdG9rZW4%3D       | 1234           | 2   | b64:dG9rZW4=     |
      | /v2/applications/1234/boxes?limit=2&next=b64%3AZ29vZEJveA%3D%3D | 1234           | 2   | b64:Z29vZEJveA== |

  @unit.indexer.logs
  Scenario Outline: LookupApplicationLogsByID path
    When we make a LookupApplicationLogsByID call with applicationID <application-id> limit <limit> minRound <minRound> maxRound <maxRound> nextToken "<nextToken>" sender "<senderAddr>" and txID "<txid>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                                                                                                                                                                          | application-id | limit | minRound | maxRound | nextToken | senderAddr                                                 | txid                                                 |
      | /v2/applications/1234/logs                                                                                                                                                                                    | 1234           | 0     | 0        | 0        |           |                                                            |                                                      |
      | /v2/applications/1234/logs?limit=4&max-round=120&min-round=100&next=TOKEN&sender-address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&txid=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 1234           | 4     | 100      | 120      | TOKEN     | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A |

  @unit.indexer.ledger_refactoring
  Scenario Outline: LookupAccountAssets path
    When we make a LookupAccountAssets call with accountID "<account-id>" assetID <asset-id> includeAll "<include-all>" limit <limit> next "<next>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                                     | account-id | asset-id | include-all | limit | next |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets                                                  | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets?asset-id=123                                     | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123      | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets?include-all=true                                 | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | true        | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets?limit=123                                        | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 123   |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets?next=def                                         | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 0     | def  |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/assets?asset-id=123&include-all=true&limit=456&next=def | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123      | true        | 456   | def  |

  @unit.indexer.ledger_refactoring
  Scenario Outline: LookupAccountCreatedAssets path
    When we make a LookupAccountCreatedAssets call with accountID "<account-id>" assetID <asset-id> includeAll "<include-all>" limit <limit> next "<next>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                                             | account-id | asset-id | include-all | limit | next |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets                                                  | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets?asset-id=123                                     | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123      | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets?include-all=true                                 | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | true        | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets?limit=123                                        | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 123   |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets?next=def                                         | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0        | false       | 0     | def  |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-assets?asset-id=123&include-all=true&limit=456&next=def | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123      | true        | 456   | def  |

  @unit.indexer.ledger_refactoring
  Scenario Outline: LookupAccountAppLocalStates path
    When we make a LookupAccountAppLocalStates call with accountID "<account-id>" applicationID <application-id> includeAll "<include-all>" limit <limit> next "<next>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                                                     | account-id | application-id | include-all | limit | next |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state                                                        | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state?application-id=123                                     | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123            | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state?include-all=true                                       | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | true        | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state?limit=123                                              | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 123   |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state?next=def                                               | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 0     | def  |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/apps-local-state?application-id=123&include-all=true&limit=456&next=def | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123            | true        | 456   | def  |

  @unit.indexer.ledger_refactoring
  Scenario Outline: LookupAccountCreatedApplications path
    When we make a LookupAccountCreatedApplications call with accountID "<account-id>" applicationID <application-id> includeAll "<include-all>" limit <limit> next "<next>"
    Then expect the path used to be "<path>"

    Examples:
      | path                                                                                         | account-id | application-id | include-all | limit | next |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications                                                        | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications?application-id=123                                     | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123            | false       | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications?include-all=true                                       | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | true        | 0     |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications?limit=123                                              | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 123   |      |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications?next=def                                               | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 0              | false       | 0     | def  |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/created-applications?application-id=123&include-all=true&limit=456&next=def | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q        | 123            | true        | 456   | def  |

  @unit.indexer.ledger_refactoring
  Scenario Outline: SearchAccounts path
    When we make a Search Accounts call with exclude "<exclude>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                           | exclude                                             |
      | /v2/accounts?exclude=assets                                                    | assets                                              |
      | /v2/accounts?exclude=assets%2Ccreated-assets                                   | assets,created-assets                               |
      | /v2/accounts?exclude=assets%2Ccreated-assets%2Capps-local-state%2Ccreated-apps | assets,created-assets,apps-local-state,created-apps |

  @unit.indexer.ledger_refactoring
  Scenario Outline: LookupAccountByID path
    When we make a Lookup Account by ID call against account "<account>" with exclude "<exclude>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                               | account | exclude                                             |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q?exclude=assets                                                    | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q     | assets                                              |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q?exclude=assets%2Ccreated-assets                                   | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q     | assets,created-assets                               |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q?exclude=assets%2Ccreated-assets%2Capps-local-state%2Ccreated-apps | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q     | assets,created-assets,apps-local-state,created-apps |

  @unit.indexer.ledger_refactoring
  Scenario Outline: SearchForApplications path
    When we make a SearchForApplications call with creator "<creator>"
    Then expect the path used to be "<path>"

    Examples:
      | path                         | creator |
      | /v2/applications?creator=7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q     |

  @unit.blocksummary
  Scenario Outline: LookupBlock path 2
    When we make a Lookup Block call against round <round> and header "<header>"
    Then expect the path used to be "<path>"
    Examples:
      | path                           | round | header |
      | /v2/blocks/3                   | 3     |        |
      | /v2/blocks/3?header-only=true  | 3     | true   |
