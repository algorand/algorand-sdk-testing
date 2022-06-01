@unit.feetest
@unit
Feature: Transaction fee test
  Background:
    Given a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

  Scenario Outline: App Call Fee Test
    When I build an application transaction with operation "<operation>", application-id <application-id>, sender "<sender>", approval-program "<approval-prog-file>", clear-program "<clear-prog-file>", global-bytes <global-bytes>, global-ints <global-ints>, local-bytes <local-bytes>, local-ints <local-ints>, app-args "<app-args>", foreign-apps "<foreign-apps>", foreign-assets "<foreign-assets>", app-accounts "<app-accounts>", fee <fee>, first-valid <first-valid>, last-valid <last-valid>, genesis-hash "<genesis-hash>", extra-pages <extra-pages>, boxes ""
    And sign the transaction
    Then fee field is in txn
    When I build an application transaction with operation "<operation>", application-id <application-id>, sender "<sender>", approval-program "<approval-prog-file>", clear-program "<clear-prog-file>", global-bytes <global-bytes>, global-ints <global-ints>, local-bytes <local-bytes>, local-ints <local-ints>, app-args "<app-args>", foreign-apps "<foreign-apps>", foreign-assets "<foreign-assets>", app-accounts "<app-accounts>", fee 0, first-valid <first-valid>, last-valid <last-valid>, genesis-hash "<genesis-hash>", extra-pages <extra-pages>, boxes ""
    And sign the transaction
    Then fee field not in txn

    Examples:
      | operation | application-id | sender                                                     | approval-prog-file         | clear-prog-file            | global-bytes | global-ints | local-bytes | local-ints | app-args | foreign-apps | foreign-assets | app-accounts                                                                                                          | fee  | first-valid | last-valid | genesis-hash                                 | extra-pages |
      | create    | 0              | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 | programs/loccheck.teal.tok | programs/one.teal.tok      | 1            | 0           | 1           | 0          | str:test | 5555,6666    |                |                                                                                                                       | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | update    | 456            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 | programs/zero.teal.tok     | programs/loccheck.teal.tok | 0            | 0           | 0           | 0          | str:test |              |                | AAZFG7YLUHOQ73J7UR7TPJA634OIDL5GIEURTW2QXN7VBRI7BDZCVN6QTI                                                            | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | call      | 100            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 |                            |                            | 0            | 0           | 0           | 0          | str:test | 5555,6666    | 7777,8888      | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | optin     | 100            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 |                            |                            | 0            | 0           | 0           | 0          | str:test | 5555,6666    | 7777,8888      | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | clear     | 100            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 |                            |                            | 0            | 0           | 0           | 0          | str:test | 5555,6666    | 7777,8888      | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | closeout  | 100            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 |                            |                            | 0            | 0           | 0           | 0          | str:test | 5555,6666    | 7777,8888      | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |
      | delete    | 100            | BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4 |                            |                            | 0            | 0           | 0           | 0          | str:test | 5555,6666    | 7777,8888      | AAVDEAJ3NIYOG7XCRBKCJ3T5PUCVL2XASOP3NGX4NPPZ3UX6477PBG6E4Q,AADQIC4PMKRTFMHAAXYAFSGAUULDI2ABBIYVQJ6GZ5JHY6DJPHTU2SPHYM | 1234 | 9000        | 9010       | Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M= | 0           |


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
      | fee | fv    | lv    | gh                                           | to                                                         | close                                                      | amt  | gen          | note         | mn                                                                                                                                                                   | addresses                                                                                                                                                                        |
      | 4   | 12466 | 13466 | JgsgCaCTqIaLeVhyL6XlRu3n7Rfk2FxMeK+wRSaQ7dI= | PNWOET7LLOWMBMLE4KOCELCX6X3D3Q4H2Q4QJASYIEOF7YIPPQBG3YQ5YI | IDUTJEUIEVSMXTU4LGTJWZ2UE2E6TIODUKU6UW3FU3UKIQQ77RLUBBBFLA | 1000 | devnet-v33.0 | X4Bl4wQ9rCo= | advice pudding treat near rule blouse same whisper inner electric quit surface sunny dismiss leader blood seat clown cost exist hospital century reform able sponsor | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4MQUPZTA BFRTECKTOOE7A5LHCF3TTEOH2A7BW46IYT2SX5VP6ANKEXHZYJY77SJTVM 47YPQTIGQEO7T4Y4RWDYWEKV6RTR2UNBQXBABEEGM72ESWDQNCQ52OPASU |
