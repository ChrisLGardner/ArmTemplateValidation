# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE value that represents a number.
class ArmNumberValue : ArmValue {

    [ArmToken]$Token

    ArmNumberValue ([ArmToken]$Token) {
        if ($null -eq $Token -or $Token.GetTokenType() -ne [ArmTokenType]::Number) {
            Write-Error -Message "Token cannot be null and must be a number"
        }

        $this.Token = $Token
    }

    [ArmSpan] GetSpan() {
        return $this.token.span
    }

    [bool] contains([int]$characterIndex) {
        return $this.getSpan().contains($characterIndex, $true)
    }

    [void] accept([ArmVisitor]$Visitor) {
        $visitor.visitNumber($this)
    }

    [string] toString() {
        return $this.token.stringValue
    }
}
