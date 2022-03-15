@unit
Feature: Dryrun Trace

    @unit.dryrun.trace.application
    Scenario Outline: Application Trace Tests
        Given a dryrun response file "<dryrun-response-file>" and a transaction at index "<txn-index>"
        Then calling app trace produces "<app-trace-file>"

        Examples:
            | dryrun-response-file                                 | txn-index | app-trace-file                                  |
            | v2algodclient_responsejsons/dryrunResponse.json      | 0         | v2algodclient_responsejsons/app_trace.txt       |
            | v2algodclient_responsejsons/largeDryrunResponse.json | 0         | v2algodclient_responsejsons/large_app_trace.txt |
            | v2algodclient_responsejsons/errorDryrunResponse.json | 0         | v2algodclient_responsejsons/error_app_trace.txt |
