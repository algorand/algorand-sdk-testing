@unit.atomic_transaction_composer
@unit
Feature: Atomic Transaction Composer
  Background:
    Given a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

  Scenario Outline: Method call construction and signing
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Prepare a TransactionSigner
    When I make a transaction signer for the signing account.
    # Create a method call with an address argument, and add it to the composer
    And I create the Method object from method signature "<method-signature>"
    # Prepare method call arguments
    And I create a new method arguments array.
    And I append the encoded arguments "<app-args>" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | app-id | method-signature                                                                                                          | app-args                                                                                                                                                                                                                         | goldens                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
      | 1      | add(uint64,uint64)uint64                                                                                                  | AAAAAAAAAAE=,AAAAAAAAAAE=                                                                                                                                                                                                        | gqNzaWfEQMVxDN20jOKxnGvKJ3VGpYcMC+2aplj9ui5c6iXVemem63F62RpXj4pM2yY5BOB9/YZL2OoosRqPoynVRtm/bwKjdHhuiaRhcGFhk8QE/mvfacQIAAAAAAAAAAHECAAAAAAAAAABpGFwaWQBo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs                                                                                                                                         |
      | 1      | empty()void                                                                                                               |                                                                                                                                                                                                                                  | gqNzaWfEQDFR7lMtnCc83aW465p3xQszFqixlQsuBGpnAtKvgy5iBfkJSK3rGAErs22t1OT9ZYjNtppEbRlpzNNDCSKRmg2jdHhuiaRhcGFhkcQEqIwmpaRhcGlkAaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==                                                                                                                                                                 |
      | 3      | boolArgs(bool[])void                                                                                                      | AAqswA==                                                                                                                                                                                                                         | gqNzaWfEQB7BJ5U66CPqYqSqc+vzdNFyYaYg2bsOA6luFZjhmU+pPkD4B6L9blGiujvkj5WKCia7geP9XqjaqxH8eHHN/QSjdHhuiaRhcGFhksQErS5OfsQEAAqswKRhcGlkA6NmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==                                                                                                                                                         |
      | 20     | fifteenArgs(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)void | AAFh,AAFi,AAFj,AAFk,AAFl,AAFm,AAFn,AAFo,AAFp,AAFq,AAFr,AAFs,AAFt,AAFu,AAFv                                                                                                                                                       | gqNzaWfEQLUSzQ0dMWAKx4/R+NhVB8PHnevmzV4nNLWhK7B45Jj4gV3c8L0nsw+xsb8Q6nHHnJJmGLGkuZPQdt3wMWMnNwOjdHhuiaRhcGFh3AAQxAQR2I2HxAMAAWHEAwABYsQDAAFjxAMAAWTEAwABZcQDAAFmxAMAAWfEAwABaMQDAAFpxAMAAWrEAwABa8QDAAFsxAMAAW3EAwABbsQDAAFvpGFwaWQUo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs                                                             |
      | 20     | sixteenArgs(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void          | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==                                                                                                                                                  | gqNzaWfEQMpLr6nbJj+m2Wvvq90UXdYxn1i7CDwCVIr43YT/xxUy8H5MHStSnwIfQRAgwG91gsxN1mugk/aRNhm2nYZEvA+jdHhuiaRhcGFh3AAQxATidT9cxAEAxAEBxAECxAEDxAEExAEFxAEGxAEHxAEIxAEJxAEKxAELxAEMxAENxAIOD6RhcGlkFKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==                                                                                                 |
      | 20     | accountArgs(account,account,account,address,account)void                                                                  | WygnxOc7ALlIIsdm4zPiq5ZiQM+FRZDXg8QOrncK260=,CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0=,WygnxOc7ALlIIsdm4zPiq5ZiQM+FRZDXg8QOrncK260=,CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0=,fGi1Nk3Vn4xImkRXiz0TDlLgF2a7toSZQ92/BFskmos= | gqNzaWfEQAU/SKxm16OtBEJ3THxmGl0479yDsG7XyQbknuY7BxfjnJtuBxQnbm5JW/uX+5jXUADi+JCwjA3EhHwu65MZMACjdHhuiqRhcGFhlsQEjNMCh8QBAcQBAMQBAcQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f3EAQKkYXBhdJLEIFsoJ8TnOwC5SCLHZuMz4quWYkDPhUWQ14PEDq53CtutxCB8aLU2TdWfjEiaRFeLPRMOUuAXZru2hJlD3b8EWySai6RhcGlkFKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 20     | appArgs(application,application,uint64,application,application)void                                                       | AB////////8=,AAAAAAAAArw=,AAAAAAAAABQ=,AAAAAAAAABQ=,AAAAAAAAArw=                                                                                                                                                                 | gqNzaWfEQC/v+Hm+QoC6z6jKsFxTXCGRGmvmzmnX64ENDVXXDXxZpRVs+7svbh1ReOveuD3z/KYNO2mAC+Y99NtQt/FtJwyjdHhuiqRhcGFhlsQETRzPlMQBAcQBAsQIAAAAAAAAABTEAQDEAQKkYXBmYZLPAB/////////NArykYXBpZBSjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw=                                                                                                             |
      | 20     | assetArgs(asset,uint64,asset,asset,asset,asset)void                                                                       | AAAAAAAAAAc=,AAAAAAAAAAg=,AAAAAAAAAAg=,AAAAAAAAAAk=,AAAAAAAAAAk=,AB////////8=                                                                                                                                                    | gqNzaWfEQF7tHkJa/ZtxEoQVTRmZzHBWXtX0RlebnUkbABSuNv259w93HLu9Gl6QayW7LIUcbOfD/Bd0VvtNBuN5RQ/p2QijdHhuiqRhcGFhl8QEuMy5O8QBAMQIAAAAAAAAAAjEAQHEAQLEAQLEAQOkYXBhc5QHCAnPAB////////+kYXBpZBSjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw=                                                                                                         |

  Scenario Outline: Method call creation construction and signing
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    And an application id 0
    When I make a transaction signer for the signing account.
    And I create the Method object from method signature "create(uint64)uint64"
    And I create a new method arguments array.
    And I append the encoded arguments "AAAAAAAAAAQ=" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "<on-complete>", current transaction signer, current method arguments, approval-program "programs/zero.teal.tok", clear-program "programs/one.teal.tok", global-bytes 2, global-ints 3, local-bytes 4, local-ints 5, extra-pages 1.
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | on-complete | goldens                                                                                                                                                                                                                                                                                                                                                                                          |
      | noop        | gqNzaWfEQEdsO0c7dmuFLDqdc1cGteNnAWh0gFhXXTtBTRYWClahGJ8v1zxJGJ9blWNfFIP8JCRiPnBHocBSIecVKTx4bQ6jdHhujaRhcGFhksQEQ0ZBAcQIAAAAAAAAAASkYXBhcMQFAiABACKkYXBlcAGkYXBnc4KjbmJzAqNudWkDpGFwbHOCo25icwSjbnVpBaRhcHN1xAUCIAEBIqNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==         |
      | optin       | gqNzaWfEQBRX+Mk8mUzTD+g6lIdA9F+9vxEbV7NmENNxIstwuHgnBXhG3bM2w/fdKSKvy5RrCwMZVq8L2NQxMTvAU1qS2gejdHhujqRhcGFhksQEQ0ZBAcQIAAAAAAAAAASkYXBhbgGkYXBhcMQFAiABACKkYXBlcAGkYXBnc4KjbmJzAqNudWkDpGFwbHOCo25icwSjbnVpBaRhcHN1xAUCIAEBIqNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | delete      | gqNzaWfEQLxlqhy12zkcCO1PBragfYqPx5aD90HKM/9vKx3uA4sgD9Rl7nVoeNAWA0axWwqkMJPyIzr3m2++KB2ujuiqdwWjdHhujqRhcGFhksQEQ0ZBAcQIAAAAAAAAAASkYXBhbgWkYXBhcMQFAiABACKkYXBlcAGkYXBnc4KjbmJzAqNudWkDpGFwbHOCo25icwSjbnVpBaRhcHN1xAUCIAEBIqNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | update      | gqNzaWfEQE5k1S2terPuVH+dyngc5UhfmqM8weLwgR9Tsn7r2DFhY5PrZSyOxdTp6g/wu5Qz0/5jV2b+R5mqBiXwaZ+TUgCjdHhujqRhcGFhksQEQ0ZBAcQIAAAAAAAAAASkYXBhbgSkYXBhcMQFAiABACKkYXBlcAGkYXBnc4KjbmJzAqNudWkDpGFwbHOCo25icwSjbnVpBaRhcHN1xAUCIAEBIqNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |

  Scenario Outline: Method call with pay txn construction and signing
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the signing account.
    And I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 100001, close remainder to ""
    And I create a transaction with signer with the current transaction.
    # Create a method call with an address argument, and add it to the composer
    And I create the Method object from method signature "<method-signature>"
    # Prepare method call arguments
    And I create a new method arguments array.
    And I append the current transaction with signer to the method arguments array.
    And I append the encoded arguments "<app-args>" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | app-id | method-signature         | app-args                                     | goldens                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | 1      | payment(pay,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gqNzaWfEQCv0jOhwTJjQfJ9KXm6SJdeGAFea7brEq0BbwBDVMA577Rx3rooi9Ck/ZnExT66+a/kJpUGoPcjdrZoR7QLHHQSjdHhuiqNhbXTOAAGGoaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIN9TXFmEUnoCj+aTGTY6FrNbiCumYIoSgBhMZBZ1/HwOomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQDujKdRruRn6Xg46ZPBIfnL6eooQBqwTRyt9s05bDnc9I3NNqK7SBTuzKcvMes5PTbHxUw/GaNRbQo750PTtCgGjdHhuiqRhcGFhksQEU1pHusQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kYXBpZAGjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCDfU1xZhFJ6Ao/mkxk2OhazW4grpmCKEoAYTGQWdfx8DqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 1      | generic(txn,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gqNzaWfEQFBnvjwMoQIWkk2JR+C7k7ou4sE7zlq++gOuAkS/FgMorWgaeBAZNVqIAiTITgp7j7SapfH2xn69HIkOWcoH2ASjdHhuiqNhbXTOAAGGoaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIJCQOjaegEcO1s8vPYqjhmiznNDzK2bTS69N0szpuG3pomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQKDNV+SD1s4XFzAhjHuWz8az7kolH7JQJG7BfrzMVAeD9DXmAPcA+M9yJdx/ZKoBVlEv4N5O+BM5tk0WzjW+/Q+jdHhuiqRhcGFhksQEWsMy4cQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kYXBpZAGjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCCQkDo2noBHDtbPLz2Ko4Zos5zQ8ytm00uvTdLM6bht6aJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |

  Scenario Outline: Method call with multiple pay txns construction and signing
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    # Save an application id so we can test method calls
    And an application id <app-id>
    # Create a pay transaction, create a TransactionSigner, and add it to the composer
    When I make a transaction signer for the signing account.
    And I create the Method object from method signature "<method-signature>"
    And I create a new method arguments array.

    And I append the encoded arguments "<app-args-part-1>" to the method arguments array.

    And I build a payment transaction with sender "5WSFXNXLZGIRSSY6R4UGMHJSHKKW3NDZ2WXCOXZVG5HMQ4P7HN4PGLD7LY", receiver "EJMBXTBD4BO27OC3OFFMX4D4WF5LMZROBE6X4QSW5I7VSM74KZHVUWKOAA", amount 100000, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I append the current transaction with signer to the method arguments array.

    And I append the encoded arguments "<app-args-part-2>" to the method arguments array.

    And I build a payment transaction with sender "EJMBXTBD4BO27OC3OFFMX4D4WF5LMZROBE6X4QSW5I7VSM74KZHVUWKOAA", receiver "5WSFXNXLZGIRSSY6R4UGMHJSHKKW3NDZ2WXCOXZVG5HMQ4P7HN4PGLD7LY", amount 200000, close remainder to "IO4SUZWSUQZBKIC4PMJJXSZS53IBD3LED75OT5W32HSHC3JASJKQNLUQDY"
    And I create a transaction with signer with the current transaction.
    And I append the current transaction with signer to the method arguments array.

    And I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.
    # Build the group in the composer
    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    # Try signing and compare the golden with the signed transaction
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "<goldens>"

    Examples:
      | app-id | method-signature                        | app-args-part-1 | app-args-part-2 | goldens                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | 5      | payment(uint64,pay,uint8,pay)bool       | AAAAAAAAE4g=    | CA==            | g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQFgXcrfqlqPMkUpF7NNtiUraAzBu/hRY1U8qQh6MdNztPAAB50uvmTtzIedFGe3dfEgx9lgsb+xal+k0ovV4RwejdHhuiqNhbXTOAAGGoKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIPflivpHZbXTSM8skvY8aHBV1dQQ5SvbnpSCevRaHupNomx2zSMyo3JjdsQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+jc25kxCDtpFu268mRGUsejyhmHTI6lW20edWuJ181N07Icf87eKR0eXBlo3BheQ==,g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQBLdTaZDeN2HnuWAmTErSuNYllUZZ6D5xakLGv9nesuAUnX38bEqqEioOiHU3bksxzo3a+t6aIgtgMokFcJrzwOjdHhui6NhbXTOAAMNQKVjbG9zZcQgQ7kqZtKkMhUgXHsSm8sy7tAR7WQf+un229HkcW0gklWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCD35Yr6R2W100jPLJL2PGhwVdXUEOUr256Ugnr0Wh7qTaJsds0jMqNyY3bEIO2kW7bryZEZSx6PKGYdMjqVbbR51a4nXzU3Tshx/zt4o3NuZMQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+kdHlwZaNwYXk=,gqNzaWfEQBrbSBf2FI7vMCRIxMXfBC0TH2mm2f+mn6hBl25BZNxh6qlFTYb+yCJsOi4HiRl47emzjcp9vy2dwAENMoZVLwOjdHhuiqRhcGFhk8QEkASID8QIAAAAAAAAE4jEAQikYXBpZAWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCD35Yr6R2W100jPLJL2PGhwVdXUEOUr256Ugnr0Wh7qTaJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 5      | generic(uint64,txn,uint8,txn)bool       | AAAAAAAAE4k=    | CQ==            | g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQAEJFAwoxMwLqDE3KGrGmKRei2a9pfDgWjB2LH5vkrgIGcjPTy6r0YU36UpVHFNq5U6tuS8pNdHV448gDzDT2AGjdHhuiqNhbXTOAAGGoKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIDyrzDbT+YwsSw8y4Wss7f7dkN9Y/bnPI6FW+AIsRcpuomx2zSMyo3JjdsQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+jc25kxCDtpFu268mRGUsejyhmHTI6lW20edWuJ181N07Icf87eKR0eXBlo3BheQ==,g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQCt8u+Q+MqFH8K0fjgFzKVwGMcgqh5o1+BIA4G+GSqT9SZ1k3WxdRzwlobm75QsmJZ/aXcbbJ+B0c+jc8GqZggyjdHhui6NhbXTOAAMNQKVjbG9zZcQgQ7kqZtKkMhUgXHsSm8sy7tAR7WQf+un229HkcW0gklWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCA8q8w20/mMLEsPMuFrLO3+3ZDfWP25zyOhVvgCLEXKbqJsds0jMqNyY3bEIO2kW7bryZEZSx6PKGYdMjqVbbR51a4nXzU3Tshx/zt4o3NuZMQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+kdHlwZaNwYXk=,gqNzaWfEQPgC6qWsD+UaIZzEDbqzFX+FTghgMMT6USEkpCvvbJu8ichVHOcnz6EGQD0mRzL1KG2rbnSmq+Hu7iclOmt2vQejdHhuiqRhcGFhk8QEtOUqucQIAAAAAAAAE4nEAQmkYXBpZAWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCA8q8w20/mMLEsPMuFrLO3+3ZDfWP25zyOhVvgCLEXKbqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 5      | payAndGeneric(uint64,pay,uint8,txn)bool | AAAAAAAAE4o=    | Cg==            | g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQLy/8gtihLP8soAaW8siuOcsLFgEI8DXCrUG6SSTutOWAe6pLBZ6Pa0uLzBctr9TIh6w5MS3Ijcp75W3cFSBMgSjdHhuiqNhbXTOAAGGoKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIPOPvzxTdmRI6afu0TjG7FKBqUCwAp4KuOW/Q20O/mRfomx2zSMyo3JjdsQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+jc25kxCDtpFu268mRGUsejyhmHTI6lW20edWuJ181N07Icf87eKR0eXBlo3BheQ==,g6RzZ25yxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aNzaWfEQNnEcRFJydgyg/8QcyNxsJ+O6yBNZf9gZxTSSXOvyDE2xxXyMUgYTHZsbbJrY2y/bFr0OjpN+RHNaAEC97zWJwOjdHhui6NhbXTOAAMNQKVjbG9zZcQgQ7kqZtKkMhUgXHsSm8sy7tAR7WQf+un229HkcW0gklWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCDzj788U3ZkSOmn7tE4xuxSgalAsAKeCrjlv0NtDv5kX6Jsds0jMqNyY3bEIO2kW7bryZEZSx6PKGYdMjqVbbR51a4nXzU3Tshx/zt4o3NuZMQgIlgbzCPgXa+4W3FKy/B8sXq2Zi4JPX5CVuo/WTP8Vk+kdHlwZaNwYXk=,gqNzaWfEQMLPXHFcI9kxHRviIqISoQ+1QtdO8BXo3MlbniTENAxd5o7rVoV3yYHwDDzu/lCf6dlDY0S9HBfRfEtegRXDPQajdHhuiqRhcGFhk8QE/QlBR8QIAAAAAAAAE4rEAQqkYXBpZAWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCDzj788U3ZkSOmn7tE4xuxSgalAsAKeCrjlv0NtDv5kX6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |

  Scenario: Multiple method calls construction and signing
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    And an application id 5
    When I make a transaction signer for the signing account.

    # optIn(string)string
    And I create the Method object from method signature "optIn(string)string"
    And I create a new method arguments array.
    And I append the encoded arguments "AAxBbGdvcmFuZCBGYW4=" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "optin", current transaction signer, current method arguments.

    # payment(pay,uint64)bool
    And I create the Method object from method signature "payment(pay,uint64)bool"
    And I create a new method arguments array.
    And I build a payment transaction with sender "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", receiver "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4", amount 1234567, close remainder to ""
    And I create a transaction with signer with the current transaction.
    And I append the current transaction with signer to the method arguments array.
    And I append the encoded arguments "AAAAAAAS1oc=" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # add(uint64,uint64)uint64
    When I create the Method object from method signature "add(uint64,uint64)uint64"
    And I create a new method arguments array.
    And I append the encoded arguments "AAAAAAAAAAE=,AAAAAAAAAAI=" to the method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments.

    # closeOut()string
    And I create the Method object from method signature "closeOut()string"
    And I create a new method arguments array.
    And I add a method call with the signing account, the current application, suggested params, on complete "closeout", current transaction signer, current method arguments.

    And I build the transaction group with the composer. If there is an error it is "".
    Then The composer should have a status of "BUILT".
    And I gather signatures with the composer.
    Then The composer should have a status of "SIGNED".
    And the base64 encoded signed transactions should equal "gqNzaWfEQKVD98rzjJ6etlT65/tJwTxuL5d4ryZAi0HQvugm4BFcTFh8EJMwMu0WuK3nJCI8V12z71zu2FfHZr2gfASS1QSjdHhui6RhcGFhksQEz6aONsQOAAxBbGdvcmFuZCBGYW6kYXBhbgGkYXBpZAWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCAIaNQsXGAGnBByjytsa+evka/YMnDx4NvfNjbTn+11pqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==,gqNzaWfEQPyojeHXIbbeE4+8qClaYNwsKE32C842NbrTDPZQybLilzwXlKJM2dW36ZbqXJYVBykaar4qahk9Nz1fJeJeugqjdHhuiqNhbXTOABLWh6NmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIAho1CxcYAacEHKPK2xr56+Rr9gycPHg2982NtOf7XWmomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQObtQ7AzmAv+ZNSP066lypBvHwpdub1ckAT08J5Lcfz0r+Z/aREWiOVmsf2mic9wf6c73rLHzS/OmbL3py9/XgSjdHhuiqRhcGFhksQEPjs9KMQIAAAAAAAS1oekYXBpZAWjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCAIaNQsXGAGnBByjytsa+evka/YMnDx4NvfNjbTn+11pqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA==,gqNzaWfEQBrZuzcWAiEw8icgD3J9FmU8J91UENqp2wSmA+4AAnIlzoiGJm/fn6HkYbdhvFlLcnIaFI4hm2IYCnmfcVVCWAejdHhuiqRhcGFhk8QE/mvfacQIAAAAAAAAAAHECAAAAAAAAAACpGFwaWQFo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDo2dycMQgCGjULFxgBpwQco8rbGvnr5Gv2DJw8eDb3zY205/tdaaibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw=,gqNzaWfEQBs7mtW7Xj6mY73M32nAUveeRuBX7FCAci3JYwf4iy6Mmjxkh8xScm11e+pqiojf9MeG26ZigrdqJH/4wP9pHA+jdHhui6RhcGFhkcQEqfQrPaRhcGFuAqRhcGlkBaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIAho1CxcYAacEHKPK2xr56+Rr9gycPHg2982NtOf7XWmomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs"

  Scenario: Initial status
    Given a new AtomicTransactionComposer
    Then The composer should have a status of "BUILDING".

  Scenario: Build with 0 transactions fails
    Given a new AtomicTransactionComposer
    When I build the transaction group with the composer. If there is an error it is "zero group size error".
    Then The composer should have a status of "BUILDING".
  
  @unit.atc_method_args
  Scenario Outline: Method call argument count validation
    Given a new AtomicTransactionComposer
    And suggested transaction parameters fee 1234, flat-fee "true", first-valid 9000, last-valid 9010, genesis-hash "Mf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464M=", genesis-id "cucumbernet"
    And I make a transaction signer for the signing account.
    And an application id 42
    When I create the Method object from method signature "<method-signature>"
    And I create a new method arguments array.
    And I append the encoded arguments "<app-args>" to the method arguments array.
    # When "none" is provided for <none-or-exception-pattern> there should be no exception, otherwise, the error's message should satisfy the regex:
    Then I add a method call with the signing account, the current application, suggested params, on complete "noop", current transaction signer, current method arguments; any resulting exception has key "<none-or-exception-key>".

    Examples:
      | method-signature                                                                                                  | app-args                                                                                   | none-or-exception-key     |
      | add(uint64,uint64)uint64                                                                                          | AAAAAAAAAAE=,AAAAAAAAAAI=                                                                  | none                      |
      | empty()void                                                                                                       |                                                                                            | none                      |
      | f15(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)void | AAFh,AAFi,AAFj,AAFk,AAFl,AAFm,AAFn,AAFo,AAFp,AAFq,AAFr,AAFs,AAFt,AAFu,AAFv                 | none                      |
      | f16(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void          | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==            | none                      |
      | f17(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void    | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==,Dw==       | none                      |
      | add(uint64,uint64)uint64                                                                                          | AAAAAAAAAAE=,AAAAAAAAAAI=,AAAAAAAAAAI=                                                     | argument_count_mismatch   |
      | add(uint64,uint64)uint64                                                                                          | AAAAAAAAAAE=                                                                               | argument_count_mismatch   |
      | empty()void                                                                                                       | AAAAAAAAAAE=                                                                               | argument_count_mismatch   |
      | f15(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)void | AAFh,AAFi,AAFj,AAFk,AAFl,AAFm,AAFn,AAFo,AAFp,AAFq,AAFr,AAFs,AAFt,AAFu                      | argument_count_mismatch   |
      | f15(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)void | AAFh,AAFi,AAFj,AAFk,AAFl,AAFm,AAFn,AAFo,AAFp,AAFq,AAFr,AAFs,AAFt,AAFu,AAFu,AAFu            | argument_count_mismatch   |
      | f16(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void          | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==                 | argument_count_mismatch   |
      | f16(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void          | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==,Dw==       | argument_count_mismatch   |
      | f17(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void    | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==                 | argument_count_mismatch   |
      | f17(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void    | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==            | argument_count_mismatch   |
      | f17(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void    | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==,Dw==,Dw==  | argument_count_mismatch   |
