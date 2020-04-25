Feature: Algod REST API v2
  Background:
    Given mock server recording request paths
  # SendRaw, Status, Supply, SuggestedParams, and PendingTransactionsInformation omitted - the path never mutates, they're constant

  Scenario Outline: Shutdown
    When we make a Shutdown call with timeout <timeout>
    Then expect the path used to be "<path>"
    Examples:
      |path   | timeout |
      |TODO   | 0 |

  Scenario Outline: Register Participation Keys
    When we make a Register Participation Keys call against account "<account>" fee <fee> dilution <dilution> lastvalidround <lastvalid> and nowait "<nowait>"
    Then expect the path used to be "<path>"
    Examples:
      |path   | account | fee | dilution | lastvalid | nowait|
      |TODO   | TODO    | 0   | 0        | 0         | false |

  Scenario Outline: Pending Transaction Information
    When we make a Pending Transaction Information against txid "<txid>" with max <max>
    Then expect the path used to be "<path>"
    Examples:
      |path | txid| max|
      |TODO | TODO| 0  |

  Scenario Outline: Pending Transactions Information
    When we make a Pending Transactions Information call with max <max>
    Then expect the path used to be "<path>"
    Examples:
      |path | max|
      |TODO | 0  |

  Scenario Outline: Pending Transactions By Address
    When we make a Pending Transactions By Address call against account "<account>" and max <max>
    Then expect the path used to be "<path>"
    Examples:
      |path | account| max|
      |TODO | TODO   | 0  |

  Scenario Outline: Status After Block
    When we make a Status after Block call with round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path | round|
      |TODO | 0    |

  Scenario Outline: Account Information
    When we make an Account Information call against account "<account>"
    Then expect the path used to be "<path>"
    Examples:
      |path | account|
      |TODO | TODO   |

  Scenario Outline: Get Block
    When we make a Get Block call against block number <round>
    Then expect the path used to be "<path>"
    Examples:
      |path | round|
      |TODO | 0    |