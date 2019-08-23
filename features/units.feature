Feature: Units
  Background:
    Given an algod client
    And a kmd client
    And wallet information

  Scenario Outline: Convert microAlgos to Algos
    Given a balance in microAlgos <microbal>
    When I convert the microAlgo balance to Algos
    Then the amount should equal the balance in Algos <bal>
    When I convert the Algo balance to microAlgos
    Then the amount should equal the balance in microAlgos <microbal>
    Examples:
    | microbal | bal |
    | 10000000 | 1   |