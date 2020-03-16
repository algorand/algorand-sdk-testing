Feature: v2 Indexer Endpoints
  Background:
    Given a mock indexer

  Scenario: endpoint json check
    When I make a GET request against endpoint <endpoint>
    Then the most recent response should look like <jsonfile>
    # TODO support multiple requests to explore e.g. pagination

  |endpoint|jsonfile|
  |TODO: many of these|TODO: many of these|