@unit.feetest
@unit
Feature: Transaction fee test
  Background:
    Given a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

  Scenario Outline: App Call Fee Test
    When I build an application transaction with operation "<operation>", application-id <application-id>, sender "<sender>", approval-program "<approval-prog-file>", clear-program "<clear-prog-file>", global-bytes <global-bytes>, global-ints <global-ints>, local-bytes <local-bytes>, local-ints <local-ints>, app-args "<app-args>", foreign-apps "<foreign-apps>", foreign-assets "<foreign-assets>", app-accounts "<app-accounts>", fee <fee>, first-valid <first-valid>, last-valid <last-valid>, genesis-hash "<genesis-hash>", extra-pages <extra-pages>
    And sign the transaction
    Then fee field is in txn
    When I build an application transaction with operation "<operation>", application-id <application-id>, sender "<sender>", approval-program "<approval-prog-file>", clear-program "<clear-prog-file>", global-bytes <global-bytes>, global-ints <global-ints>, local-bytes <local-bytes>, local-ints <local-ints>, app-args "<app-args>", foreign-apps "<foreign-apps>", foreign-assets "<foreign-assets>", app-accounts "<app-accounts>", fee 0, first-valid <first-valid>, last-valid <last-valid>, genesis-hash "<genesis-hash>", extra-pages <extra-pages>
    And sign the transaction
    Then fee field not in txn

    Examples:
      | operation | application-id | sender                                                     | approval-prog-file         | clear-prog-file            | global-bytes | global-ints | local-bytes | local-ints | app-args  | foreign-apps | foreign-assets | app-accounts                                                                                                          | fee  | first-valid | last-valid | genesis-hash      | golden                |extra-pages                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | create | 0 | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 | programs/loccheck.teal.tok | programs/one.teal.tok | 1 | 0 | 1 | 0 | str:test | 5555,6666 |  |  | 1234 | 9000 | 9010 | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQLgQe82pAVOJgOJmbckwZr7iAM91EXVO3GHsEJNUmcPLeH3wS3GX7fviNb7VJQF8p5+/GA016E/Uy9itvCxfSwGjdHhujKRhcGFhkcQEdGVzdKRhcGFwxFsCIAIAASYFBWhlbGxvBXdyaXRlBWNoZWNrA2ZvbwNiYXI2GgAoEkAAKDYaACkSQAAXNhoAKhIiIitjIhJAABc2GgESECNAABMiKycEZiNAAAAjI0AABSIjQAAApGFwZmGSzRWzzRoKpGFwZ3OBo25icwGkYXBsc4GjbmJzAaRhcHN1xAUCIAEBIqNmZWXNBNKiZnbNIyiiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs | 0 |
      | update | 456 | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 | programs/zero.teal.tok | programs/loccheck.teal.tok | 0  | 0  | 0  | 0  | str:test |  |  | AAZFG7YLUHOQ73J7UR7TPJA634OIDL5GIEURTW2QXN7VBRI7BDZCVN6QTI | 1234 | 9000 | 9010 | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQHNbuCglt4vyeDjPkFRDDpOym0K1GKyHjgr3e8hm+9MzrDIhzHIvUbNVYyU4G4X+UoLhrHHBVWYaIpNVD//VmgejdHhujKRhcGFhkcQEdGVzdKRhcGFuBKRhcGFwxAUCIAEAIqRhcGF0kcQgADJTfwuh3Q/tP6R/N6Qe3xyBr6ZBKRnbULt/UMUfCPKkYXBpZM0ByKRhcHN1xFsCIAIAASYFBWhlbGxvBXdyaXRlBWNoZWNrA2ZvbwNiYXI2GgAoEkAAKDYaACkSQAAXNhoAKhIiIitjIhJAABc2GgESECNAABMiKycEZiNAAAAjI0AABSIjQAAAo2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |
      | call        | 100             | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4     |                    |                 | 0            | 0           | 0           | 0          | str:test       | 5555,6666           | 7777,8888           | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM  | 1234          | 9000         | 9010  | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQEbhKgBScIWg4Cq9jLfSIE+LvH4hJSVGfU6ikR75waHFgIOy1Ut2dwdvkumHuiGzvJ0O0/ouMxnycqCyW49rWw6jdHhui6RhcGFhkcQEdGVzdKRhcGFzks0eYc0iuKRhcGF0ksQgACoyATtqMON+4ohUJO59fQVV6uCTn7aa/GvfndL+5/7EIAAHBAuPYqMysOAF8ALIwKUWNGgBCjFYJ8bPUnx4aXnnpGFwZmGSzRWzzRoKpGFwaWRko2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |
      | optin        | 100             | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4     |                    |                 | 0            | 0           | 0           | 0          | str:test       | 5555,6666           | 7777,8888           | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM  | 1234          | 9000         | 9010  | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQCavYI5oOpW5EXknuiLsxx+/VXQeXaEO8COfnKsvmOQzA8hINpy9IdU0OB8R5mwjb4u6gHCSSyoNz9wQq1fZcQ+jdHhujKRhcGFhkcQEdGVzdKRhcGFuAaRhcGFzks0eYc0iuKRhcGF0ksQgACoyATtqMON+4ohUJO59fQVV6uCTn7aa/GvfndL+5/7EIAAHBAuPYqMysOAF8ALIwKUWNGgBCjFYJ8bPUnx4aXnnpGFwZmGSzRWzzRoKpGFwaWRko2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |
      | clear        | 100             | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4     |                    |                 | 0            | 0           | 0           | 0          | str:test       | 5555,6666           | 7777,8888           | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM  | 1234          | 9000         | 9010  | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQJG+3VRzlHS7JxGAEqLu8TUAprs/6+P5HHJZZ0JvNYslk8cJs4axUOZ8icZUWcbSNY290gzn4vzCb9+Kfn6sgAujdHhujKRhcGFhkcQEdGVzdKRhcGFuA6RhcGFzks0eYc0iuKRhcGF0ksQgACoyATtqMON+4ohUJO59fQVV6uCTn7aa/GvfndL+5/7EIAAHBAuPYqMysOAF8ALIwKUWNGgBCjFYJ8bPUnx4aXnnpGFwZmGSzRWzzRoKpGFwaWRko2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |
      | closeout        | 100             | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4     |                    |                 | 0            | 0           | 0           | 0          | str:test       | 5555,6666           | 7777,8888           | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM  | 1234          | 9000         | 9010  | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQCgyXFm+653eOTGcswb0OPkF2NZe0nSZhSKBJzK+woWbo9dcl111qiR2xk3X0m21eTNynztPjvmloDKI10j/kAyjdHhujKRhcGFhkcQEdGVzdKRhcGFuAqRhcGFzks0eYc0iuKRhcGF0ksQgACoyATtqMON+4ohUJO59fQVV6uCTn7aa/GvfndL+5/7EIAAHBAuPYqMysOAF8ALIwKUWNGgBCjFYJ8bPUnx4aXnnpGFwZmGSzRWzzRoKpGFwaWRko2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |
      | delete        | 100             | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4     |                    |                 | 0            | 0           | 0           | 0          | str:test       | 5555,6666           | 7777,8888           | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM  | 1234          | 9000         | 9010  | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | gqNzaWfEQNRuI7jjkY7nVUFd+weVjF9vL80VLDDhOZTZ7Iu6gPpvMzgiaKhRWPw2GdvdggqyqAp6R71B0iNItmTKcS6ZhAmjdHhujKRhcGFhkcQEdGVzdKRhcGFuBaRhcGFzks0eYc0iuKRhcGF0ksQgACoyATtqMON+4ohUJO59fQVV6uCTn7aa/GvfndL+5/7EIAAHBAuPYqMysOAF8ALIwKUWNGgBCjFYJ8bPUnx4aXnnpGFwZmGSzRWzzRoKpGFwaWRko2ZlZc0E0qJmds0jKKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= | 0 |


  Scenario Outline: Payment Txn Fee Test
    Given payment transaction parameters <fee> <fv> <lv> "<gh>" "<to>" "<close>" <amt> "<gen>" "<note>"
    And mnemonic for private key "<mn>"
    And multisig addresses "<addresses>"
    When I create the multisig payment transaction
    And I sign the multisig transaction with the private key
    Then fee field is in txn
    Given payment transaction parameters 0 <fv> <lv> "<gh>" "<to>" "<close>" <amt> "<gen>" "<note>"
    And mnemonic for private key "<mn>"
    And multisig addresses "<addresses>"
    When I create the multisig payment transaction with zero fee
    And I sign the multisig transaction with the private key
    Then fee field not in txn

    Examples:
    | fee | fv    | lv    | gh                                           | to                                                         | close                                                      | amt  | gen          | note         | mn                                                                                                                                                                   | addresses                                                                                                                                                                        | golden                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
    | 4   | 12466 | 13466 | JgsgCaCTqIaLeVhyL6XlRu3n7Rfk2FxMeK+wRSaQ7dI= | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | IDUTJEUIEVSMXTU4LGTJWZ2UE2E6TIODUKU6UW3FU3UKIQQ77RLUBBBFLA | 1000 | devnet-v33.0 | X4Bl4wQ9rCo= | advice pudding treat near rule blouse same whisper inner electric quit surface sunny dismiss leader blood seat clown cost exist hospital century reform able sponsor | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU | gqRtc2lng6ZzdWJzaWeTgaJwa8QgG37AsEvqYbeWkJfmy/QH4QinBTUdC8mKvrEiCairgXiBonBrxCAJYzIJU3OJ8HVnEXc5kcfQPhtzyMT1K/av8BqiXPnCcYKicGvEIOfw+E0GgR358xyNh4sRVfRnHVGhhcIAkIZn9ElYcGihoXPEQF6nXZ7CgInd1h7NVspIPFZNhkPL+vGFpTNwH3Eh9gwPM8pf1EPTHfPvjf14sS7xN7mTK+wrz7Odhp4rdWBNUASjdGhyAqF2AaN0eG6Lo2FtdM0D6KVjbG9zZcQgQOk0koglZMvOnFmmm2dUJonpocOiqepbZabopEIf/FejZmVlzQSYomZ2zTCyo2dlbqxkZXZuZXQtdjMzLjCiZ2jEICYLIAmgk6iGi3lYci+l5Ubt5+0X5NhcTHivsEUmkO3Somx2zTSapG5vdGXECF+AZeMEPawqo3JjdsQge2ziT+tbrMCxZOKcIixX9fY9w4fUOQSCWEEcX+EPfAKjc25kxCCNkrSJkAFzoE36Q1mjZmpq/OosQqBd2cH3PuulR4A36aR0eXBlo3BheQ== |