Feature: Indexer Client v2
  Background:
    Given mock server recording request paths

  Scenario Outline: LookupAssetBalances path
    When we make a Lookup Asset Balances call against asset index <index> with limit <limit> afterAddress "<afterAddress>" round <round> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan>
    Then expect the path used to be "<path>"
    Examples:
      |path                  | index |limit| round | currencyGreaterThan | currencyLessThan| afterAddress |
      |/assets/100/balances  | 100   |  0 | 0   | 0                  | 0              |                   |
      |/assets/100/balances?limit=1&round=2&currency-greater-than=3&currency-less-than=4  | 100   |  1 | 2   | 3                  | 4              | |

  Scenario Outline: LookupAssetTransactions path
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | index | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | address                                                    | addressRole | excludeCloseTo |
      |/assets/100/transactions?limit=60&note-prefix=6gAVR0Nsv5Y=&tx-type=acfg&sig-type=sig&tx-id=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A&round=102&min-round=51&max-round=52&before-time=2019-10-12T07:20:50.52Z&after_time=2019-10-13T07:20:50.52Z&currency-greater-than=12&currency-less-than=10000000&address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&address-role=manager&exclude-close-to=true   | 100   | 6gAVR0Nsv5Y=  | acfg   | sig     | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 102  |   51     | 52       | 60    | 2019-10-12T07:20:50.52Z | 2019-10-13T07:20:50.52Z | 12                  | 10000000         | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | manager     | true           |
      |/assets/0/transactions  | 0     | none          | none   | none    | none                                                 | 0    |   0      | 0        | 0     | none                    | none                    | 0                   | 0                | none                                                       | none        | false          |
  
  Scenario Outline: LookupAccountTransactions path
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?limit=60&note-prefix=6gAVR0Nsv5Y=&tx-type=acfg&sig-type=sig&tx-id=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A&round=102&min-round=51&max-round=52&before-time=2019-10-12T07:20:50.52Z&after_time=2019-10-13T07:20:50.52Z&currency-greater-than=12&currency-less-than=10000000&asset-id=100&address-role=manager&exclude-close-to=true   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 6gAVR0Nsv5Y=  | acfg   | sig     | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 102  |   51     | 52       | 60    | 2019-10-12T07:20:50.52Z | 2019-10-13T07:20:50.52Z | 12                  | 10000000         | 100   | manager     | true           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | none          | none   | none    | none                                                 | 0    |   0      | 0        | 0     | none                    | none                    | 0                   | 0                | 0     | none        | false          |
  
  Scenario Outline: LookupBlock path
    When we make a Lookup Block call against round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path     |round|
      |/blocks/3|3    |

  Scenario Outline: LookupAccountByID path
    When we make a Lookup Account by ID call against account "<account>" with round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path                                                                          |account                                                   |round|
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI?round=15 |PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI| 15  |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI          |PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI| 0   |

  Scenario Outline: LookupAssetByID path
    When we make a Lookup Asset by ID call against asset index <index>
    Then expect the path used to be "<path>"
    Examples:
      |path      |index|
      |/assets/15|15   |

  Scenario Outline: SearchAccounts path
    When we make a Search Accounts call with assetID <index> limit <limit> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> and round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path                                                                                           | index | round | limit | currencyGreaterThan | currencyLessThan|
      |/accounts                                                                                      | 0     | 0     | 0     | 0                   | 0               |
      |/accounts?asset-id=23&round=15&limit=50&currency-greater-than=1000&currency-less-than=100000000 | 23    | 15    | 50    | 1000                | 100000000       |

  Scenario Outline: SearchForTransactions path
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo |
      |/transactions?limit=60&note-prefix=6gAVR0Nsv5Y=&tx-type=acfg&sig-type=sig&tx-id=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A&round=102&min-round=51&max-round=52&asset-id=100&before-time=2019-10-12T07:20:50.52Z&after_time=2019-10-13T07:20:50.52Z&currency-greater-than=12&currency-less-than=10000000&address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&address-role=sender&exclude-close-to=true   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 6gAVR0Nsv5Y=  | acfg   | sig     | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 102  |   51     | 52       | 60    | 2019-10-12T07:20:50.52Z | 2019-10-13T07:20:50.52Z | 12                  | 10000000         | 100   | sender      | true           |
      |/transactions   | none                                                       | none          | none   | none    | none                                                 | 0    |   0      | 0        | 0     | none                    | none                    | 0                   | 0                | 0     | none        | false          |
  
  Scenario Outline: SearchForAssets path
    When we make a SearchForAssets call with limit <limit> creator "<creator>" name "<name>" unit "<unit>" index <index>
    Then expect the path used to be "<path>"
    Examples:
      |path                                                                                                                         | limit | index | creator                                                    | name      | unit     |
      |/assets?limit=30&asset-id=22&creator=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI&name=assetname&unit=unitname | 30    | 22    | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | assetname | unitname |
      |/assets                                                                                                                      | 0     | 0     | none                                                       | none      | none     |