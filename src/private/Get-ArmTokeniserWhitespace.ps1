# Based on functions found in the ARM VS Code extension
# https:#github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/JSON.ts#L243

# Read a JSON whitespace string from the provided tokenizer. The tokenizer must be pointing at
# either a Space, Tab, CarriageReturn, NewLine, or CarriageReturnNewLine Token.
function Get-ArmTokeniserWhitespace {
    param (
        $Iterator
    )
    $whitespaceTokens = @($Iterator.current())
    $Iterator.moveNext()

    while ($Iterator.current() -and
        ($Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Space -or
            $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Tab -or
            $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::CarriageReturn -or
            $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::NewLine -or
            $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::CarriageReturnNewLine)) {
        $whitespaceTokens += $Iterator.current()
        $Iterator.moveNext()
    }

    return $whitespaceTokens
}
