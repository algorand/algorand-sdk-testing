@unit
Feature: Dryrun Trace

    @unit.dryrun.trace.application
    Scenario Outline: Application Trace Tests
        Given a dryrun response file "<dryrun-response-file>" and a transaction id "<txn-id>"
        When I call app trace
        Then the output should equal "<golden>"

        Examples:
            | dryrun-response-file                            | txn-id | golden                                    |
            | v2algodclient_responsejsons/dryrunResponse.json | 0      | v2algodclient_responsejsons/app_trace.txt |
