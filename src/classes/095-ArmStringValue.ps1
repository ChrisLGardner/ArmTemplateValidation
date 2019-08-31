# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE value representing a string.
class ArmStringValue : ArmValue {

    [ArmToken]$Token
    [int]$Length
    [string]$QuoteCharacter

    ArmStringValue([ArmToken]$token) {
        #super()

        if ($null -ne $Token) {
            $this.Token = $Token
            $this.Length = $Token.ToString().Length
        }
        else {
            Write-Error -Message "Token cannot be null"
        }
    }

    [string] GetLastCharacter() {
        return $this.toString()[$this.length - 1]
    }

    [ArmSpan] GetSpan() {
        return $this.Token.Span
    }

    [ArmSpan] GetUnquotedSpan() {
        return ([ArmSpan]::New(
            $this.getSpan().startIndex + 1,
            $this.Length - $(if ($this.hasCloseQuote()) {2} else {1})))
    }

    [bool] Contains([int]$CharacterIndex) {
        return $this.getSpan().contains($characterIndex, $true)
    }

    [bool] HasCloseQuote() {
        return $this.length -gt 1 -and $this.toString()[$this.length - 1] -eq $this.quoteCharacter
    }

    [bool] IsParametersArgument() {
        return $this.IsFunctionArgument("parameters")
    }

    [bool] IsVariablesArgument() {
        return $this.isFunctionArgument("variables")
    }

    [bool] IsFunctionArgument([string]$functionName) {
        $parent = $this.parent
        return $parent -and
            #$parent -is [ArmFunctionValue] -and ###what is a functionvalue? like a stringvalue?
            $parent.nameToken.stringValue -eq $functionName -and
            $parent.argumentExpressions[0] -eq $this
    }

    [void] accept([ArmVisitor]$Visitor) {
        $visitor.visitString($this)
    }

    [string] ToString() {
        return $this.token.stringValue
    }
}
