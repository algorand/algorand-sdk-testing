@unit
Feature: SourceMap

    @unit.sourcemap.pctoline
    Scenario Outline: Parse a SourceMap from json and compare with expected pc:line string
        Given a source map json file "<sourcemap-file>"
        Then the string composed of pc:line number equals "<pc-to-line>"

        Examples:
            | sourcemap-file                             | pc-to-line                                                                                                                                                                                                                                                                   |
            | v2algodclient_responsejsons/sourcemap.json | 1:7;2:7;3:7;4:7;5:7;6:7;7:7;8:7;9:7;10:7;11:7;12:7;13:7;14:7;15:7;16:7;17:7;18:7;19:7;20:7;21:7;22:7;23:7;24:7;25:7;26:7;27:7;28:7;29:8;30:9;31:9;32:9;33:10;34:10;35:10;36:11;37:12;38:12;39:13;40:14;41:14;42:14;43:15;44:16;45:17;46:17;47:18;48:18;49:19;50:20;51:21 |