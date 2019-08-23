Feature: REST Endpoints
  Background: Client setup
    Given an algod client
    And a kmd client
    And wallet information

  Scenario: Get Status
    When I get the status

  Scenario: Get Status-After-Block and Block Info
    When I get the status after this block
    And I can get the block info

  Scenario: Get Node Health
    When I get the node health

  Scenario: Get Ledger Supply
    When I get the ledger supply

  Scenario: Get Transactions By Address
    When I get recent transactions from address "<address>"

  Scenario: Get Transactions By Address and Limit Count
    When I get recent transactions from address "<address>" limited by count <cnt>

  Scenario: Get Transactions By Address and Round
    When I get recent transactions from address "<address>" limited by first round <fr> and last round <lr>

  Scenario: Get Transactions By Address and Date
    When I get recent transactions from address "<address>" limited by first date "<startdate>" and last date "<lastdate>"

  Scenario: Get Transaction by ID
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I send the transaction
    Then I can get transaction information using the TXID

  Scenario: Make Account And Query Info
    When I ask algod to make a new account
    When I get account information using account

  Scenario: Get Current Suggested Parameters
    When I get the current suggested parameters

