Feature: Key
  Background: Kmd client
    Given an algod client
    And a kmd client
    And wallet information

  Scenario: Generate and delete key
    When I generate a key using kmd
    Then the key should be in the wallet
    When I delete the key
    Then the key should not be in the wallet

  Scenario: Import and export key
    When I generate a key
    And I import the key
    Then the private key should be equal to the exported private key

  Scenario Outline: Sign transaction
    Given payment transaction parameters <fee> <fv> <lv> "<gh>" "<to>" "<close>" <amt> "<gen>" "<note>"
    And mnemonic for private key "<mn>"
    When I create the payment transaction
    And I sign the transaction with the private key
    Then the signed transaction should equal the golden "<golden>"

    Examples: 
    | fee | fv    | lv    | gh                                           | to                                                         | close                                                      | amt  | gen          | note         | mn                                                                                                                                                                   | golden                                                                                                                                                                                                                                                                                                                                                                                                       |
    | 4   | 12466 | 13466 | JgsgCaCTqIaLeVhyL6XlRu3n7Rfk2FxMeK+wRSaQ7dI= | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | IDUTJEUIEVSMXTU4LGTJWZ2UE2E6TIODUKU6UW3FU3UKIQQ77RLUBBBFLA | 1000 | devnet-v33.0 | 6gAVR0Nsv5Y= | advice pudding treat near rule blouse same whisper inner electric quit surface sunny dismiss leader blood seat clown cost exist hospital century reform able sponsor | gqNzaWfEQPhUAZ3xkDDcc8FvOVo6UinzmKBCqs0woYSfodlmBMfQvGbeUx3Srxy3dyJDzv7rLm26BRv9FnL2/AuT7NYfiAWjdHhui6NhbXTNA+ilY2xvc2XEIEDpNJKIJWTLzpxZpptnVCaJ6aHDoqnqW2Wm6KRCH/xXo2ZlZc0EmKJmds0wsqNnZW6sZGV2bmV0LXYzMy4womdoxCAmCyAJoJOohot5WHIvpeVG7eftF+TYXEx4r7BFJpDt0qJsds00mqRub3RlxAjqABVHQ2y/lqNyY3bEIHts4k/rW6zAsWTinCIsV/X2PcOH1DkEglhBHF/hD3wCo3NuZMQg5/D4TQaBHfnzHI2HixFV9GcdUaGFwgCQhmf0SVhwaKGkdHlwZaNwYXk= |

  Scenario Outline: Sign both ways
    Given default transaction with parameters <amt> "<note>"
    When I get the private key
    And I sign the transaction with the private key
    And I sign the transaction with kmd
    Then the signed transaction should equal the kmd signed transaction
  
    Examples:
    | amt | note |
    | 0   | X4Bl4wQ9rCo= |
    | 1234523 | X4Bl4wQ9rCo= |