# Based on functions found in the ARM VS Code extension
# https:#github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/JSON.ts#L243

# Read a JSON quoted string from the provided tokenizer. The tokenizer must be pointing at
# either a SingleQuote or DoubleQuote Token.
function Get-ArmTokeniserQuotedString {
    param (
        $Iterator
    )
    $startQuote = $Iterator.current()
    $quotedStringTokens = @($startQuote)
    $Iterator.moveNext()

    $escaped = $false
    [ArmBasicToken]$endQuote = $null
    while (!$endQuote -and $Iterator.current()) {
        $quotedStringTokens += $Iterator.current()

        if ($escaped) {
            $escaped = $false
        }
        else {
            if ($Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Backslash) {
                $escaped = $true
            }
            elseif ($Iterator.current().GetTokenType() -eq $startQuote.GetTokenType()) {
                $endQuote = $Iterator.current()
            }
        }

        $Iterator.moveNext()
    }

    return $quotedStringTokens
}
