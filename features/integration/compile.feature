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


# Scenario Outline: Compiled teals are as expected
#   When I compile a teal program <teal>
#   Then it is compiled with <status> and <result> and <hash>
#   And base64 decoding the response <result> is the same as the binary <program>
#   Examples:
#     | teal                            | program                             | status | hash                                                         | result                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
#     | "programs/one.teal"             | "programs/one.teal.tok"             | 200    | "YOE6C22GHCTKAN3HU4SE5PGIPN5UKXAJTXCQUPJ3KKF5HOAH646MKKCPDA" | "AiABASI="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
#     | "programs/zero.teal"            | "programs/zero.teal.tok"            | 200    | "U4TBITSQWSG2G4IMJYBOJPEEC535YPRSFMR2JE3ZMXDGY27U3CCO4HPCKQ" | "AiABACI="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
#     | "programs/abi_method_call.teal" | "programs/abi_method_call.teal.tok" | 200    | "EZD2SJS7UJI45CGG4GEVMCTPZCJ7GQNDUG74GU74C6WKOD2TEFAA7RNNBU" | "BSADAQACJgIEFR98dQRuYW1lMRgjEkAA4zEZgQQSNhoAgASg6BhyEhBAAMsxGSISNhoAgATPpo42EhBAALExGSQSNhoAgASp9Cs9EhBAAJoxGYEFEjYaAIAEJDeNPBIQQACCMRkjEjYaAIAE/mvfaRIQQABlMRkjEjYaAIAEqIwmpRIQQABOMRkjEjYaAIAEPjs9KBIQQAA0MRkjEjYaAIAEDfAFDxIQQAACI0M2GgE2GgI2GgM2GgQ2GgU2GgY2Ggc2Ggg2GgmIAPkiQzYaAYgAzCJDiACpIkM2GgE2GgKIAI4iQ4gAgiJDiABfIkM2GgGIADEiQ4gAKyJDMRsjDUAAAiJDNhoAgARDRkEBEkQ2GgGIAANC/+o1ACg0ABckCxZQsImJNQEjKTQBVwIAZoAGaGVsbG8gIyliUDUCKDQCFRZXBgJQNAJQsImACGdvb2RieWUgIyliUDUDKDQDFRZXBgJQNANQsIkxADIJEkSJNQU1BCg0BBc0BRcIFlCwiYAacmFuZG9tIGluY29uc2VxdWVudGlhbCBsb2ewiTUGMRYiCTgQIhJEKDEWIgk4CDQGFxJAAAaAAQBCAAOAAYBQsIk1DzUONQ01DDULNQo1CTUINQcoNAdQNAlQNAtQNAhQNA5QNA9QNApQNAxQNA1QsIk=" |
#     | "programs/fake_random.teal"     | "programs/fake_random.teal.tok"     | 200    | "DOY24Q6DKONK356FOJ4ATH53DLKOUFDR4COCZHDXZ7HMCF4UDLCJOBDB2A" | "BTYaAIAEIGY1EBJAABUyBhYDgQBbNhoBGBaABBUffHVMULCBAQ=="                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |


# Scenario Outline: Compiled teals are as expected - skip the hash check
#   When I compile a teal program <teal>
#   Then base64 decoding the response <result> is the same as the binary <program>
#   Examples:
#     | teal                            | program                             | result |
#     | "programs/one.teal"             | "programs/one.teal.tok"             | ""     |
#     | "programs/zero.teal"            | "programs/zero.teal.tok"            | ""     |
#     | "programs/abi_method_call.teal" | "programs/abi_method_call.teal.tok" | ""     |
#     | "programs/fake_random.teal"     | "programs/fake_random.teal.tok"     | ""     |
