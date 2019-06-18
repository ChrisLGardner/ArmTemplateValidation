# Based on functions found in the ARM VS Code extension
# https:#github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/JSON.ts#L243

# Read a JSON number from the provided $Iterator. The $Iterator must be pointing at either a
# Dash or Digits Token when this function is called.
function Get-ArmTokeniserNumber {
    param (
        $Iterator
    )
    $numberBasicTokens = @()

    if ($Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Dash) {
        # Negative sign
        $numberBasicTokens += $Iterator.Current()
        $Iterator.moveNext()
    }

    if ($Iterator.current() -and $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Digits) {
        # Whole number digits
        $numberBasicTokens += $Iterator.Current()
        $Iterator.moveNext()
    }

    if ($Iterator.current() -and $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Period) {
        #Decimal point
        $numberBasicTokens += $Iterator.Current()
        $Iterator.moveNext()

        if ($Iterator.current() -and $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Digits) {
            # Fractional number digits
            $numberBasicTokens += $Iterator.Current()
            $Iterator.moveNext()
        }
    }

    if ($Iterator.current()) {
        if ($Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Letters -and $Iterator.current().toString().toLower() -eq "e") {
            # e
            $numberBasicTokens += $Iterator.Current()
            $Iterator.moveNext()

            if ($Iterator.current() -and ($Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Dash -or $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Plus)) {
                # Exponent number sign
                $numberBasicTokens += $Iterator.Current()
                $Iterator.moveNext()
            }

            if ($Iterator.current() -and $Iterator.current().GetTokenType() -eq [ArmBasicTokenType]::Digits) {
                # Exponent number digits
                $numberBasicTokens += $Iterator.Current()
                $Iterator.moveNext()
            }
        }
    }

    return $numberBasicTokens
}
