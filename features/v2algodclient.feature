Feature: Algod REST API v2

  #TODO ejr there's no response, what's the recommended test? 
  Scenario Template: Shutdown
    When we make any Shutdown call, return mock response "<jsonfile>"
    Examples:
      |jsonfile|
      |TODO    |

  #TODO ejr there's no response, what's the recommended test?
  Scenario Template: Register Participation Keys
    When we make any Register Participation Keys call, return mock response "<jsonfile>"
    Examples:
      |jsonfile|
      |TODO    |

  Scenario Template: Pending Transaction Information
    When we make any Pending Transaction Information call, return mock response "<jsonfile>"
    Then the parsed Pending Transaction Information response should have sender "<sender>"
    Examples:
      |jsonfile|sender|
      |TODO    |TODO  |

  Scenario Template: Send Raw Transaction
    When we make any Send Raw Transaction call, return mock response "<jsonfile>"
    Then the parsed Send Raw Transaction response should have txid "<txid>"
    Examples:
      |jsonfile|txid|
      |TODO    |TODO|

  Scenario Template: Pending Transactions By Address
    When we make any Pending Transactions By Address call, return mock response "<jsonfile>"
    Then the parsed Pending Transactions By Address response should contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfile|len|idx|sender|
      |TODO    |0  |0  |TODO  |

  Scenario Template: Node Status
    When we make any Node Status call, return mock response "<jsonfile>"
    Then the parsed Node Status response should have a last round of <roundNum>
    Examples:
      |jsonfile|roundNum|
      |TODO    |0       |

  Scenario Template: Ledger Supply
    When we make any Ledger Supply call, return mock response "<jsonfile>"
    Then the parsed Ledger Supply response should have totalMoney <tot> onlineMoney <online> on round <roundNum>
    Examples:
      |jsonfile|tot|online|roundNum|
      |TODO    |0  |0     |0       |

  Scenario Template: Status After Block
    When we make any Status After Block call, return mock response "<jsonfile>"
    Then the parsed Status After Block response should have a last round of <roundNum>
    Examples:
      |jsonfile|roundNum|
      |TODO    |0       |

  Scenario Template: Account Information
    When we make any Account Information call, return mock response "<jsonfile>"
    Then the parsed Account Information response should have address "<address>"
    Examples:
      |jsonfile|address|
      |TODO    |TODO   |

  Scenario Template: Get Block
    When we make any Get Block call, return mock response "<jsonfile>"
    Then the parsed Get Block response should have proposer "<proposer>"
    Examples:
      |jsonfile|proposer|
      |TODO    |TODO    |

  Scenario Template: Suggested Transaction Parameters
    When we make any Suggested Transaction Parameters call, return mock response "<jsonfile>"
    Then the parsed Suggested Transaction Parameters response should have first round valid of <roundNum>
    Examples:
      |jsonfile|roundNum|
      |TODO    |0       |