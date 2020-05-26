@unit
@unit.indexer.rekey
Feature: Indexer Client v2 Paths, Rekey Feature
  Background:
    Given mock server recording request paths

  Scenario Outline: LookupAssetTransactions path for rekey
    When we make a Lookup Asset Transactions call against asset index <index> with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> address "<address>" addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>" RekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
    |path   | index | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | address                                                    | addressRole | excludeCloseTo | rekeyTo |
    |/v2/assets/100/transactions?rekey-to=true  | 100   |   |     |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         |  |      |            |                                                                                                                                                                true       |

  Scenario Outline: LookupAccountTransactions path
    When we make a Lookup Account Transactions call against account "<account>" with NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> rekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | rekeyTo |
      |/v2/accounts/PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI/transactions?rekey-to=true   | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI |   |     |      |  | 0  |   0     | 0       | 0    |  |  | 0                  | 0         | 0   |                                          true|

  Scenario Outline: SearchAccounts path
    When we make a Search Accounts call with assetID <index> limit <limit> currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> round <round> and authenticating address "<authAddr>"
    Then expect the path used to be "<path>"
    Examples:
      |path                                                                                           | index | round | limit | currencyGreaterThan | currencyLessThan| authAddr |
      |/v2/accounts?auth-addr=PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI                 | 0     | 0    | 0     | 0                   | 0               |PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI|

  Scenario Outline: SearchForTransactions path
    When we make a Search For Transactions call with account "<account>" NotePrefix "<notePrefixB64>" TxType "<txType>" SigType "<sigType>" txid "<txid>" round <round> minRound <minRound> maxRound <maxRound> limit <limit> beforeTime "<beforeTime>" afterTime "<afterTime>" currencyGreaterThan <currencyGreaterThan> currencyLessThan <currencyLessThan> assetIndex <index> addressRole "<addressRole>" ExcluseCloseTo "<excludeCloseTo>" rekeyTo "<rekeyTo>"
    Then expect the path used to be "<path>"
    Examples:
      |path            | account                                                    | notePrefixB64 | txType | sigType | txid                                                 | round| minRound | maxRound | limit | beforeTime              | afterTime               | currencyGreaterThan | currencyLessThan | index | addressRole | excludeCloseTo | rekeyTo |
      |/v2/transactions?rekey-to=true   |  |   |    |      |  | 0  |   0     | 0       | 0    | |  | 0                  | 0         | 0   |       |            |                                                                                            true|
