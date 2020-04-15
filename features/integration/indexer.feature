Feature: Indexer
  Background:
    Given an indexer client at "http://localhost" port 59999 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  Scenario: blocks endpoint
    When I request block <number>
    Then The block was confirmed at <timestamp>, contains <number-of-transaction> transactions, has the previous block hash <previous-block-hash>
    Examples:
      | number | timestamp  | number-of-transactions | previous-block-hash                          |
      | 7      | 1585684086 | 8                      | PpPusF+bU/uNLS5ODG/hG0pP0vehdSSlBcnnyZDr770= |
      | 20     | 1585684138 | 2                      | 9jzxFIKLoTGkFl60aqGwyzO0AVyMBnbs/Wb5R9hPrsA= |
      | 100    | 1585684463 | 0                      | rEWRbwgzDagT5wYTf9TuiuC+VR3XLLy4S73vInxkmrA= |
