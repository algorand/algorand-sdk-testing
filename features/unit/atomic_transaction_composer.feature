@unit.atomic_transaction_composer
@unit
Feature: Atomic Transaction Composer
  Background:
    Given an algod v2 client
    And a signing account with address "BH55E5RMBD4GYWXGX5W5PJ5JAHPGM5OXKDQH5DC4O2MGI7NW4H6VOE4CP4" and mnemonic "awful drop leaf tennis indoor begin mandate discover uncle seven only coil atom any hospital uncover make any climb actor armed measure need above hundred"

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
      | app-id | method-signature                                                                                                          | app-args                                                                                                                                                                                                                         | goldens |
      | 1      | add(uint64,uint64)uint64                                                                                                  | AAAAAAAAAAE=,AAAAAAAAAAE=                                                                                                                                                                                                        | gqNzaWfEQMVxDN20jOKxnGvKJ3VGpYcMC+2aplj9ui5c6iXVemem63F62RpXj4pM2yY5BOB9/YZL2OoosRqPoynVRtm/bwKjdHhuiaRhcGFhk8QE/mvfacQIAAAAAAAAAAHECAAAAAAAAAABpGFwaWQBo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs |
      | 1      | empty()void                                                                                                               |                                                                                                                                                                                                                                  | gqNzaWfEQDFR7lMtnCc83aW465p3xQszFqixlQsuBGpnAtKvgy5iBfkJSK3rGAErs22t1OT9ZYjNtppEbRlpzNNDCSKRmg2jdHhuiaRhcGFhkcQEqIwmpaRhcGlkAaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 3      | boolArgs(bool[])void                                                                                                      | AAqswA==                                                                                                                                                                                                                         | gqNzaWfEQB7BJ5U66CPqYqSqc+vzdNFyYaYg2bsOA6luFZjhmU+pPkD4B6L9blGiujvkj5WKCia7geP9XqjaqxH8eHHN/QSjdHhuiaRhcGFhksQErS5OfsQEAAqswKRhcGlkA6NmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 20     | fifteenArgs(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)void | AAFh,AAFi,AAFj,AAFk,AAFl,AAFm,AAFn,AAFo,AAFp,AAFq,AAFr,AAFs,AAFt,AAFu,AAFv                                                                                                                                                       | gqNzaWfEQLUSzQ0dMWAKx4/R+NhVB8PHnevmzV4nNLWhK7B45Jj4gV3c8L0nsw+xsb8Q6nHHnJJmGLGkuZPQdt3wMWMnNwOjdHhuiaRhcGFh3AAQxAQR2I2HxAMAAWHEAwABYsQDAAFjxAMAAWTEAwABZcQDAAFmxAMAAWfEAwABaMQDAAFpxAMAAWrEAwABa8QDAAFsxAMAAW3EAwABbsQDAAFvpGFwaWQUo2ZlZc0E0qJmds0jKKNnZW6rY3VjdW1iZXJuZXSiZ2jEIDH9Ies45BCBGT7TTN87K4Poh0BUtH2cYYK+8N+SOOuDomx2zSMyo3NuZMQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kdHlwZaRhcHBs |
      | 20     | sixteenArgs(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8)void          | AA==,AQ==,Ag==,Aw==,BA==,BQ==,Bg==,Bw==,CA==,CQ==,Cg==,Cw==,DA==,DQ==,Dg==,Dw==                                                                                                                                                  | gqNzaWfEQMpLr6nbJj+m2Wvvq90UXdYxn1i7CDwCVIr43YT/xxUy8H5MHStSnwIfQRAgwG91gsxN1mugk/aRNhm2nYZEvA+jdHhuiaRhcGFh3AAQxATidT9cxAEAxAEBxAECxAEDxAEExAEFxAEGxAEHxAEIxAEJxAEKxAELxAEMxAENxAIOD6RhcGlkFKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 20     | accountArgs(account,account,account,address,account)void                                                                  | WygnxOc7ALlIIsdm4zPiq5ZiQM+FRZDXg8QOrncK260=,CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0=,WygnxOc7ALlIIsdm4zPiq5ZiQM+FRZDXg8QOrncK260=,CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0=,fGi1Nk3Vn4xImkRXiz0TDlLgF2a7toSZQ92/BFskmos= | gqNzaWfEQAU/SKxm16OtBEJ3THxmGl0479yDsG7XyQbknuY7BxfjnJtuBxQnbm5JW/uX+5jXUADi+JCwjA3EhHwu65MZMACjdHhuiqRhcGFhlsQEjNMCh8QBAcQBAMQBAcQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f3EAQKkYXBhdJLEIFsoJ8TnOwC5SCLHZuMz4quWYkDPhUWQ14PEDq53CtutxCB8aLU2TdWfjEiaRFeLPRMOUuAXZru2hJlD3b8EWySai6RhcGlkFKNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6Jsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 20     | appArgs(application,application,uint64,application,application)void                                                       | AB////////8=,AAAAAAAAArw=,AAAAAAAAABQ=,AAAAAAAAABQ=,AAAAAAAAArw=                                                                                                                                                                 | gqNzaWfEQC/v+Hm+QoC6z6jKsFxTXCGRGmvmzmnX64ENDVXXDXxZpRVs+7svbh1ReOveuD3z/KYNO2mAC+Y99NtQt/FtJwyjdHhuiqRhcGFhlsQETRzPlMQBAcQBAsQIAAAAAAAAABTEAQDEAQKkYXBmYZLPAB/////////NArykYXBpZBSjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= |
      | 20     | assetArgs(asset,uint64,asset,asset,asset,asset)void                                                                       | AAAAAAAAAAc=,AAAAAAAAAAg=,AAAAAAAAAAg=,AAAAAAAAAAk=,AAAAAAAAAAk=,AB////////8=                                                                                                                                                    | gqNzaWfEQF7tHkJa/ZtxEoQVTRmZzHBWXtX0RlebnUkbABSuNv259w93HLu9Gl6QayW7LIUcbOfD/Bd0VvtNBuN5RQ/p2QijdHhuiqRhcGFhl8QEuMy5O8QBAMQIAAAAAAAAAAjEAQHEAQLEAQLEAQOkYXBhc5QHCAnPAB////////+kYXBpZBSjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OibHbNIzKjc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlpGFwcGw= |

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
      | app-id | method-signature         | app-args                                     | goldens |
      | 1      | payment(pay,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gqNzaWfEQCv0jOhwTJjQfJ9KXm6SJdeGAFea7brEq0BbwBDVMA577Rx3rooi9Ck/ZnExT66+a/kJpUGoPcjdrZoR7QLHHQSjdHhuiqNhbXTOAAGGoaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIN9TXFmEUnoCj+aTGTY6FrNbiCumYIoSgBhMZBZ1/HwOomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQDujKdRruRn6Xg46ZPBIfnL6eooQBqwTRyt9s05bDnc9I3NNqK7SBTuzKcvMes5PTbHxUw/GaNRbQo750PTtCgGjdHhuiqRhcGFhksQEU1pHusQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kYXBpZAGjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCDfU1xZhFJ6Ao/mkxk2OhazW4grpmCKEoAYTGQWdfx8DqJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |
      | 1      | generic(txn,address)bool | CfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f0= | gqNzaWfEQFBnvjwMoQIWkk2JR+C7k7ou4sE7zlq++gOuAkS/FgMorWgaeBAZNVqIAiTITgp7j7SapfH2xn69HIkOWcoH2ASjdHhuiqNhbXTOAAGGoaNmZWXNBNKiZnbNIyijZ2Vuq2N1Y3VtYmVybmV0omdoxCAx/SHrOOQQgRk+00zfOyuD6IdAVLR9nGGCvvDfkjjrg6NncnDEIJCQOjaegEcO1s8vPYqjhmiznNDzK2bTS69N0szpuG3pomx2zSMyo3JjdsQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2jc25kxCAJ+9J2LAj4bFrmv23Xp6kB3mZ111Dgfoxcdphkfbbh/aR0eXBlo3BheQ==,gqNzaWfEQKDNV+SD1s4XFzAhjHuWz8az7kolH7JQJG7BfrzMVAeD9DXmAPcA+M9yJdx/ZKoBVlEv4N5O+BM5tk0WzjW+/Q+jdHhuiqRhcGFhksQEWsMy4cQgCfvSdiwI+Gxa5r9t16epAd5mdddQ4H6MXHaYZH224f2kYXBpZAGjZmVlzQTSomZ2zSMoo2dlbqtjdWN1bWJlcm5ldKJnaMQgMf0h6zjkEIEZPtNM3zsrg+iHQFS0fZxhgr7w35I464OjZ3JwxCCQkDo2noBHDtbPLz2Ko4Zos5zQ8ytm00uvTdLM6bht6aJsds0jMqNzbmTEIAn70nYsCPhsWua/bdenqQHeZnXXUOB+jFx2mGR9tuH9pHR5cGWkYXBwbA== |

  Scenario: Initial status
    Given a new AtomicTransactionComposer
    Then The composer should have a status of "BUILDING".

  Scenario: Build with 0 transactions fails
    Given a new AtomicTransactionComposer
    When I build the transaction group with the composer. If there is an error it is "zero group size error".
    Then The composer should have a status of "BUILDING".
