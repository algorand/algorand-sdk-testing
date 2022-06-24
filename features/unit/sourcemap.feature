@unit
Feature: SourceMap

    @unit.sourcemap.pctoline
    Scenario Outline: Parse a SourceMap from json and compare with expected pc:line string
        Given a source map json file "<sourcemap-file>"
        Then the string composed of pc:line number equals "<pc-to-line>"

        Examples:
            | sourcemap-file                             | pc-to-line                                                                    |
            | v2algodclient_responsejsons/sourcemap.json | 0:0;1:2;2:2;3:3;4:3;5:3;6:4;7:5;8:6;9:8;10:8;11:9;12:9;13:9;14:10;15:11;16:12 |