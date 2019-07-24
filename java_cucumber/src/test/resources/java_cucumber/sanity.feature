Feature: Sanity
  Background:
    Given an algod client
    And a kmd client

  Scenario: Versions
    When I get versions with algod
    Then v1 should be in the versions
    When I get versions with kmd
    Then v1 should be in the versions

  Scenario: Status check
    When I get the status
    And I get status after this block
    Then the rounds should be equal
    And I can get the block info