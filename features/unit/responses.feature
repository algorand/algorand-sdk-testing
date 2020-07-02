@unit
@unit.responses
Feature: v2 REST Client Responses

  Scenario Outline: <client>: <endpoint> - <jsonfile>
    Given mock http responses in "<jsonfile>" loaded from "generated_responses" with status <status>.
    When we make any "<client>" call to "<endpoint>".
    Then the parsed response should equal the mock response.
    Examples:
      | jsonfile                                          | status | client  | endpoint                  |
      | indexer_applications_AccountResponse_0.json       | 200    | indexer | lookupAcocuntByID         |
      | indexer_applications_AccountsResponse_0           | 200    | indexer | searchForAccounts         |
      | indexer_applications_ApplicationResponse_0.json   | 200    | indexer | lookupApplicationByID     |
      | indexer_applications_ApplicationsResponse_0.json  | 200    | indexer | searchForApplications     |
      | indexer_applications_AssetBalancesResponse_0.json | 200    | indexer | lookupAssetBalances       |
      | indexer_applications_AssetResponse_0.json         | 200    | indexer | lookupAssetByID           |
      | indexer_applications_AssetsResponse_0.json        | 200    | indexer | searchForAssets           |
      | indexer_applications_TransactionsResponse_0.json  | 200    | indexer | lookupAccountTransactions |
      | indexer_applications_TransactionsResponse_0.json  | 200    | indexer | lookupAssetTransactions   |
      | indexer_applications_TransactionsResponse_0.json  | 200    | indexer | searchForTransactions     |
      | indexer_applications_ErrorResponse_0.json         | 500    | indexer | any                       |

