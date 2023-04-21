Feature: Dev mode features
  Background:
    Given an algod v2 client

  @devmode.offset
  Scenario: Setting timestamp offsets in dev mode
    When I set the timestamp offset to be 1234
    And I get the timestamp offset
    Then the timestamp offset should be 1234
