@unit
Feature: REST Client Responses

  Scenario Outline: <client>: <endpoint> - <jsonfile>
    Given mock http responses in "<jsonfile>" loaded from "<response-folder>" with status <status>.
    When we make any "<client>" call to "<endpoint>".
    Then the parsed response should equal the mock response.
    @unit.responses
    Examples:
      | jsonfile                                                | response-folder     | status | client  | endpoint                  |
      | indexer_applications_AccountResponse_0.json             | generated_responses | 200    | indexer | lookupAccountByID         |
      | indexer_applications_AccountsResponse_0.json            | generated_responses | 200    | indexer | searchForAccounts         |
      | indexer_applications_ApplicationResponse_0.json         | generated_responses | 200    | indexer | lookupApplicationByID     |
      | indexer_applications_ApplicationsResponse_0.json        | generated_responses | 200    | indexer | searchForApplications     |
      | indexer_applications_AssetBalancesResponse_0.json       | generated_responses | 200    | indexer | lookupAssetBalances       |
      | indexer_applications_AssetResponse_0.json               | generated_responses | 200    | indexer | lookupAssetByID           |
      | indexer_applications_AssetsResponse_0.json              | generated_responses | 200    | indexer | searchForAssets           |
      | indexer_applications_TransactionsResponse_0.json        | generated_responses | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_0.json        | generated_responses | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_0.json        | generated_responses | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_1.json        | generated_responses | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_1.json        | generated_responses | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_1.json        | generated_responses | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_2.json        | generated_responses | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_2.json        | generated_responses | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_2.json        | generated_responses | 200    | indexer | searchForTransactions     |
      | indexer_applications_ErrorResponse_0.json               | generated_responses | 500    | indexer | any                       |
      | algod_applications_NodeStatusResponse_0.json            | generated_responses | 200    | algod   | GetStatus                 |
      | algod_applications_NodeStatusResponse_0.json            | generated_responses | 200    | algod   | WaitForBlock              |
      | algod_applications_CompileResponse_0.json               | generated_responses | 200    | algod   | TealCompile               |
      | algod_applications_PostTransactionsResponse_0.json      | generated_responses | 200    | algod   | RawTransaction            |
      | algod_applications_SupplyResponse_0.json                | generated_responses | 200    | algod   | GetSupply                 |
      | algod_applications_TransactionParametersResponse_0.json | generated_responses | 200    | algod   | TransactionParams         |
      | algod_applications_ApplicationResponse_0.json           | generated_responses | 200    | algod   | GetApplicationByID        |
      | algod_applications_AssetResponse_0.json                 | generated_responses | 200    | algod   | GetAssetByID              |
      | algod_applications_ErrorResponse_0.json                 | generated_responses | 500    | algod   | any                       |

    @unit.responses.231
    Examples:
      | jsonfile                                          | response-folder         | status | client  | endpoint                  |
      | indexer_applications_AccountResponse_0.json       | generated_responses_231 | 200    | indexer | lookupAccountByID         |
      | indexer_applications_AccountsResponse_0.json      | generated_responses_231 | 200    | indexer | searchForAccounts         |
      | indexer_applications_ApplicationResponse_0.json   | generated_responses_231 | 200    | indexer | lookupApplicationByID     |
      | indexer_applications_ApplicationsResponse_0.json  | generated_responses_231 | 200    | indexer | searchForApplications     |
      | indexer_applications_AssetBalancesResponse_0.json | generated_responses_231 | 200    | indexer | lookupAssetBalances       |
      | indexer_applications_AssetResponse_0.json         | generated_responses_231 | 200    | indexer | lookupAssetByID           |
      | indexer_applications_AssetsResponse_0.json        | generated_responses_231 | 200    | indexer | searchForAssets           |
      | indexer_applications_TransactionsResponse_0.json  | generated_responses_231 | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_0.json  | generated_responses_231 | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_0.json  | generated_responses_231 | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_1.json  | generated_responses_231 | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_1.json  | generated_responses_231 | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_1.json  | generated_responses_231 | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_2.json  | generated_responses_231 | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_2.json  | generated_responses_231 | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_2.json  | generated_responses_231 | 200    | indexer | searchForTransactions     |
      | algod_NodeStatusResponse_0.json                   | generated_responses_231 | 200    | algod   | GetStatus                 |
      | algod_NodeStatusResponse_0.json                   | generated_responses_231 | 200    | algod   | WaitForBlock              |
      | algod_CompileResponse_0.json                      | generated_responses_231 | 200    | algod   | TealCompile               |
      | algod_DryrunResponse_0.json                       | generated_responses_231 | 200    | algod   | DryRun                    |
      | algod_PostTransactionsResponse_0.json             | generated_responses_231 | 200    | algod   | RawTransaction            |
      | algod_ProofResponse_0.json                        | generated_responses_231 | 200    | algod   | Proof                     |
      | algod_SupplyResponse_0.json                       | generated_responses_231 | 200    | algod   | GetSupply                 |
      | algod_TransactionParametersResponse_0.json        | generated_responses_231 | 200    | algod   | TransactionParams         |

    @unit.responses.unlimited_assets
    Examples:
      | jsonfile                                                   | response-folder                      | status | client  | endpoint                         |
      | indexer_unlimited_aa_AccountResponse_0.json                | generated_responses_unlimited_assets | 200    | indexer | lookupAccountByID                |
      | indexer_unlimited_aa_AccountsResponse_0.json               | generated_responses_unlimited_assets | 200    | indexer | searchForAccounts                |
      | indexer_unlimited_aa_ApplicationLocalStatesResponse_0.json | generated_responses_unlimited_assets | 200    | indexer | lookupAccountAppLocalStates      |
      | indexer_unlimited_aa_ApplicationLogsResponse_0.json        | generated_responses_unlimited_assets | 200    | indexer | lookupApplicationLogsByID        |
      | indexer_unlimited_aa_ApplicationResponse_0.json            | generated_responses_unlimited_assets | 200    | indexer | lookupApplicationByID            |
      | indexer_unlimited_aa_ApplicationsResponse_0.json           | generated_responses_unlimited_assets | 200    | indexer | searchForApplications            |
      | indexer_unlimited_aa_ApplicationsResponse_0.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAccountCreatedApplications |
      | indexer_unlimited_aa_ApplicationsResponse_1.json           | generated_responses_unlimited_assets | 200    | indexer | searchForApplications            |
      | indexer_unlimited_aa_ApplicationsResponse_1.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAccountCreatedApplications |
      | indexer_unlimited_aa_AssetBalancesResponse_0.json          | generated_responses_unlimited_assets | 200    | indexer | lookupAssetBalances              |
      | indexer_unlimited_aa_AssetHoldingsResponse_0.json          | generated_responses_unlimited_assets | 200    | indexer | lookupAccountAssets              |
      | indexer_unlimited_aa_AssetResponse_0.json                  | generated_responses_unlimited_assets | 200    | indexer | lookupAssetByID                  |
      | indexer_unlimited_aa_AssetsResponse_0.json                 | generated_responses_unlimited_assets | 200    | indexer | searchForAssets                  |
      | indexer_unlimited_aa_AssetsResponse_0.json                 | generated_responses_unlimited_assets | 200    | indexer | lookupAccountCreatedAssets       |
      | indexer_unlimited_aa_AssetsResponse_1.json                 | generated_responses_unlimited_assets | 200    | indexer | searchForAssets                  |
      | indexer_unlimited_aa_AssetsResponse_1.json                 | generated_responses_unlimited_assets | 200    | indexer | lookupAccountCreatedAssets       |
      | indexer_unlimited_aa_TransactionResponse_0.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_1.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_2.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_3.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_4.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_5.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_6.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_7.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_8.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_9.json            | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_10.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_11.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_12.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_13.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_14.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_15.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_16.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionResponse_17.json           | generated_responses_unlimited_assets | 200    | indexer | lookupTransaction                |
      | indexer_unlimited_aa_TransactionsResponse_0.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAccountTransactions        |
      | indexer_unlimited_aa_TransactionsResponse_0.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAssetTransactions          |
      | indexer_unlimited_aa_TransactionsResponse_0.json           | generated_responses_unlimited_assets | 200    | indexer | searchForTransactions            |
      | indexer_unlimited_aa_TransactionsResponse_1.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAccountTransactions        |
      | indexer_unlimited_aa_TransactionsResponse_1.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAssetTransactions          |
      | indexer_unlimited_aa_TransactionsResponse_1.json           | generated_responses_unlimited_assets | 200    | indexer | searchForTransactions            |
      | indexer_unlimited_aa_TransactionsResponse_2.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAccountTransactions        |
      | indexer_unlimited_aa_TransactionsResponse_2.json           | generated_responses_unlimited_assets | 200    | indexer | lookupAssetTransactions          |
      | indexer_unlimited_aa_TransactionsResponse_2.json           | generated_responses_unlimited_assets | 200    | indexer | searchForTransactions            |
      | indexer_unlimited_aa_ErrorResponse_0.json                  | generated_responses_unlimited_assets | 500    | indexer | any                              |
      | indexer_unlimited_aa_ErrorResponse_1.json                  | generated_responses_unlimited_assets | 500    | indexer | any                              |
      | algod_unlimited_aa_Account_0.json                          | generated_responses_unlimited_assets | 200    | algod   | AccountInformation               |
      | algod_unlimited_aa_Account_2.json                          | generated_responses_unlimited_assets | 200    | algod   | AccountInformation               |
      | algod_unlimited_aa_AccountApplicationResponse_0.json       | generated_responses_unlimited_assets | 200    | algod   | AccountApplicationInformation    |
      | algod_unlimited_aa_AccountApplicationResponse_2.json       | generated_responses_unlimited_assets | 200    | algod   | AccountApplicationInformation    |
      | algod_unlimited_aa_AccountAssetResponse_0.json             | generated_responses_unlimited_assets | 200    | algod   | AccountAssetInformation          |
      | algod_unlimited_aa_AccountAssetResponse_2.json             | generated_responses_unlimited_assets | 200    | algod   | AccountAssetInformation          |
      | algod_unlimited_aa_Application_0.json                      | generated_responses_unlimited_assets | 200    | algod   | GetApplicationByID               |
      | algod_unlimited_aa_Application_1.json                      | generated_responses_unlimited_assets | 200    | algod   | GetApplicationByID               |
      | algod_unlimited_aa_Asset_0.json                            | generated_responses_unlimited_assets | 200    | algod   | GetAssetByID                     |
      | algod_unlimited_aa_Asset_1.json                            | generated_responses_unlimited_assets | 200    | algod   | GetAssetByID                     |
      | algod_unlimited_aa_CompileResponse_0.json                  | generated_responses_unlimited_assets | 200    | algod   | TealCompile                      |
      | algod_unlimited_aa_CompileResponse_1.json                  | generated_responses_unlimited_assets | 200    | algod   | TealCompile                      |
      | algod_unlimited_aa_NodeStatusResponse_0.json               | generated_responses_unlimited_assets | 200    | algod   | GetStatus                        |
      | algod_unlimited_aa_NodeStatusResponse_0.json               | generated_responses_unlimited_assets | 200    | algod   | WaitForBlock                     |
      | algod_unlimited_aa_NodeStatusResponse_1.json               | generated_responses_unlimited_assets | 200    | algod   | GetStatus                        |
      | algod_unlimited_aa_NodeStatusResponse_1.json               | generated_responses_unlimited_assets | 200    | algod   | WaitForBlock                     |
      | algod_unlimited_aa_NodeStatusResponse_2.json               | generated_responses_unlimited_assets | 200    | algod   | GetStatus                        |
      | algod_unlimited_aa_NodeStatusResponse_2.json               | generated_responses_unlimited_assets | 200    | algod   | WaitForBlock                     |
      | algod_unlimited_aa_NodeStatusResponse_3.json               | generated_responses_unlimited_assets | 200    | algod   | GetStatus                        |
      | algod_unlimited_aa_NodeStatusResponse_3.json               | generated_responses_unlimited_assets | 200    | algod   | WaitForBlock                     |
      | algod_unlimited_aa_PostTransactionsResponse_0.json         | generated_responses_unlimited_assets | 200    | algod   | RawTransaction                   |
      | algod_unlimited_aa_PostTransactionsResponse_1.json         | generated_responses_unlimited_assets | 200    | algod   | RawTransaction                   |
      | algod_unlimited_aa_SupplyResponse_0.json                   | generated_responses_unlimited_assets | 200    | algod   | GetSupply                        |
      | algod_unlimited_aa_SupplyResponse_1.json                   | generated_responses_unlimited_assets | 200    | algod   | GetSupply                        |
      | algod_unlimited_aa_TransactionParametersResponse_0.json    | generated_responses_unlimited_assets | 200    | algod   | TransactionParams                |
      | algod_unlimited_aa_TransactionParametersResponse_1.json    | generated_responses_unlimited_assets | 200    | algod   | TransactionParams                |
      | algod_unlimited_aa_ErrorResponse_0.json                    | generated_responses_unlimited_assets | 500    | algod   | any                              |
      | algod_unlimited_aa_ErrorResponse_1.json                    | generated_responses_unlimited_assets | 500    | algod   | any                              |
      | algod_unlimited_aa_ErrorResponse_2.json                    | generated_responses_unlimited_assets | 500    | algod   | any                              |

    @unit.responses.genesis
    Examples:
      | jsonfile                        | response-folder         | status | client | endpoint   |
      | algod_GetGenesisResponse_0.json | generated_responses_231 | 200    | algod  | GetGenesis |

    @unit.responses.messagepack
    Examples:
      | jsonfile                                                | response-folder     | status | client | endpoint                        |
      | algod_applications_PendingTransactionResponse_0.base64  | generated_responses | 200    | algod  | PendingTransactionInformation   |
      | algod_applications_PendingTransactionResponse_1.base64  | generated_responses | 200    | algod  | PendingTransactionInformation   |
      | algod_applications_PendingTransactionsResponse_0.base64 | generated_responses | 200    | algod  | GetPendingTransactions          |
      | algod_applications_PendingTransactionsResponse_1.base64 | generated_responses | 200    | algod  | GetPendingTransactions          |
      | algod_applications_PendingTransactionsResponse_0.base64 | generated_responses | 200    | algod  | GetPendingTransactionsByAddress |
      | algod_applications_PendingTransactionsResponse_1.base64 | generated_responses | 200    | algod  | GetPendingTransactionsByAddress |

    @unit.responses.messagepack.231
    Examples:
      | jsonfile                                   | response-folder         | status | client | endpoint                        |
      | algod_PendingTransactionResponse_0.base64  | generated_responses_231 | 200    | algod  | PendingTransactionInformation   |
      | algod_PendingTransactionsResponse_0.base64 | generated_responses_231 | 200    | algod  | GetPendingTransactions          |
      | algod_PendingTransactionsResponse_1.base64 | generated_responses_231 | 200    | algod  | GetPendingTransactions          |
      | algod_PendingTransactionsResponse_0.base64 | generated_responses_231 | 200    | algod  | GetPendingTransactionsByAddress |
      | algod_PendingTransactionsResponse_1.base64 | generated_responses_231 | 200    | algod  | GetPendingTransactionsByAddress |

    @unit.stateproof.responses
    Examples:
      | jsonfile                                | response-folder | status | client  | endpoint                 |
      | v2_algod_GetTransactionProof.json       | stateproof      | 200    | algod   | GetTransactionProof      |
      | v2_algod_GetLightBlockHeaderProof.json  | stateproof      | 200    | algod   | GetLightBlockHeaderProof |
      | v2_algod_GetStateProof.json             | stateproof      | 200    | algod   | GetStateProof            |
      | v2_indexer_lookupBlock_header.json      | stateproof      | 200    | indexer | lookupBlock              |
      | v2_indexer_lookupBlock_transaction.json | stateproof      | 200    | indexer | lookupBlock              |

    @unit.stateproof.responses.msgp
    Examples:
      | jsonfile                                | response-folder | status | client  | endpoint |
      | v2_algod_GetBlock_header.base64         | stateproof      | 200    | algod   | GetBlock |
      | v2_algod_GetBlock_transaction.base64    | stateproof      | 200    | algod   | GetBlock |
 
    @unit.responses.participationupdates
    Examples:
      | jsonfile                                        | response-folder     | status | client  | endpoint    | 
      | indexer_block_ParticipationupdatesResponse.json | generated_responses | 200    | indexer | lookupBlock |

    @unit.responses.blocksummary
    Examples:
      | jsonfile                   | response-folder             | status | client | endpoint     | 
      | v2_algod_GetBlockHash.json | v2algodclient_responsejsons | 200    | algod  | GetBlockHash |

    @unit.responses.blocksummary
    Examples:
      | jsonfile                                | response-folder               | status | client  | endpoint    | 
      | indexer_v2_lookupBlock_header_only.json | v2indexerclient_responsejsons | 200    | indexer | lookupBlock |

    @unit.responses.statedelta
    Examples:
      | jsonfile                         | response-folder             | status | client | endpoint            | 
      | statedelta_betanet_22085518.json | v2algodclient_responsejsons | 200    | algod  | GetLedgerStateDelta |
      | statedelta_testnet_26091000.json | v2algodclient_responsejsons | 200    | algod  | GetLedgerStateDelta |
      | statedelta_testnet_26091001.json | v2algodclient_responsejsons | 200    | algod  | GetLedgerStateDelta |
      | statedelta_testnet_26091002.json | v2algodclient_responsejsons | 200    | algod  | GetLedgerStateDelta |
      | statedelta_testnet_26091003.json | v2algodclient_responsejsons | 200    | algod  | GetLedgerStateDelta |

    @unit.responses.timestamp
    Examples:
      | jsonfile                    | response-folder             | status | client | endpoint                | 
      | devmodeTimestampOffset.json | v2algodclient_responsejsons | 200    | algod  | GetBlockTimeStampOffset |

    @unit.responses.sync
    Examples:
      | jsonfile                    | response-folder             | status | client | endpoint                |
      | getSyncRoundResponse.json   | v2algodclient_responsejsons | 200    | algod  | GetSyncRound            |
