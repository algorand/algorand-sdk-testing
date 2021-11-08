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


