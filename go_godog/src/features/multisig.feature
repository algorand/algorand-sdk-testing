Feature: Multisig
  Background: Kmd client
    Given an algod client
    And a kmd client
    And wallet information

  Scenario Outline: Import and export multisig
    Given multisig addresses "<addresses>"
    When I import the multisig
    Then the multisig should be in the wallet
    When I export the multisig
    Then the multisig should equal the exported multisig
    When I delete the multisig
    Then the multisig should not be in the wallet

    Examples:
    | addresses |
    | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU |

  Scenario Outline: Sign multisig
    Given payment transaction parameters <fee> <fv> <lv> "<gh>" "<to>" "<close>" <amt> "<gen>" "<note>"
    And mnemonic for private key "<mn>"
    And multisig addresses "<addresses>"
    When I create the multisig payment transaction
    And I sign the multisig transaction with the private key
    Then the multisig transaction should equal the golden "<golden>"

    Examples: 
    | fee | fv    | lv    | gh                                           | to                                                         | close                                                      | amt  | gen          | note         | mn                                                                                                                                                                   | addresses                                                                                                                                                                        | golden                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
    | 4   | 12466 | 13466 | JgsgCaCTqIaLeVhyL6XlRu3n7Rfk2FxMeK+wRSaQ7dI= | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | IDUTJEUIEVSMXTU4LGTJWZ2UE2E6TIODUKU6UW3FU3UKIQQ77RLUBBBFLA | 1000 | devnet-v33.0 | X4Bl4wQ9rCo= | advice pudding treat near rule blouse same whisper inner electric quit surface sunny dismiss leader blood seat clown cost exist hospital century reform able sponsor | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU | gqRtc2lng6ZzdWJzaWeTgaJwa8QgG37AsEvqYbeWkJfmy/QH4QinBTUdC8mKvrEiCairgXiBonBrxCAJYzIJU3OJ8HVnEXc5kcfQPhtzyMT1K/av8BqiXPnCcYKicGvEIOfw+E0GgR358xyNh4sRVfRnHVGhhcIAkIZn9ElYcGihoXPEQF6nXZ7CgInd1h7NVspIPFZNhkPL+vGFpTNwH3Eh9gwPM8pf1EPTHfPvjf14sS7xN7mTK+wrz7Odhp4rdWBNUASjdGhyAqF2AaN0eG6Lo2FtdM0D6KVjbG9zZcQgQOk0koglZMvOnFmmm2dUJonpocOiqepbZabopEIf/FejZmVlzQSYomZ2zTCyo2dlbqxkZXZuZXQtdjMzLjCiZ2jEICYLIAmgk6iGi3lYci+l5Ubt5+0X5NhcTHivsEUmkO3Somx2zTSapG5vdGXECF+AZeMEPawqo3JjdsQge2ziT+tbrMCxZOKcIixX9fY9w4fUOQSCWEEcX+EPfAKjc25kxCCNkrSJkAFzoE36Q1mjZmpq/OosQqBd2cH3PuulR4A36aR0eXBlo3BheQ== |

  Scenario Outline: Sign both ways
    Given default multisig transaction with parameters <amt> "<note>"
    When I sign the multisig transaction with kmd
    And I get the private key
    And I sign the multisig transaction with the private key
    Then the multisig transaction should equal the kmd signed multisig transaction
    
    Examples:
    | amt | note |
    | 0   | X4Bl4wQ9rCo= |
    | 1234523 | X4Bl4wQ9rCo= |

  Scenario Outline: Multisig address
    Given multisig addresses "<addresses>"
    Then the multisig address should equal the golden "<golden>"

    Examples:
    | addresses                                                                                                                                                                        | golden                                                     |
    | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU | RWJLJCMQAFZ2ATP2INM2GZTKNL6OULCCUBO5TQPXH3V2KR4AG7U5UA5JNM |


