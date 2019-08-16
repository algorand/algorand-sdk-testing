Feature: Auction
  Background:
    Given an algod client
    And a kmd client

  Scenario: Build, sign, encode, and decode a bid
    Given bid parameters <tbd>
    And a passphrase for bidder <bidpass>
    When I build a bid
    Then there should be no error
    When I sign the bid
    Then there should be no error
    And the bid should equal the golden <golden>
    And the bid should not equal the wrong bid <wrongbid>
    When I encode the bid to bytes
    Then there should be no error
    Then I write the bytes to file <file>
    When I read the bytes from file <file>
    Then there should be no error
    When I decode the bytes to a bid
    Then the bid should equal the golden <golden>