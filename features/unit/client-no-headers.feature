@unit.client-no-headers
Feature: Client No Headers
  Background:
    # The mock servers are
    Given mock server recording request paths
    And an algod v2 client connected to mock server with token ""
    And an indexer v2 client connected to mock server with token ""

    # Using a random API call since we're just testing the headers and don't care about the request
  Scenario: Auth Headers Algod
    Given expected headers
      | key             |
      | accept-encoding |
      | user-agent      |
      | accept          |
      | connection      |
      | host            |
    When we make an arbitrary algod call
    Then expect the observed header keys to equal the expected header keys

    # Using a random API call since we're just testing the headers and don't care about the request
  Scenario: Auth Headers Indexer
    Given expected headers
      | key             |
      | accept-encoding |
      | user-agent      |
      | accept          |
      | connection      |
      | host            |
    When we make an arbitrary indexer call
    Then expect the observed header keys to equal the expected header keys
