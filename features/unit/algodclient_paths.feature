@unit
Feature: Algod REST API version agnostic paths
  Background:
    Given mock server recording request paths

  @unit.ready
  Scenario Outline: Ready path
    When we make a Ready call
    Then expect the request to be "<method>" "<path>"
    Examples:
      | path   | method |
      | /ready | get    |
