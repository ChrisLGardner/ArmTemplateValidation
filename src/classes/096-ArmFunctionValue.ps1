# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE value that represents a function expression.
class ArmFunctionValue : ArmValue {

    [ArmToken]$NameToken

    [ArmToken]$LeftParenthesisToken

    [ArmToken[]]$CommaToken

    [ArmValue[]]$ArgumentExpression

    [ArmToken]$rightParenthesisToken

    ArmFunctionValue ([ArmToken]$nameToken, [ArmToken]$leftParenthesisToken,[ArmToken[]]$CommaToken, [ArmValue[]]$argumentExpressions, [ArmToken]$rightParenthesisToken) {
        if ($null -eq $nameToken -or $null -eq $CommaToken -or $null -eq $argumentExpressions) {
            Write-Error -Message "Name, Commas and ArgumentExpression cannot be null" -ErrorAction Stop
        }

        $this.nameToken = $nameToken
        $this.leftParenthesisToken = $leftParenthesisToken
        $this.commaToken = $CommaToken
        $this.ArgumentExpression = $argumentExpressions
        $this.rightParenthesisToken = $rightParenthesisToken

        foreach ($argumentExpression in $argumentExpressions.where({$_})) {
                $argumentExpression.parent = $this
        }
    }

    [ArmSpan] GetArgumentListSpan() {
        [ArmSpan]$result = $null

        if ($this.leftParenthesisToken) {
            $result = $this.leftParenthesisToken.span

            if ($this.rightParenthesisToken) {
                $result = $result.union($this.rightParenthesisToken.span)
            }
            elseif ($this.argumentExpressions.length -gt 0 -or $this.CommaToken.length -gt 0) {
                for ($i = $this.argumentExpressions.length - 1; 0 -le $i; --$i) {
                    $arg = $this.argumentExpressions[$i]
                    if ($null -ne $arg) {
                        $result = $result.union($arg.getSpan())
                        break
                    }
                }

                if (0 -lt $this.CommaToken.length) {
                    $result = $result.union($this.CommaToken[$this.CommaToken.length - 1].span)
                }
            }
        }

        return $result
    }

    [ArmSpan] GetSpan() {
        return $this.nameToken.span.union($this.GetArgumentListSpan())
    }

    [bool] Contains([int]$characterIndex) {
        return $this.getSpan().contains($characterIndex, (-not $this.rightParenthesisToken))
    }

    [void] Accept([ArmVisitor]$visitor) {
        $visitor.visitFunction($this)
    }

    [string] ToString() {
        $result = $this.nameToken.stringValue
        if ($null -ne $this.leftParenthesisToken) {
            $result += "("
        }

        for ($i = 0; $i -lt $this.argumentExpressions.length; ++$i) {
            if ($i > 0) {
                $result += ", "
            }
            $result += $this.argumentExpressions[$i].toString()
        }

        if ($null -ne $this.rightParenthesisToken) {
            $result += ")"
        }

        return $result
    }
}
