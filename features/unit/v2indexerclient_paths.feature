@indexer
@unit
Feature: Indexer Client v2
  Background:
    Given mock server recording request paths

  Scenario Outline: LookupAssetBalances path
    When we make a Lookup Asset Balances call against asset index <index> with limit <limit> afterAddress "<afterAddress>" round <round> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan>
    Then expect the path used to be "<path>"
    Examples:
      |path                  | index |limit| round | currencyGreaterThan | currencyLessThan| afterAddress |
      |/assets/100/balances  | 100   |  0 | 0   | 0                  | 0              |                   |
      |/assets/100/balances?limit=1 | 100   |  1 | 0   | 0                  | 0              | |
      |/assets/100/balances?round=2 | 100   |  0 | 2   | 0                  | 0              | |
      |/assets/100/balances?currency-greater-than=3 | 100   |  0 | 0   | 3                  | 0              | |
      |/assets/100/balances?currency-less-than=4 | 100   |  0 | 0   | 0                  | 4              | |

  Scenario Outline: LookupAssetTransactions path
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | index | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | address                                                    | addressRole | excludeCloseTo |
      |/assets/0/transactions  | 0     |           |    |     |                                                  | 0    |   0      | 0        | 0     |                     |                     | 0                   | 0                |                                                        |         | false          |
      |/assets/100/transactions  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |      | false           |
      |/assets/100/transactions?address-role=sender  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  | sender     | false           |
      |/assets/100/transactions?after-time=2019-10-13T07:20:50.52Z  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  | 2019-10-13T07:20:50.52Z | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?before-time=2019-10-12T07:20:50.52Z  | 100   |   |    |      |  | 0  |   0     | 0       | 0    | 2019-10-12T07:20:50.52Z |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?currency-greater-than=12  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 12                  | 0         |  |      | false           |
      |/assets/100/transactions?currency-less-than=10000000 | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 10000000         |  |      | false           |
      |/assets/100/transactions?exclude-close-to=true  | 100   |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | true           |
      |/assets/100/transactions?limit=60  | 100   |   |    |      |  | 0  |   0     | 0       | 60    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?max-round=52 | 100   |   |    |      |  | 0  |   0     | 52       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?min-round=51  | 100   |   |    |      |  | 0  |   51     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?note-prefix=6gAVR0Nsv5Y= | 100   | 6gAVR0Nsv5Y=  |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?round=102  | 100   |   |    |      |  | 102  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?sig-type=sig | 100   |   |    | sig     |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?tx-id=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A  | 100   |   |    |      | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |
      |/assets/100/transactions?tx-type=acfg  | 100   |   | acfg   |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      | false           |

  Scenario Outline: LookupAccountTransactions path
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |           |    |     |                                                  | 0    |   0      | 0        | 0     |                     |                     | 0                   | 0                | 0     |         | false          |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?address-role=receiver | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   | receiver     | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?after-time=2019-10-13T07:20:50.52Z  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  | 2019-10-13T07:20:50.52Z | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?asset-id=100 | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 100   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?before-time=2019-10-12T07:20:50.52Z | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    | 2019-10-12T07:20:50.52Z |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-greater-than=12  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 12                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?currency-less-than=10000000   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 10000000         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?exclude-close-to=true | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | true     |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?limit=60  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 0       | 60    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?max-round=52  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   0     | 52       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?min-round=51  | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 0  |   51     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?note-prefix=6gAVR0Nsv5Y=   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | 6gAVR0Nsv5Y=  |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?round=102   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      |  | 102  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?sig-type=sig   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    | sig     |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?tx-id=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |    |      | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?tx-type=acfg   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   | acfg   |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |      | false           |

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
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI          |PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI| 0   |
      |/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI?round=15 |PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI| 15  |

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
      |/accounts?asset-id=23                                                                          | 23    | 0     | 0     | 0                   | 0               |
      |/accounts?currency-greater-than=1000                                                           | 0     | 0     | 0     | 1000                | 0               |
      |/accounts?currency-less-than=100000000                                                         | 0     | 0     | 0     | 0                   | 100000000       |
      |/accounts?limit=50                                                                             | 0     | 0     | 50    | 0                   | 0               |
      |/accounts?round=15                                                                             | 0     | 15    | 0     | 0                   | 0               |

  Scenario Outline: SearchForTransactions path
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path            | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo |
      |/transactions   |                                                            |                |        |         |                                                     | 0    |   0      | 0        | 0     |                          |                        | 0                   | 0                | 0     |             | false          |
      |/transactions?address=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |  |    |      |         | 0    | 0        | 0        | 0     |                         |                         | 0                   | 0                | 0     |             | false          |
      |/transactions?address-role=sender|  |   |    |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   | sender      |  false  |
      |/transactions?after-time=2019-10-13T07:20:50.52Z |  |   |    |      |  | 0  |   0     | 0       | 0    |  | 2019-10-13T07:20:50.52Z | 0                  | 0         | 0   |       | false           |
      |/transactions?asset-id=100 |  |   |    |      |  | 0  |   0     | 0       | 0    |  |   | 0                  | 0         | 100   |       | false           |
      |/transactions?before-time=2019-10-12T07:20:50.52Z |  |   |    |      |  | 0  |   0     | 0       | 0    | 2019-10-12T07:20:50.52Z | | 0                  | 0         | 0   |       | false           |
      |/transactions?currency-greater-than=12 |  |   |    |      |  | 0  |   0     | 0       | 0    | |  | 12                  | 0         | 0   |       | false           |
      |/transactions?currency-less-than=10000000 |  |   |    |      |  | 0  |   0     | 0       | 0    | |  | 0                  | 10000000         | 0   |       | false           |
      |/transactions?exclude-close-to=true  |  |   |    |      |  | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | true           |
      |/transactions?limit=60 |  |   |    |      |  | 0  |   0     | 0       | 60    | |  | 0                  | 0         | 0   |       |    false     |
      |/transactions?max-round=52  |  |   |    |      |  | 0  |   0     | 52       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?min-round=51   |  |   |    |      |  | 0  |   51     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?note-prefix=6gAVR0Nsv5Y= |  | 6gAVR0Nsv5Y=  |    |      |  | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?round=102 |  |   |    |      |  | 102  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?sig-type=sig   |  |   |    | sig     |  | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?tx-type=acfg |  |   | acfg   |      |  | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |
      |/transactions?txid=TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A   |  |   |    |      | TDIO6RJWJIVDDJZELMSX5CPJW7MUNM3QR4YAHYAKHF3W2CFRTI7A | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       | false           |

  Scenario Outline: SearchForAssets path
    When we make a SearchForAssets call with limit <limit> creator "<creator>" name "<name>" unit "<unit>" index <index>
    Then expect the path used to be "<path>"
    Examples:
      |path                                                                                                                         | limit | index | creator                                                    | name      | unit     |
      |/assets                                                                                                                      | 0     | 0     |                                                            |           |          |
      |/assets?asset-id=22                                                                                                          | 0     | 22    |                                                            |           |          |
      |/assets?creator=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI                                                   | 0     | 0     | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |           |          |
      |/assets?limit=30                                                                                                             | 30    | 0     |                                                            |           |          |
      |/assets?name=assetname                                                                                                       | 0     | 0     |                                                            | assetname |          |
      |/assets?unit=unitname                                                                                                        | 0     | 0     |                                                            |           | unitname |
