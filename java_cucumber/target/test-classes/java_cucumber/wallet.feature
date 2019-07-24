Feature: Wallet
  Background: Wallet
    Given a kmd client
    And wallet information

  Scenario: Create and rename wallet
    When I create a wallet
    Then the wallet should exist
    When I get the wallet handle
    Then I can get the master derivation key
    When I rename the wallet
    Then I can still get the wallet information with the same handle

  Scenario: Wallet handle
    When I get the wallet handle
    And I renew the wallet handle
    And I release the wallet handle
    Then the wallet handle should not work

  