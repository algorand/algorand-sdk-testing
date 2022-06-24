@unit
Feature: SourceMap

    @unit.sourcemap.pctoline
    Scenario Outline: Parse a SourceMap from json 
        Given a source map json file "<sourcemap-file>"
        Then getting the line that corresponds to the PC "<pc-value>" produces "<line-number>"

        Examples:
            | sourcemap-file | pc-value | line-number |
            | v2algodclient_responsejsons/sourcemap.json | 0 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 10 | 8 |

    @unit.sourcemap.linetopc
    Scenario Outline: Parse a SourceMap from json 
        Given a source map json file "<sourcemap-file>" 
        Then getting the first PC that corresponds to the line "<line-number>" produces "<pc-value>"

        Examples:
            | sourcemap-file | line-number | pc-value |
            | v2algodclient_responsejsons/sourcemap.json | 0 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 10 | 14 |