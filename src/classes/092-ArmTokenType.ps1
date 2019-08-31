# Based on conde from the ARM VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/src/TLE.ts

# The different types of tokens that can be produced from a TLE string.
enum ArmTokenType {
    LeftSquareBracket
    RightSquareBracket
    LeftParenthesis
    RightParenthesis
    QuotedString
    Comma
    Whitespace
    Literal
    Period
    Number
}
