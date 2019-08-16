Feature: Offline actions
  Background:
    Given an algod client
    And a kmd client
    And wallet information

  Scenario: Generate account offline
    When I generate an account while offline
    Then there should be no error

  Scenario: Generate account while offline and get address
    When I generate an account while offline
    Then I can get the generated account's address
    And there should be no error

  Scenario: Importing accounts from passphrase
    When I generate the private key
    Then I get the address from the private key
    When I convert the private key to passphrase
    And I get the address from the passphrase
    Then the two addresses should be equal

  Scenario: Fail to import account from bad passphrase
    Given golden passphrase <"goldpass"> golden address <"goldaddr"> and wrong passphrase <"badpass">
    When I convert the golden passphrase to address
    Then the result should match the golden address
    When I convert the wrong passphrase to address
    Then the result should not match the golden address

  Scenario: Build a flat-fee transaction and sign it offline
    Given a flat fee <flatfee> and a passphrase <"pass">
    When I build a flat fee transaction with flat fee <flatfee>
    And I convert the passphrase to a private key
    And I sign the transaction with the private key
    Then the transaction should equal the golden <"golden">


  Scenario: Build a fee-per-byte txn and sign it offline
    Given a fee paid per byte <feeperbyte> and a passphrase <"pass">
    When I build a fee per byte transaction with fee <feeperbyte> per byte
    And I convert the passphrase to a private key
    And I sign the transaction with the private key
    Then the transaction should equal the golden <"golden">

  Scenario: TODO: build a flat-fee-txn and sign it with a multisig
   #seems like we already have this in multisig.feature

  Scenario: Build and sign go-online and go-offline transaction
    Given change online status transaction parameters <fee> <fv> <lv> "<gh>" "<to>" "<close>" "<gen>" "<note>" <online>
    And mnemonic for private key "<mn>"
    And address <"address">
    When I create the change online status transaction
    And I sign the transaction with the private key
    Then the transaction should equal the golden <"golden">
    # example uses parameters to do both the go-online path and go-offline path

  Scenario: TODO: build a go-offline transaction and sign it offline
    #see above
