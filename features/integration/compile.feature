@compile
Feature: Compile
  Background:
    Given an algod v2 client

  Scenario Outline: Compile programs
    When I compile a teal program <program>
    Then it is compiled with <status> and <result> and <hash>
    Examples:
      | program                 | status | result     | hash                                                         |
      | "programs/one.teal"     | 200    | "AiABASI=" | "YOE6C22GHCTKAN3HU4SE5PGIPN5UKXAJTXCQUPJ3KKF5HOAH646MKKCPDA" |
      | "programs/invalid.teal" | 400    | ""         | ""                                                           |


  Scenario Outline: Teals compile to their associated binary
    When I compile a teal program <teal>
    Then base64 decoding the response is the same as the binary <program>
    Examples:
      | teal                            | program                             |
      | "programs/one.teal"             | "programs/one.teal.tok"             |
      | "programs/zero.teal"            | "programs/zero.teal.tok"            |
      | "programs/abi_method_call.teal" | "programs/abi_method_call.teal.tok" |

  @compile.sourcemap
  Scenario Outline: Teals return a valid Source Map
    When I compile a teal program <teal> with mapping enabled
    Then the resulting source map is the same as the json <sourcemap>
    Examples:
      | teal                  | sourcemap                                    |
      | "programs/quine.teal" | "v2algodclient_responsejsons/sourcemap.json" |