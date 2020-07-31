@unit
@unit.responses
Feature: v2 REST Client Responses

  Scenario Outline: <client>: <endpoint> - <jsonfile>
    Given mock http responses in "<jsonfile>" loaded from "generated_responses" with status <status>.
    When we make any "<client>" call to "<endpoint>".
    Then the parsed response should equal the mock response.
    Examples:
      | jsonfile                                                | status | client  | endpoint                  |
      | indexer_applications_AccountResponse_0.json             | 200    | indexer | lookupAccountByID         |
      | indexer_applications_AccountsResponse_0.json            | 200    | indexer | searchForAccounts         |
      | indexer_applications_ApplicationResponse_0.json         | 200    | indexer | lookupApplicationByID     |
      | indexer_applications_ApplicationsResponse_0.json        | 200    | indexer | searchForApplications     |
      | indexer_applications_AssetBalancesResponse_0.json       | 200    | indexer | lookupAssetBalances       |
      | indexer_applications_AssetResponse_0.json               | 200    | indexer | lookupAssetByID           |
      | indexer_applications_AssetsResponse_0.json              | 200    | indexer | searchForAssets           |
      | indexer_applications_TransactionsResponse_0.json        | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_0.json        | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_0.json        | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_1.json        | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_1.json        | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_1.json        | 200    | indexer | searchForTransactions     |
      | indexer_applications_TransactionsResponse_2.json        | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_2.json        | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_2.json        | 200    | indexer | searchForTransactions     |
      | indexer_applications_ErrorResponse_0.json               | 500    | indexer | any                       |
      | algod_applications_NodeStatusResponse_0.json            | 200    | algod   | GetStatus                 |
      | algod_applications_NodeStatusResponse_0.json            | 200    | algod   | WaitForBlock              |
      | algod_applications_CompileResponse_0.json               | 200    | algod   | TealCompile               |
      | algod_applications_PostTransactionsResponse_0.json      | 200    | algod   | RawTransaction            |
      | algod_applications_SupplyResponse_0.json                | 200    | algod   | GetSupply                 |
      | algod_applications_TransactionParametersResponse_0.json | 200    | algod   | TransactionParams         |
      | algod_applications_ApplicationResponse_0.json           | 200    | algod   | GetApplicationByID        |
      | algod_applications_AssetResponse_0.json                 | 200    | algod   | GetAssetByID              |
      | algod_applications_ErrorResponse_0.json                 | 500    | algod   | any                       |
      # This one should be msp encoded...
      #| algod_applications_BlockResponse_0.json                 | 200    | algod   | GetBlock                  |
      # These are missing, and should be msp encoded...
      # PendingTransactionsResponse GetPendingTransactionsByAddress
      # PendingTransactionsResponse GetPendingTransactions
      # PendingTransactionsResponse GetPendingTransactionInformation
      # These are missing proper response objects, so they were not generated.
      # health check
      # metrics
      # Register participation keys
      # ShutdownNode
      # This is still WIP
      #| algod_applications_DryrunResponse_0.json                | 200    | algod   | Dryrun                    |

