@unit
Feature: SourceMap

    @unit.sourcemap.pctoline
    Scenario Outline: Parse a SourceMap from json 
        Given a source map json file "<soucemap-file>" and a PC with the value "<pc-value>" 
        Then getting the line that corresponds to the PC produces "<line-number>"

        Examples:
            | sourcemap-file | pc-value | line-number |
            | v2algodclient_responsejsons/sourcemap.json | 0 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 10 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 101 | 0 |

    @unit.sourcemap.linetopc
    Scenario Outline: Parse a SourceMap from json 
        Given a source map json file "<soucemap-file>" and a Line with the value "<line-number>" 
        Then getting the first PC that corresponds to the line produces "<pc-value>"

        Examples:
            | sourcemap-file | line-number | pc-value |
            | v2algodclient_responsejsons/sourcemap.json | 0 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 10 | 0 |
            | v2algodclient_responsejsons/sourcemap.json | 101 | 0 |