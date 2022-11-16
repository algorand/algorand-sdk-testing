@algod
Feature: Algod
  Background:
    Given an algod v2 client connected to "localhost" port 60000 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  Scenario: Node health
    Then the node should be healthy

  Scenario: Ledger supply
    Then I get the ledger supply

  Scenario: Version
    When I get versions with algod
    Then v2 should be in the versions
