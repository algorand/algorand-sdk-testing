@unit.abijson
@unit
Feature: AbiJson
  Scenario Outline: Serialize Method object from sig into json 
    When I create the Method object from "<methodsig>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"

    Examples:
      | methodsig                | jsonfile       | directory         |
      | add(uint32,uint32)uint32 | addMethod.json | abi_responsejsons |

  Scenario Outline: Create and serialize Method object into json
    When I create the Method object with "<name>" "<firstargtype>" "<secondargtype>" "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"

    Examples:
      | name  | firstargtype | secondargtype | returntype | jsonfile       | directory         |
      | add   | uint32       | uint32        | uint32     | addMethod.json | abi_responsejsons |

  Scenario Outline: Create and serialize Method object into json with arg names
    When I create the Method object with "<name>" "<firstargname>" "<firstargtype>" "<secondargname>" "<secondargtype>" "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"

    Examples:
      | name  | firstargname | firstargtype | secondargname | secondargtype | returntype | jsonfile                   | directory         |
      | add   | first        | uint32       | second        | uint32        | uint32     | addMethodWithArgNames.json | abi_responsejsons |

  Scenario Outline: Create and serialize Method object into json with description
    When I create the Method object with "<name>" "<methoddesc>" "<firstargtype>" "<firstdesc>" "<secondargtype>" "<seconddesc>" "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"

    Examples:
      | name  | methoddesc  | firstargtype | firstdesc   | secondargtype | seconddesc  | returntype | jsonfile                      | directory         |
      | add   | description | uint32       | description | uint32        | description | uint32     | addMethodWithDescription.json | abi_responsejsons |

  Scenario Outline: Check txn count of Method
    When I create the Method object from "<methodsig>"
    Then the txn count should be <txncount>

    Examples:
      | methodsig                            | txncount |
      | add(uint32,uint32)uint32             | 1        |
      | txcalls(pay,bool,pay,axfer,byte)void | 4        |

  Scenario Outline: Check method selector from Method
    When I create the Method object from "<methodsig>"
    Then the method selector should be "<methodselector>"

    Examples:
      | methodsig                            | methodselector |
      | add(uint32,uint32)uint32             | 3e1e52bd       |

