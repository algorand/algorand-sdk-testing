Feature: Algod REST API v2
  Background:
    Given mock server recording request paths
  # SendRaw, Status, Supply, SuggestedParams, and PendingTransactionsInformation omitted - the path never mutates, they're constant

  Scenario Outline: Shutdown
    When we make a Shutdown call with timeout <timeout>
    Then expect the path used to be "<path>"
    Examples:
      |path                   | timeout |
      |/v2/shutdown           | 0 |
      |/v2/shutdown?timeout=1 | 1 |

  # Scenario Outline: Register Participation Keys
  #   When we make a Register Participation Keys call against account "<account>" fee <fee> dilution <dilution> lastvalidround <lastvalid> and nowait "<nowait>"
  #   Then expect the path used to be "<path>"
  #   Examples:
  #     |path                                                                                        | account                                                       | fee | dilution | lastvalid | nowait|
  #     |/v2/register-participation-keys/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q  | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q    | 0   | 0        | 0         | false |
  #     |/v2/register-participation-keys/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q?fee=1001&key-dilution=23&round-last-valid=12345&no-wait=true  | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q    | 1001   | 23        | 12345         | true |

  Scenario Outline: Pending Transaction Information
    When we make a Pending Transaction Information against txid "<txid>" with format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      |path | txid| format |
      |/v2/transactions/pending/5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ?format=msgpack | 5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ| msgpack |

  Scenario Outline: Pending Transaction Information
    When we make a Pending Transaction Information with max <max> and format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      |path | max| format |
      |/v2/transactions/pending?format=msgpack | 0  | msgpack |
      |/v2/transactions/pending?format=msgpack&max=1 | 1  | msgpack |

  Scenario Outline: Pending Transactions By Address
    When we make a Pending Transactions By Address call against account "<account>" and max <max> and format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      |path | account| max | format |
      |/v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/transactions/pending?format=msgpack | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q   | 0  | msgpack |
      |/v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/transactions/pending?format=msgpack&max=1 | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q   | 1  | msgpack |

  Scenario Outline: Status After Block
    When we make a Status after Block call with round <round>
    Then expect the path used to be "<path>"
    Examples:
      |path | round|
      |/v2/status/wait-for-block-after/0 | 0    |

  Scenario Outline: Account Information
    When we make an Account Information call against account "<account>"
    Then expect the path used to be "<path>"
    Examples:
      |path | account|
      |/v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q   |

  Scenario Outline: Get Block
    When we make a Get Block call against block number <round> with format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      |path | round| format |
      |/v2/blocks/0?format=msgpack | 0    | msgpack |

