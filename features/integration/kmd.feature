@kmd
Feature: KMD
  Background:
    Given a kmd client
    And wallet information

  Scenario: Version
    When I get versions with kmd
    Then v1 should be in the versions

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

  Scenario: Generate and delete key
    When I generate a key using kmd
    Then the key should be in the wallet
    When I delete the key
    Then the key should not be in the wallet

  Scenario: Import and export key
    When I generate a key
    And I import the key
    Then the private key should be equal to the exported private key

  Scenario Outline: Import and export multisig
    Given multisig addresses "<addresses>"
    When I import the multisig
    Then the multisig should be in the wallet
    When I export the multisig
    Then the multisig should equal the exported multisig
    When I delete the multisig
    Then the multisig should not be in the wallet

    Examples:
      | addresses                                                                                                                                                                        |
      | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU |
