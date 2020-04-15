@indexer
Feature: Indexer Dataset 1
  Background:
    Given indexer client 1 at "localhost" port 59999 with token "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  Scenario Outline: /blocks/<number>
    When I request block <number> with indexer <indexer>
    Then The block was confirmed at <timestamp>, contains <num> transactions, has the previous block hash "<hash>"

    Examples:
      | indexer | number | timestamp  | num | hash                                         |
      | 1       | 7      | 1585684086 | 8   | PpPusF+bU/uNLS5ODG/hG0pP0vehdSSlBcnnyZDr770= |
      | 1       | 20     | 1585684138 | 2   | 9jzxFIKLoTGkFl60aqGwyzO0AVyMBnbs/Wb5R9hPrsA= |
      | 1       | 100    | 1585684463 | 0   | rEWRbwgzDagT5wYTf9TuiuC+VR3XLLy4S73vInxkmrA= |

  Scenario Outline: /account/<account> (has asset)
    When I lookup account "<account>" with <indexer>
    Then The account has <num> assets, asset <index> has a frozen status of "<frozen>" and amount <units>.

    Examples:
      | indexer | account                                                    | num | index | frozen | units        |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 1   | 9     | false  | 999931337000 |
      | 1       | ZBBRQD73JH5KZ7XRED6GALJYJUXOMBBP3X2Z2XFA4LATV3MUJKKMKG7SHA | 1   | 9     | false  | 68663000     |

  Scenario Outline: /account/<account> (asset creator)
    When I lookup account "<account>" with <indexer>
    Then The account created <num> assets, asset <index> is named "<name>" with a total amount of <total> "<unit>"

    Examples:
      | indexer | account                                                    | num | index | name     | total         | unit |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 1   | 9     | bogocoin | 1000000000000 | bogo |

  Scenario Outline: /account/<account>
    When I lookup account "<account>" with <indexer>
    Then The account has <μalgos> μalgos and <num> assets

    Examples:
      | indexer | account                                                    | μalgos           | num |
      | 1       | OSY2LBBSYJXOBAO6T5XGMGAJM77JVPQ7OLRR5J3HEPC3QWBTQZNWSEZA44 | 999899126000     | 1   |
      | 1       | FROJFIFQRARWEHOL6GR3MBFCDJY76CPF3UY55HM3PCK42AD5HA5SKKXLLA | 4992999999993000 | 0   |
