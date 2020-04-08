Feature: Algod REST API v2
  Background:
    Given mock server recording request paths
  # SendRaw, Status, Supply, SuggestedParams, and PendingTransactionsInformation omitted - the path never mutates, they're constant

  Scenario Template: Shutdown
    When we make a Shutdown call with timeout <timeout>
    Then expect the path used to be "<path>"
    Examples:
      |path   | timeout |
      |TODO   | 0 |

  Scenario Template: Register Participation Keys
    When we make a Register Participation Keys call against account "<account>" fee <fee> dilution <dilution> lastvalidround <lastvalid> and nowait "<nowait>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account | fee | dilution | lastvalid | nowait|
      |TODO   | TODO    | 0   | 0        | 0         | false |

  Scenario Template: Pending Transaction Information
    When we make a Pending Transaction Information against txid "<txid>" with max <max>
    Then expect the path used to be "<path>"
    Examples:
      |path | txid| max|
      |TODO | TODO| 0  |

  Scenario Template: Pending Transactions By Address
    When we make a Pending Transactions By Address call against account "<account>" and max <max>
    Then expect the path used to be "<path>"
    Examples:
      |path | account| max|
      |TODO | TODO   | 0  |

  Scenario Template: Status After Block
    Given mock server recording request paths
    When we make a Status after Block call with round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path | round|
      |TODO | 0    |

  Scenario Template: Account Information
    When we make an Account Information call against account "<account>"
    Then expect the path used to be "<path>"
    Examples:
      |path | account|
      |TODO | TODO   |

  Scenario Template: Get Block
    When we make a Get Block call against block number <round>
    Then expect the path used to be "<path>"
    Examples:
      |path | round|
      |TODO | 0    |