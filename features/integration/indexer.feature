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
  #
  Scenario Outline: note prefix - /transactions
  #  When I use <indexer> to search for transactions with <limit>, "<note-prefix>", "<tx-type>", "<sig-type>", "<tx-id>", <round>, <min-round>, <max-round>, <asset-id>, "<before-time>", "<after-time>", <currency-gt>, <currency-lt>, "<address>", "<address-role>", "<exclude-close-to>"  and token "<token>"
    When I use <indexer> to search for transactions with 0, "<note-prefix>", "", "", "", 0, 0, 0, 0, "", "", 0, 0, "", "", ""  and token ""

  Examples:
  | indexer | note-prefix |
  | 1       | V           |

# all the fixins
#  Scenario Outline: note prefix - /transactions
#  #  When I use <indexer> to search for transactions with <limit>, "<note-prefix>", "<tx-type>", "<sig-type>", "<tx-id>", <round>, <min-round>, <max-round>, <asset-id>, "<before-time>", "<after-time>", <currency-gt>, <currency-lt>, "<address>", "<address-role>", "<exclude-close-to>"  and token "<token>"
#    When I use <indexer> to search for transactions with <limit>, "<note-prefix>", "<tx-type>", "<sig-type>", "<tx-id>", <round>, <min-round>, <max-round>, <asset-id>, "<before-time>", "<after-time>", <currency-gt>, <currency-lt>, "<address>", "<address-role>", "<exclude-close-to>"  and token "<token>"
#
#  Examples:
#  | indexer | limit | note-prefix | tx-type | sig-type | tx-id | round | min-round | max-round | asset-id | before-time | after-time | currency-gt | currency-lt | address | address-role | exclude-close-to |
#  | 1       | 0     |             |         |          |       | 0     | 0         | 0         | 0        |             |            | 0           | 0           |         |              |                  |

  # All the fixins
  #| indexer | limit | note-prefix | tx-type | sig-type | tx-id | round | min-round | max-round | asset-id | before-time | after-time | currency-gt | currency-lt | address | address-role | exclude-close-to | token |


  #
  # /accounts/{account-id}/transactions - same as /transactions but the validation just ensures that all results include the specified account
  #

  #
  # /assets/{asset-id}/transactions - same as /transactions but the validation just ensures that all results are asset xfer's for the specified asset.
  #

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
  #  - Invalid parameters, mixed up min/max