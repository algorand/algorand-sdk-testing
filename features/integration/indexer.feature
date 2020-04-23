@indexer
Feature: Indexer Dataset 1

  For all queries, parameters will not be set for default values as defined by:
  * Numeric inputs: 0
  * String inputs: ""

  Background:
    Given indexer client 1 at "localhost" port 59999 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  #
  # /blocks/{round-number}
  #
  Scenario Outline: /blocks/<number>
    When I use <indexer> to lookup block <number>
    Then The block was confirmed at <timestamp>, contains <num> transactions, has the previous block hash "<hash>"

    Examples:
      | indexer | number | timestamp  | num | hash                                         |
      | 1       | 7      | 1585684086 | 8   | PpPusF+bU/uNLS5ODG/hG0pP0vehdSSlBcnnyZDr770= |
      | 1       | 20     | 1585684138 | 2   | 9jzxFIKLoTGkFl60aqGwyzO0AVyMBnbs/Wb5R9hPrsA= |
      | 1       | 100    | 1585684463 | 0   | rEWRbwgzDagT5wYTf9TuiuC+VR3XLLy4S73vInxkmrA= |

  #
  # /accounts/{account-id}
  #
  Scenario Outline: has asset - /account/<account>
    When I use <indexer> to lookup account "<account>"
    Then The account has <num> assets, the first is asset <index> has a frozen status of "<frozen>" and amount <units>.

    Examples:
      | indexer | account                                                    | num | index | frozen | units        |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 1   | 9     | false  | 999931337000 |
      | 1       | ZBBRQD73JH5KZ7XRED6GALJYJUXOMBBP3X2Z2XFA4LATV3MUJKKMKG7SHA | 1   | 9     | false  | 68663000     |

  Scenario Outline: creator - /account/<account>
    When I use <indexer> to lookup account "<account>"
    Then The account created <num> assets, the first is asset <index> is named "<name>" with a total amount of <total> "<unit>"

    Examples:
      | indexer | account                                                    | num | index | name     | total         | unit |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 1   | 9     | bogocoin | 1000000000000 | bogo |

  Scenario Outline: lookup - /account/<account>
    When I use <indexer> to lookup account "<account>"
    Then The account has <μalgos> μalgos and <num> assets

    Examples:
      | indexer | account                                                    | μalgos           | num |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 999899126000     | 1   |
      | 1       | FROJFIFQRARWEHOL6GR3MBFCDJY76CPF3UY55HM3PCK42AD5HA5SKKXLLA | 4992999999993000 | 0   |

  #
  # /assets/{asset-id}
  #
  Scenario Outline: lookup - /assets/<asset-id>
    When I use <indexer> to lookup asset <asset-id>
    Then The asset found has: "<name>", "<units>", "<creator>", <decimals>, "<default-frozen>", <total>, "<clawback>"

    Examples:
      | indexer | asset-id | name     | units | creator                                                    | decimals | default-frozen | total         | clawback                                                   |
      | 1       | 9        | bogocoin | bogo  | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 0        | false          | 1000000000000 | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 |

  #
  # /assets/{asset-id}/balances
  #
  Scenario Outline: balances - /assets/<asset-id>/balances?gt=<currency-gt>&lt=<currency-lt>&limit=<limit>
    When I use <indexer> to lookup asset balances for <asset-id> with <currency-gt>, <currency-lt>, <limit>
    Then There are <num-accounts> with the asset, the first is "<account>" has "<is-frozen>" and <amount>

    Examples:
      | indexer | asset-id | currency-gt | currency-lt | limit | num-accounts | account                                                    | is-frozen | amount       |
      | 1       | 9        | 0           | 0           | 0     | 2            | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | false     | 999931337000 |
      | 1       | 9        | 0           | 0           | 1     | 1            | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | false     | 999931337000 |
      | 1       | 9        | 0           | 0           | 1     | 1            | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | false     | 999931337000 |
      | 1       | 9        | 68663000    | 0           | 0     | 1            | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | false     | 999931337000 |
      | 1       | 9        | 0           | 68663001    | 0     | 1            | ZBBRQD73JH5KZ7XRED6GALJYJUXOMBBP3X2Z2XFA4LATV3MUJKKMKG7SHA | false     | 68663000     |

  #
  # /accounts
  #
  Scenario Outline: general - /accounts?asset-id=<asset-id>&limit=<limit>&gt=<currency-gt>&lt=<currency-lt>
    When I use <indexer> to search for an account with <asset-id>, <limit>, <currency-gt>, <currency-lt> and token ""
    Then There are <num>, the first has <pending-rewards>, <rewards-base>, <rewards>, <without-rewards>, "<address>", <amount>, "<status>", "<type>"

    Examples:
      | indexer | asset-id | limit | currency-gt | currency-lt | num | pending-rewards | rewards-base | rewards | without-rewards | address                                                    | amount       | status  | type |
  # These changed when adding 'ORDER BY' in the backend
  #| 1       | 0        | 0     | 0           | 0           | 32  | 0               | 0            | 0       | 1000000         | XKWNJ6MDJWB5WEIARTAJI6GMCX3ETHBSM4OZ2NYACFEXHQJ2RHTC4SHH5A | 1000000      | Offline |      |
  #| 1       | 0        | 10    | 0           | 0           | 10  | 0               | 0            | 0       | 1000000         | XKWNJ6MDJWB5WEIARTAJI6GMCX3ETHBSM4OZ2NYACFEXHQJ2RHTC4SHH5A | 1000000      | Offline |      |
      | 1       | 0        | 0     | 0           | 0           | 32  | 0               | 0            | 0       | 0                | A5QNF7MATDBZHXVYROXVZ6WTWMMDGX5RPEUCYAQEINOS3LQUW7NQGUJ4OI | 0           | Offline | lsig |
      | 1       | 0        | 10    | 0           | 0           | 10  | 0               | 0            | 0       | 0                | A5QNF7MATDBZHXVYROXVZ6WTWMMDGX5RPEUCYAQEINOS3LQUW7NQGUJ4OI | 0           | Offline | lsig |
      | 1       | 9        | 0     | 68663000    | 0           | 1   | 0               | 0            | 0       | 999899126000    | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 999899126000 | Offline | sig  |
      | 1       | 9        | 0     | 0           | 68663001    | 1   | 0               | 0            | 0       | 998000          | ZBBRQD73JH5KZ7XRED6GALJYJUXOMBBP3X2Z2XFA4LATV3MUJKKMKG7SHA | 998000       | Offline | lsig |
      | 1       | 0        | 0     | 798999      | 799001      | 1   | 0               | 0            | 0       | 799000          | RRHDAJKO5HQBLHPCVK6K7U54LENDIP2JKM3RNRYX2G254VUXBRQD35CK4E | 799000       | Offline | msig |

  #
  # /accounts - online
  #
  Scenario Outline: online - /accounts?asset-id=<asset-id>&limit=<limit>&gt=<currency-gt>&lt=<currency-lt>
    When I use <indexer> to search for an account with <asset-id>, <limit>, <currency-gt>, <currency-lt> and token ""
    Then The first account is online and has "<address>", <key-dilution>, <first-valid>, <last-valid>, "<vote-key>", "<selection-key>"

    Examples:
      | indexer | asset-id | limit | currency-gt      | currency-lt | address                                                    | key-dilution | first-valid | last-valid | vote-key                                     | selection-key                                |
      | 1       | 0        | 0     | 998999           | 999001      | NNFTUMXU5EMDOSFRGQ55TOGOJIS7P7POIDHJTQNQUBVVYJ6GCIPHOMAMQE | 10000        | 0           | 100        | h0wDwh1yhWiWu0S79wEiQaWXnNLCMjcce5MPeWPRQ/Q= | Ob0jBcHd0uh6nMjls6bOHlissWvPlINGiREJ+gaEOSg= |
  # These changed when adding 'ORDER BY' in the backend
  #| 1       | 0        | 0     | 4992999999992999 | 0           | FROJFIFQRARWEHOL6GR3MBFCDJY76CPF3UY55HM3PCK42AD5HA5SKKXLLA | 10000        | 0           | 3000000    | mQzj8cwerZh1QzdCR9WBteLQ6MQszzLP4MAjSi5wuD4= | NRnpzxRIGUnTICoPloP9eWU1W6OPksR0ReEDRTwzoYg= |
      | 1       | 0        | 0     | 4992999999992999 | 0           | BYP7VVRIBDOOFKEYICNYIM43S6DW7RIZC73XNMKF3KT5YUITDDMH3W5D5Q | 10000        | 0           | 3000000    | 9OO2S7ikfESeDZg8Z9mrzdN2Lh52UBSVH9uD7XqQHhs= | BkTjDJB2Su5Fi9uwJTODkxpEjrhCJSYtF10m0ee6THU= |


  #
  # /accounts - paging
  #
  Scenario Outline: paging - /accounts?asset-id=<asset-id>&limit=<limit>&gt=<currency-gt>&lt=<currency-lt>
    When I use <indexer> to search for an account with <asset-id>, <limit>, <currency-gt>, <currency-lt> and token ""
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then There are <num>, the first has <pending-rewards>, <rewards-base>, <rewards>, <without-rewards>, "<address>", <amount>, "<status>", "<type>"

    Examples:
      | indexer | asset-id | limit | currency-gt | currency-lt | num | pending-rewards | rewards-base | rewards | without-rewards | address                                                    | amount       | status           | type |
      | 1       | 0        | 1     | 0           | 0           | 1   | 0               | 0            | 0       | 149234          | A7NMWS3NT3IUDMLVO26ULGXGIIOUQ3ND2TXSER6EBGRZNOBOUIQXHIBGDE | 149234       | NotParticipating |      |
  # These changed when adding 'ORDER BY' in the backend
  #| 1       | 0        | 10    | 0           | 0           | 10  | 0               | 0            | 0       | 99862000        | M7E3Z6MJ7LZT725IK3ZQ6YE64TUTVU6VPPHFMT3DSD5KRDYRE44BE6GY5A | 99862000     | Offline          | lsig |
      | 1       | 0        | 10    | 0           | 0           | 10  | 0               | 0            | 0       |  999899996766   | LQU5S7HMDXLQUQD5BKIMPPZYK7LYXPC5AVGIWNVNTBVQHL3GCXFVXZFJ3A | 999899996766 | Offline          | sig  |

  #
  # /accounts - paging multiple times
  #
  Scenario Outline: paging 6 times - /accounts?asset-id=<asset-id>&limit=<limit>&gt=<currency-gt>&lt=<currency-lt>
    When I use <indexer> to search for an account with <asset-id>, <limit>, <currency-gt>, <currency-lt> and token ""
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then I get the next page using <indexer> to search for an account with <asset-id>, <limit>, <currency-gt> and <currency-lt>
    Then There are <num>, the first has <pending-rewards>, <rewards-base>, <rewards>, <without-rewards>, "<address>", <amount>, "<status>", "<type>"

    Examples:
      | indexer | asset-id | limit | currency-gt | currency-lt | num | pending-rewards | rewards-base | rewards | without-rewards | address                                                    | amount       | status  | type |
      | 1       | 0        | 1     | 0           | 0           | 1   | 0               | 0            | 0       | 0               | GP44P6YCVSRK4IYIEZYDYO5POY3QO5VTATZIMRI6DFLMO2EPK7GBBNQRCM | 0            | Offline | lsig |
      | 1       | 0        | 2     | 0           | 0           | 2   | 0               | 0            | 0       | 999000          | NNFTUMXU5EMDOSFRGQ55TOGOJIS7P7POIDHJTQNQUBVVYJ6GCIPHOMAMQE | 999000       | Online | sig  |

  #
  # /transactions
  #  When I use <indexer> to search for transactions with <limit>, "<note-prefix>", "<tx-type>", "<sig-type>", "<tx-id>", <round>, <min-round>, <max-round>, <asset-id>, "<before-time>", "<after-time>", <currency-gt>, <currency-lt>, "<address>", "<address-role>", "<exclude-close-to>"  and token "<token>"
  #
  Scenario Outline: /transactions?note-prefix
    When I use <indexer> to search for transactions with 0, "<note-prefix>", "", "", "", 0, 0, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".

    Examples:
      | indexer | note-prefix | num  | txid                                                 |
      | 1       | XQ==        | 2    | TOVLLWKZ4QPKPX4772TOMI3L6QKWMFPI6OFN5CUCSCMBVJONXUEQ |
      | 1       | VA==        | 3    | DWE64HOPXBLDWTD3XL6VCNQSEZTXW2TCLZ6JNMNE5VL5UV67IDDQ |
      | 1       | 1111        | 0    |                                                      |

  Scenario Outline: /transactions?tx-type=<tx-type>
    When I use <indexer> to search for transactions with 0, "", "<tx-type>", "", "", 0, 0, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has tx-type "<tx-type>"

    Examples:
      | indexer | tx-type | num  | txid                                                 |
      | 1       | pay     | 41   | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | keyreg  | 1    | DLMAHOBTYQ4PMUKN4OEOV6VGFOPRASEFJKDROE6BUVB7SGMUDC5A |
      | 1       | acfg    | 1    | 2GMT4WWIYZFDB5MTXNZFOTCWNCSBVKASQNLQ2SDI3ANBCFTVHPCA |
      | 1       | axfer   | 6    | EPACZZGMIXHV3YABCDNXSSZRG7BQX2XNPUHOME2QCUQB4ABG3VSQ |
      | 1       | afrz    | 0    |                                                      |

  Scenario Outline: /transactions?sig-type=<sig-type>
    When I use <indexer> to search for transactions with 0, "", "", "<sig-type>", "", 0, 0, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has sig-type "<sig-type>"

    Examples:
      | indexer | sig-type | num  | txid                                                 |
      | 1       | sig      | 25   | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | lsig     | 24   | BS2A3W2O6GKNLPOYKCTKJO72HJVAKSJKMOFC4AEGOGBL45DVSYFA |
      | 1       | msig     | 0    |                                                      |

  Scenario Outline: /transactions?tx-id=<txid>
    When I use <indexer> to search for transactions with 0, "", "", "", "<txid>", 0, 0, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".

    Examples:
      | indexer | num | txid                                                 |
      | 1       | 0   | DN7MBMCL5JQ3PFUQS7TMX5AH4EEKOBJVDUF4TCV6WERATKFLQF4M |
      | 1       | 1   | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 1   | BS2A3W2O6GKNLPOYKCTKJO72HJVAKSJKMOFC4AEGOGBL45DVSYFA |

  Scenario Outline: /transactions?round=<round>
    When I use <indexer> to search for transactions with 0, "", "", "", "", <round>, 0, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has round <round>

    Examples:
      | indexer | round | num | txid                                                 |
      | 1       | 10    | 2   | FY54CQLUAPJIHEIIG32EX7BMCHCS4LKQVTORIZ2BZ7RPWFR4HDIQ |
      | 1       | 22    | 3   | STLE5SLDUVKBVCMNCWXQ32QBC43YGFFJTQVCT3QSAG6MP6P3OB2A |
      | 1       | 30    | 2   | SLEJ5ELZR6734TDSOPRNXFZTUIS6TTF3H433SSPIDBXVV6POFPHQ |

  Scenario Outline: /transactions?min-round=<min-round>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, <min-round>, 0, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has round >= <min-round>

    Examples:
      | indexer | min-round | num | txid                                                 |
      | 1       | 10        | 25  | FY54CQLUAPJIHEIIG32EX7BMCHCS4LKQVTORIZ2BZ7RPWFR4HDIQ |
      | 1       | 22        | 10  | STLE5SLDUVKBVCMNCWXQ32QBC43YGFFJTQVCT3QSAG6MP6P3OB2A |
      | 1       | 30        | 2   | SLEJ5ELZR6734TDSOPRNXFZTUIS6TTF3H433SSPIDBXVV6POFPHQ |

  Scenario Outline: /transactions?max-round=<max-round>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, <max-round>, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has round <= <max-round>

    Examples:
      | indexer | max-round | num | txid                                                 |
      | 1       | 10        | 26  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 22        | 42  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 30        | 49  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |


  Scenario Outline: /transactions?max-round=<max-round>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, <max-round>, 0, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction has round <= <max-round>

    Examples:
      | indexer | max-round | num | txid                                                 |
      | 1       | 10        | 26  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 22        | 42  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 30        | 49  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |

  Scenario Outline: /transactions?asset-id=<asset-id>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, <asset-id>, "", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction works with asset-id <asset-id>

    Examples:
      | indexer | asset-id | num | txid                                                 |
      | 1       | 9        | 7   | 2GMT4WWIYZFDB5MTXNZFOTCWNCSBVKASQNLQ2SDI3ANBCFTVHPCA |

  Scenario Outline: /transactions?before-time=<before>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, 0, "<before>", "", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction is older than "<before>"

    Examples:
      | indexer | before               | num | txid                                                 |
      | 1       | 2020-03-31T19:47:49Z | 0   |                                                      |
      | 1       | 2020-03-31T19:48:49Z | 35  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 2021-03-31T19:47:49Z | 49  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |

  Scenario Outline: /transactions?after-time=<after>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, 0, "", "<after>", 0, 0, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction is newer than "<after>"

    Examples:
      | indexer | after                | num | txid                                                 |
      | 1       | 2019-01-01T01:01:01Z | 49  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 2020-03-31T19:48:49Z | 14  | 3NL6W7SVU2FEPVCB773OZFFJYUGINF7EYBGJBIDFOZZBDVPHPF5Q |
      | 1       | 2029-01-01T01:01:01Z | 0   |                                                      |

  Scenario Outline: /transactions?currency-gt=<currency-gt>&currency-lt=<currency-lt>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, 0, "", "", <currency-gt>, <currency-lt>, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction moves between <currency-gt> and <currency-lt> currency

    Examples:
      | indexer | currency-gt | currency-lt | num | txid                                                 |
      | 1       | 0           | 10          | 2   | EKC5XZ6J2NN3APZABUOTFEXVHXMKZKUXTF4NFV625OLRTEKYH46Q |
      | 1       | 1           | 0           | 34  | 4M3TJFAN4RSZF6O5OI2KKX3IQGCH36MH7KVT27PVGJITW5ZN4AHQ |
      | 1       | 10000       | 1000000     | 2   | WEUXWWPN7LBKS276Q7G4FBJMD5BZAHWBFUFFIE6ZV52QDLPPE7HA |

  Scenario Outline: /transactions?asset-id=<asset-id>&currency-gt=<currency-gt>&currency-lt=<currency-lt>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, <asset-id>, "", "", <currency-gt>, <currency-lt>, "", "", "" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".
    And Every transaction moves between <currency-gt> and <currency-lt> currency

    Examples:
      | indexer | asset-id | currency-gt | currency-lt | num | txid                                                 |
      | 1       | 9        | 1           | 0           | 3   | ZDYUHC4VSMTO4P747JXPAWXIP55QJXUMBW6LKNNC2TTFCC6VHNEQ |
      | 1       | 9        | 0           | 100000000   | 2   | ZDYUHC4VSMTO4P747JXPAWXIP55QJXUMBW6LKNNC2TTFCC6VHNEQ |
      | 1       | 9        | 1000000     | 100000000   | 1   | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |

  Scenario Outline: account filter /transactions?address=<address>&address-role=<address-role>&exclude-close-to=<exclude-close-to>
    When I use <indexer> to search for transactions with 0, "", "", "", "", 0, 0, 0, 0, "", "", 0, 0, "<address>", "<address-role>", "<exclude-close-to>" and token ""
    Then there are <num> transactions in the response, the first is "<txid>".

  Examples:
  | indexer | address                                                    | address-role | exclude-close-to | num | txid                                                 |
  | 1       | TFZP2BHL7LZ4ZLN7FGW2EN5V23DNMYWPIMN55ASNY2FEGM66STNSBMFKSA |              |                  | 8   | MH2GOC765TAK6UKEH6TDJ42QWTB4W46S4W3WI2QWNQ5VWHMXCIMQ |
  | 1       | TFZP2BHL7LZ4ZLN7FGW2EN5V23DNMYWPIMN55ASNY2FEGM66STNSBMFKSA | sender       |                  | 6   | MH2GOC765TAK6UKEH6TDJ42QWTB4W46S4W3WI2QWNQ5VWHMXCIMQ |
  | 1       | TFZP2BHL7LZ4ZLN7FGW2EN5V23DNMYWPIMN55ASNY2FEGM66STNSBMFKSA | receiver     |                  | 2   | ZITQV77OVTA6EIONROACGBG3UMJAIBUMURJEQIB5DIXLPQAQOXFA |
  | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 |              |                  | 13  | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |
  | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | receiver     |                  | 6   | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |
  | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | receiver     | true             | 3   | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |
  | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | sender       |                  | 7   | QTAOMHCLPBLWX6OB7Y3TNLCA5XS23U53MCFZG6MKI535BLNQAI4Q |

  #
  # /accounts/{account-id}/transactions - same as /transactions but the validation just ensures that all results include the specified account
  #
  Scenario Outline: /accounts/<account-id>/transactions
    When I use <indexer> to search for all "<account-id>" transactions
    Then there are <num> transactions in the response, the first is "<txid>".

  Examples:
    | indexer | account-id                                                 | num | txid                                                 |
    | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 13  | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |
    | 1       | ZBBRQD73JH5KZ7XRED6GALJYJUXOMBBP3X2Z2XFA4LATV3MUJKKMKG7SHA | 4   | IYKCAANQMJETV5FAYGVB2U5MEP7SP6IOV652DNCBR2EKOSTETRQA |


  #
  # /assets/{asset-id}/transactions - same as /transactions but the validation just ensures that all results are asset xfer's for the specified asset.
  #
  Scenario Outline: /assets/<asset-id>/transactions
    When I use <indexer> to search for all <asset-id> asset transactions
    Then there are <num> transactions in the response, the first is "<txid>".

    Examples:
      | indexer | asset-id | num | txid                                                 |
      | 1       | 9        | 7   | 2GMT4WWIYZFDB5MTXNZFOTCWNCSBVKASQNLQ2SDI3ANBCFTVHPCA |

  #
  # /assets
  #

  #
  # /accounts - at round (rollback test)
  #

  # Rollback tests
  #  - account
  #  - others?

  # Paging tests:
  #  - transactions
  #  - assets
  #  - asset balances?
  #  - accounts (done)

  # Error/edge cases (mixed up min/max, ...?)
  #  - No results
  #  - Invalid parameters (invalid enum)
  #  - Mixed up min/max
