@unit
Feature: SourceMap

    @unit.sourcemap
    Scenario Outline: Parse a SourceMap from json and compare with expected pc:line string
        Given a source map json file "<sourcemap-file>"
        Then the string composed of pc:line number equals "<pc-to-line>"

        Examples:
            | sourcemap-file                             | pc-to-line                                                                                                                                                                                                                                                                   |
            | v2algodclient_responsejsons/sourcemap.json | 0:0;1:7;2:7;3:7;4:7;5:7;6:7;7:7;8:7;9:7;10:7;11:7;12:7;13:7;14:7;15:7;16:7;17:7;18:7;19:7;20:7;21:7;22:7;23:7;24:7;25:7;26:7;27:7;28:7;29:8;30:9;31:9;32:9;33:10;34:10;35:10;36:11;37:12;38:12;39:13;40:14;41:14;42:14;43:15;44:16;45:17;46:17;47:18;48:18;49:19;50:20;51:21 |

    @unit.sourcemap
    Scenario Outline: Parse a SourceMap from json and compare with expected pc:line string
        Given a source map json file "<sourcemap-file>"
        Then getting the line associated with a pc "<pc>" equals "<line>"
        Examples:
            | sourcemap-file                             | pc | line |
            | v2algodclient_responsejsons/sourcemap.json | 0  | 0    |
            | v2algodclient_responsejsons/sourcemap.json | 1  | 7    |
            | v2algodclient_responsejsons/sourcemap.json | 5  | 7    |
            | v2algodclient_responsejsons/sourcemap.json | 30 | 9    |
            | v2algodclient_responsejsons/sourcemap.json | 51 | 21   |

    @unit.sourcemap
    Scenario Outline: Parse a SourceMap from json and compare with expected pc:line string
        Given a source map json file "<sourcemap-file>"
        Then getting the last pc associated with a line "<line>" equals "<pc>"

        Examples:
            | sourcemap-file                             |  line | pc |
            | v2algodclient_responsejsons/sourcemap.json |  0    | 0  |
            | v2algodclient_responsejsons/sourcemap.json |  7    | 28 |
            | v2algodclient_responsejsons/sourcemap.json |  9    | 32 |
            | v2algodclient_responsejsons/sourcemap.json |  21   | 51 |

    @unit.sourcemapv2
    Scenario: Parse a SourceMap from json and compare expected pcs
        Given a source map json file "v2algodclient_responsejsons/sourcemapv2/sourcemap-test.teal.tok.map"
        Then the source map contains pcs "4,6,8,9,12,14,16,17,19,20,21,22,23,24"

    @unit.sourcemapv2
    Scenario Outline: Parse a SourceMap from json and compare with expected pc to line mapping
        Given a source map json file "v2algodclient_responsejsons/sourcemapv2/sourcemap-test.teal.tok.map"
        Then the source map maps pc <pc> to line <line> and column <column> of source "<source>"

        Examples:
            | pc | line | column | source              |
            |  4 |    3 |      0 | sourcemap-test.teal |
            |  6 |    3 |     19 | sourcemap-test.teal |
            |  8 |    3 |     26 | sourcemap-test.teal |
            |  9 |    3 |     30 | sourcemap-test.teal |
            | 12 |    6 |      4 | sourcemap-test.teal |
            | 14 |    6 |     11 | sourcemap-test.teal |
            | 16 |    6 |     18 | sourcemap-test.teal |
            | 17 |    7 |      4 | sourcemap-test.teal |
            | 19 |    7 |     11 | sourcemap-test.teal |
            | 20 |    7 |     18 | sourcemap-test.teal |
            | 21 |    1 |     21 | lib.teal            |
            | 22 |    1 |     25 | lib.teal            |
            | 23 |   11 |      4 | sourcemap-test.teal |
            | 24 |   12 |      4 | sourcemap-test.teal |
    
    @unit.sourcemapv2
    Scenario Outline: Parse a SourceMap from json and compare the expected source and line to pc mapping
        Given a source map json file "v2algodclient_responsejsons/sourcemapv2/sourcemap-test.teal.tok.map"
        Then the source map maps source "<source>" and line <line> to pc <pc> at column <column>

        Examples:
            | source              | line | pc | column |
            | sourcemap-test.teal |    3 |  4 |      0 |
            | sourcemap-test.teal |    3 |  6 |     19 |
            | sourcemap-test.teal |    3 |  8 |     26 |
            | sourcemap-test.teal |    3 |  9 |     30 |
            | sourcemap-test.teal |    6 | 12 |      4 |
            | sourcemap-test.teal |    6 | 14 |     11 |
            | sourcemap-test.teal |    6 | 16 |     18 |
            | sourcemap-test.teal |    7 | 17 |      4 |
            | sourcemap-test.teal |    7 | 19 |     11 |
            | sourcemap-test.teal |    7 | 20 |     18 |
            | lib.teal            |    1 | 21 |     21 |
            | lib.teal            |    1 | 22 |     25 |
            | sourcemap-test.teal |   11 | 23 |      4 |
            | sourcemap-test.teal |   12 | 24 |      4 |
