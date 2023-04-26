@unit
Feature: Algod REST API v2 Paths
  Background:
    Given mock server recording request paths
  # SendRaw, Status, Supply, SuggestedParams, and PendingTransactionsInformation omitted - the path never mutates, they're constant

  @unit.algod
  Scenario Outline: Pending Transaction Information
    When we make a Pending Transaction Information against txid "<txid>" with format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                         | txid                                                 | format  |
      | /v2/transactions/pending/5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ?format=msgpack | 5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ | msgpack |

  @unit.algod
  Scenario Outline: Pending Transaction Information2
    When we make a Pending Transaction Information with max <max> and format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                          | max | format  |
      | /v2/transactions/pending?format=msgpack       | 0   | msgpack |
      | /v2/transactions/pending?format=msgpack&max=1 | 1   | msgpack |

  @unit.algod
  Scenario Outline: Pending Transactions By Address
    When we make a Pending Transactions By Address call against account "<account>" and max <max> and format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                              | account                                                    | max | format  |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/transactions/pending?format=msgpack       | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 0   | msgpack |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q/transactions/pending?format=msgpack&max=1 | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 1   | msgpack |

  @unit.algod
  Scenario Outline: Status After Block
    When we make a Status after Block call with round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                              | round |
      | /v2/status/wait-for-block-after/0 | 0     |

  @unit.algod
  Scenario Outline: Account Information
    When we make an Account Information call against account "<account>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                    | account                                                    |
      | /v2/accounts/7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q | 7ZUECA7HFLZTXENRV24SHLU4AVPUTMTTDUFUBNBD64C73F3UHRTHAIOF6Q |

  @unit.algod
  Scenario Outline: Get Block
    When we make a Get Block call against block number <round> with format "<format>"
    Then expect the path used to be "<path>"
    Examples:
      | path                        | round | format  |
      | /v2/blocks/0?format=msgpack | 0     | msgpack |

  @unit.applications
  Scenario Outline: GetAssetByID
    When we make a GetAssetByID call for assetID <asset-id>
    Then expect the path used to be "<path>"
    Examples:
      | path            | asset-id |
      | /v2/assets/1234 | 1234     |

  @unit.applications
  Scenario Outline: GetApplicationByID
    When we make a GetApplicationByID call for applicationID <application-id>
    Then expect the path used to be "<path>"
    Examples:
      | path                  | application-id |
      | /v2/applications/1234 | 1234           |

  @unit.applications.boxes
  Scenario Outline: GetApplicationBoxByName
    When we make a GetApplicationBoxByName call for applicationID <application-id> with encoded box name "<encoded-box-name>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                | application-id | encoded-box-name     |
      | /v2/applications/1234/box?name=b64%3AaGVsbG8%3D     | 1234           | b64:aGVsbG8=         |
      | /v2/applications/1234/box?name=b64%3A%2Fw%3D%3D     | 1234           | b64:/w==             |
      | /v2/applications/1234/box?name=b64%3A8J%2BSqQ%3D%3D | 1234           | b64:8J+SqQ==         |
      | /v2/applications/1234/box?name=b64%3AYS96           | 1234           | b64:YS96             |

  @unit.applications.boxes
  Scenario Outline: GetApplicationBoxes
    When we make a GetApplicationBoxes call for applicationID <application-id> with max <max>
    Then expect the path used to be "<path>"
    Examples:
      | path                              | application-id | max |
      | /v2/applications/1234/boxes       | 1234           | 0   |
      | /v2/applications/1234/boxes?max=2 | 1234           | 2   |

  @unit.algod.ledger_refactoring
  Scenario Outline: Account Information
    When we make an Account Information call against account "<account>" with exclude "<exclude>"
    Then expect the path used to be "<path>"
    Examples:
      | path                         | account | exclude |
      | /v2/accounts/47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU             | 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU     |         |
      | /v2/accounts/47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU?exclude=all | 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU     | all     |

  @unit.algod.ledger_refactoring
  Scenario Outline: Account Asset Information
    When we make an Account Asset Information call against account "<account>" assetID <asset-id>
    Then expect the path used to be "<path>"
    Examples:
      | path                        | account | asset-id |
      | /v2/accounts/47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU/assets/123 | 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU     | 123      |

  @unit.algod.ledger_refactoring
  Scenario Outline: Account Application Information
    When we make an Account Application Information call against account "<account>" applicationID <application-id>
    Then expect the path used to be "<path>"
    Examples:
      | path                              | account | application-id |
      | /v2/accounts/47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU/applications/123 | 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU     | 123            |

  @unit.paths.stateproof
  Scenario Outline: GetTransactionProof
    When we make a GetTransactionProof call for round <round> txid "<txid>" and hashtype "<hashtype>"
    Then expect the path used to be "<path>"
    Examples:
      | path                                                                                                                      | round | txid                                                 | hashtype   |
      | /v2/blocks/123/transactions/5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ/proof?format=msgpack                     | 123   | 5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ |            |
      | /v2/blocks/123/transactions/5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ/proof?format=msgpack&hashtype=sha512_256 | 123   | 5FJDJD5LMZC3EHUYYJNH5I23U4X6H2KXABNDGPIL557ZMJ33GZHQ | sha512_256 |

  @unit.stateproof.paths
  Scenario Outline: GetLightBlockHeaderProof
    When we make a GetLightBlockHeaderProof call for round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                             | round |
      | /v2/blocks/123/lightheader/proof | 123   |

  @unit.stateproof.paths
  Scenario Outline: GetStateProof
    When we make a GetStateProof call for round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                | round |
      | /v2/stateproofs/123 | 123   |

  @unit.blocksummary
  Scenario Outline: LookupBlockHash path
    When we make a Lookup Block Hash call against round <round>
    Then expect the path used to be "<path>"
    Examples:
      | path                           | round |
      | /v2/blocks/3/hash              | 3     |

  @unit.statedelta
  Scenario Outline: GetLedgerStateDelta path
    When we make a GetLedgerStateDelta call against round <round>
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path         | method | round |
      | /v2/deltas/3 | get    | 3     |

  @unit.sync
  Scenario Outline: SetSyncRound path
    When we make a SetSyncRound call against round <round>
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path              | method | round |
      | /v2/ledger/sync/3 | post   | 3     |

  @unit.sync
  Scenario Outline: GetSyncRound path
    When we make a GetSyncRound call
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path            | method |
      | /v2/ledger/sync | get    |

  @unit.sync
  Scenario Outline: UnsetSyncRound path
    When we make a UnsetSyncRound call
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path            | method |
      | /v2/ledger/sync | delete |

  @unit.timestamp
  Scenario Outline: SetBlockTimeStampOffset path
    When we make a SetBlockTimeStampOffset call against offset <offset>
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path                          | method | offset |
      | /v2/devmode/blocks/offset/123 | post   | 123    |

  @unit.timestamp
  Scenario Outline: GetBlockTimeStampOffset path
    When we make a GetBlockTimeStampOffset call
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path                      | method |
      | /v2/devmode/blocks/offset | get    |
