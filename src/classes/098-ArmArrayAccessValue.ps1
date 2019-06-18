# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE value that represents an array access expression.
class ArmArrayAccessValue : ArmValue {

    [ArmValue]$source
    [ArmToken]$leftSquareBracketToken
    [ArmValue]$index
    [ArmToken]$rightSquareBracketToken

    ArmArrayAccessValue ([ArmValue]$source, [ArmToken]$leftSquareBracketToken, [ArmValue]$index, [ArmToken]$rightSquareBracketToken) {

        if ($null -eq $Source -or $null -eq $leftSquareBracketToken) {
            Write-Error -Message "Must provide a source and a left square bracket token as a minimum" -ErrorAction Stop
        }

        if ($LeftSquareBracketToken.GetTokenType() -ne [ArmTokenType]::LeftSquareBracket -or ($null -ne $RightSquareBracketToken -and $RightSquareBracketToken.GetTokenType() -ne [ArmTokenType]::RightSquareBracket)) {
            Write-Error -Message "Square Brackets should be the correct token type" -ErrorAction Stop
        }

        $this.Source = $source
        $this.LeftSquareBracketToken = $LeftSquareBracketToken
        $this.index = $index
        $this.RightSquareBracketToken = $rightSquareBracketToken

        if ($this.source) {
            $this.source.parent = $this
        }

        if ($this.index) {
            $this.index.parent = $this
        }
    }

    # The span that contains this entire array access expression.
    [ArmSpan] getSpan() {
        $result = $this.source.getSpan()

        if ($this.rightSquareBracketToken) {
            $result = $result.union($this.rightSquareBracketToken.span)
        }
        elseif ($this.index) {
            $result = $result.union($this.index.getSpan())
        }
        else {
            $result = $result.union($this.leftSquareBracketToken.span)
        }

        return $result
    }

    [bool] contains([int]$characterIndex) {
        return $this.getSpan().contains($characterIndex, -not $this.rightSquareBracketToken)
    }

    [void] accept([ArmVisitor]$Visitor) {
        $visitor.visitArrayAccess($this)
    }

    [string] toString() {
        $result = "$($this.source.toString())["
        if ($null -ne $this.index) {
            $result += $this.index.toString()
        }
        if ($null -ne $this.rightSquareBracketToken) {
            $result += "]"
        }
        return $result
    }
}
