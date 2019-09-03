@crosstest
Feature: Crosstesting
  Background: Kmd client
    Given an algod client
    And a kmd client
    And wallet information

  Scenario: Encoding
    When I read a transaction from file
    And I write the transaction to file
    Then the transaction should still be the same

  Scenario: Send a transaction
    Then I do my part
