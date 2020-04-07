Feature: Algod REST API v2

  Scenario Template: Shutdown response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Shutdown call
    Then expect error string to contain "<err>"
    Examples:
      |jsonfiles|directory|err|
      |TODO     |         |nil|

  Scenario Template: Register Participation Keys response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Register Participation Keys call
    Then expect error string to contain "<err>"
    Examples:
      |jsonfiles|directory|err|
      |TODO     |         |nil|

  Scenario Template: Pending Transaction Information response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Pending Transaction Information call
    Then expect error string to contain "<err>"
    And the parsed Pending Transaction Information response should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|sender|
      |TODO     |         |nil|TODO  |

  Scenario Template: Pending Transactions Information response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Pending Transactions Information call
    Then expect error string to contain "<err>"
    And the parsed Pending Transactions Information response should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|sender|
      |TODO     |         |nil|TODO  |

  Scenario Template: Send Raw Transaction response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Send Raw Transaction call
    Then expect error string to contain "<err>"
    And the parsed Send Raw Transaction response should have txid "<txid>"
    Examples:
      |jsonfiles|directory|err|txid|
      |TODO     |         |nil|TODO|

  Scenario Template: Pending Transactions By Address response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Pending Transactions By Address call
    Then expect error string to contain "<err>"
    And the parsed Pending Transactions By Address response should contain an array of len <len> and element number <idx> should have sender "<sender>"
    Examples:
      |jsonfiles|directory|err|len|idx|sender|
      |TODO     |         |nil|0  |0  |TODO  |

  Scenario Template: Node Status response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Node Status call
    Then expect error string to contain "<err>"
    And the parsed Node Status response should have a last round of <roundNum>
    Examples:
      |jsonfiles|directory|err|roundNum|
      |TODO     |         |nil|0       |

  Scenario Template: Ledger Supply response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Ledger Supply call
    Then expect error string to contain "<err>"
    And the parsed Ledger Supply response should have totalMoney <tot> onlineMoney <online> on round <roundNum>
    Examples:
      |jsonfiles|directory|err|tot|online|roundNum|
      |TODO     |         |nil|0  |0     |0       |

  Scenario Template: Status After Block response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Status After Block call
    Then expect error string to contain "<err>"
    And the parsed Status After Block response should have a last round of <roundNum>
    Examples:
      |jsonfiles|directory|err|roundNum|
      |TODO     |         |nil|0       |

  Scenario Template: Account Information response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Account Information call
    Then expect error string to contain "<err>"
    And the parsed Account Information response should have address "<address>"
    Examples:
      |jsonfiles|directory|err|address|
      |TODO     |         |nil|TODO   |

  Scenario Template: Get Block response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Get Block call
    Then expect error string to contain "<err>"
    And the parsed Get Block response should have rewards pool "<pool>"
    Examples:
      |jsonfiles|directory|err|pool    |
      |TODO     |         |nil|TODO    |

  Scenario Template: Suggested Transaction Parameters response
    Given mock http responses in "<jsonfiles>" loaded from "<directory>"
    When we make any Suggested Transaction Parameters call
    Then expect error string to contain "<err>"
    And the parsed Suggested Transaction Parameters response should have first round valid of <roundNum>
    Examples:
      |jsonfiles|directory|err|roundNum|
      |TODO     |         |nil|0       |