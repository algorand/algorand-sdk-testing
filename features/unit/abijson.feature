@unit
Feature: AbiJson

  @unit.abijson
  Scenario Outline: Serialize Method object from sig into json
    When I create the Method object from method signature "<methodsig>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"

    Examples:
      | methodsig                                        | jsonfile                 | directory         |
      | add(uint32,uint32)uint32                         | addMethod.json           | abi_responsejsons |
      | add(uint32,uint32)void                           | addMethodVoid.json       | abi_responsejsons |
      | add()uint32                                      | addMethodNoArgs.json     | abi_responsejsons |
      | add((uint32,uint32))(uint32,uint32)              | addMethodTuple.json      | abi_responsejsons |
      | add(uint32,uint16)uint32                         | addMethodUint16.json     | abi_responsejsons |
      | referenceTest(account,application,asset)uint8[3] | referenceTestMethod.json | abi_responsejsons |
      | txnTest(txn,pay,keyreg,acfg,axfer,afrz,appl)bool | txnTestMethod.json       | abi_responsejsons |

  @unit.abijson
  Scenario Outline: Create and serialize Method object into json
    When I create the Method object with name "<name>" first argument type "<firstargtype>" second argument type "<secondargtype>" and return type "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"
    And the deserialized json should equal the original Method object

    Examples:
      | name | firstargtype | secondargtype | returntype | jsonfile       | directory         |
      | add  | uint32       | uint32        | uint32     | addMethod.json | abi_responsejsons |

  @unit.abijson
  Scenario Outline: Create and serialize Method object into json with arg names
    When I create the Method object with name "<name>" first argument name "<firstargname>" first argument type "<firstargtype>" second argument name "<secondargname>" second argument type "<secondargtype>" and return type "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"
    And the deserialized json should equal the original Method object

    Examples:
      | name | firstargname | firstargtype | secondargname | secondargtype | returntype | jsonfile                   | directory         |
      | add  | first        | uint32       | second        | uint32        | uint32     | addMethodWithArgNames.json | abi_responsejsons |

  @unit.abijson
  Scenario Outline: Create and serialize Method object into json with description
    When I create the Method object with name "<name>" method description "<methoddesc>" first argument type "<firstargtype>" first argument description "<firstdesc>" second argument type "<secondargtype>" second argument description "<seconddesc>" and return type "<returntype>"
    And I serialize the Method object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"
    And the deserialized json should equal the original Method object

    Examples:
      | name | methoddesc         | firstargtype | firstdesc         | secondargtype | seconddesc         | returntype | jsonfile                      | directory         |
      | add  | method description | uint32       | first description | uint16        | second description | uint32     | addMethodWithDescription.json | abi_responsejsons |

  @unit.abijson
  Scenario Outline: Check txn count of Method
    When I create the Method object from method signature "<methodsig>"
    Then the txn count should be <txncount>

    Examples:
      | methodsig                            | txncount |
      | add(uint32,uint32)uint32             | 1        |
      | txcalls(pay,bool,pay,axfer,byte)void | 4        |

  @unit.abijson
  Scenario Outline: Check method selector from Method
    When I create the Method object from method signature "<methodsig>"
    Then the method selector should be "<methodselector>"

    Examples:
      | methodsig                | methodselector |
      | add(uint32,uint32)uint32 | 3e1e52bd       |

  @unit.abijson
  Scenario Outline: Serialize Interface into json
    When I create the Method object from method signature "<methodsig>"
    And I create an Interface object from the Method object with name "<name>" and description "<description>"
    And I serialize the Interface object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"
    And the deserialized json should equal the original Interface object

    Examples:
      | methodsig                | name             | description                  | jsonfile       | directory         |
      | add(uint32,uint32)uint32 | ExampleInterface | This is an example interface | interface.json | abi_responsejsons |

  @unit.abijson
  Scenario Outline: Serialize Contract into json
    When I create the Method object from method signature "<methodsig>"
    And I create a Contract object from the Method object with name "<name>" and description "<description>"
    And I set the Contract's appID to <network1-app-id> for the network "<network1>"
    And I set the Contract's appID to <network2-app-id> for the network "<network2>"
    And I serialize the Contract object into json
    Then the produced json should equal "<jsonfile>" loaded from "<directory>"
    And the deserialized json should equal the original Contract object

    Examples:
      | methodsig                | name            | description                 | network1                                     | network1-app-id | network2                                     | network2-app-id | jsonfile      | directory         |
      | add(uint32,uint32)uint32 | ExampleContract | This is an example contract | wGHE2Pwdvd7S12BL5FaOP20EGYesN73ktiC1qzkkit8= | 1234            | SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI= | 5678            | contract.json | abi_responsejsons |


  @unit.abijson.byname
  Scenario Outline: Get a method by name from Interface
    When I append to my Method objects list in the case of a non-empty signature "<methodsig>"
    And I append to my Method objects list in the case of a non-empty signature "<extramethod>"
    And I create an Interface object from my Method objects list
    And I get the method from the Interface by name "<name>"
    Then the produced method signature should equal "<methodsig>". If there is an error it begins with "<error>"

    Examples:
      | methodsig                | extramethod              | name | error           |
      | add(uint32,uint32)uint32 |                          | add  |                 |
      | add(uint32,uint32)uint32 |                          | sub  | found 0 methods |
      | add(uint32,uint32)uint32 | add(uint64,uint64)uint64 | add  | found 2 methods |

  @unit.abijson.byname
  Scenario Outline: Get a method by name from Contract
    When I append to my Method objects list in the case of a non-empty signature "<methodsig>"
    And I append to my Method objects list in the case of a non-empty signature "<extramethod>"
    And I create a Contract object from my Method objects list
    And I get the method from the Contract by name "<name>"
    Then the produced method signature should equal "<methodsig>". If there is an error it begins with "<error>"

    Examples:
      | methodsig                | extramethod              | name | error           |
      | add(uint32,uint32)uint32 |                          | add  |                 |
      | add(uint32,uint32)uint32 |                          | sub  | found 0 methods |
      | add(uint32,uint32)uint32 | add(uint64,uint64)uint64 | add  | found 2 methods |
