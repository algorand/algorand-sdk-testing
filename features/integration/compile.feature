@compile
Feature: Compile
  Background:
    Given an algod v2 client

  Scenario Outline: Compile programs
    When I compile a teal program <program>
    Then it is compiled with <status> and <result> and <hash>
    Scenarios:
      | program                 | status | result     | hash |
      | "programs/one.teal"     | 200    | "ASABASI=" | "6Z3C3LDVWGMX23BMSYMANACQOSINPFIRF77H7N3AWJZYV6OH6GWTJKVMXY" |
      | "programs/invalid.teal" | 400    | ""         | "" |
