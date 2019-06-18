# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# The result of parsing a TLE string.
class ArmParserResult {

    [ArmToken]$leftSquareBracketToken

    [ArmValue]$expression

    [ArmToken]$rightSquareBracketToken

    [ArmIssue[]]$Errors


    ArmParserResult ([ArmToken]$leftSquareBracketToken, [ArmValue]$expression, [ArmToken]$rightSquareBracketToken, [ArmIssue[]]$errors) {
        $this.leftSquareBracketToken = $leftSquareBracketToken
        $this.expression = $expression
        $this.rightSquareBracketToken = $rightSquareBracketToken
        $this.Errors = $errors
    }

    [ArmValue] GetValueAtCharacterIndex([int]$characterIndex) {
        [ArmValue]$result = $null

        $current = $this.expression
        if ($current -and $current.contains($characterIndex)) {
            while (!$result) {
                $currentValue = $current
                if ($currentValue -is [ArmFunctionValue]) {
                    if ($currentValue.argumentExpressions) {
                        foreach ($argumentExpression in $currentValue.argumentExpressions) {
                            if ($argumentExpression -and $argumentExpression.contains($characterIndex)) {
                                $current = $argumentExpression
                                break
                            }
                        }
                    }

                    # If the characterIndex was not in any of the argument expressions, then
                    # it must be somewhere inside this function expression.
                    if ($current -eq $currentValue) {
                        $result = $current
                    }
                }
                elseif ($currentValue -is [ArmArrayAccessValue]) {
                    if ($currentValue.source -and $currentValue.source.contains($characterIndex)) {
                        $current = $currentValue.source
                    }
                    elseif ($currentValue.index -and $currentValue.index.contains($characterIndex)) {
                        $current = $currentValue.index
                    }
                    else {
                        $result = $current
                    }
                }
                elseif ($currentValue -is [ArmPropertyAccess]) {
                    if ($currentValue.source.contains($characterIndex)) {
                        $current = $currentValue.source
                    }
                    else {
                        $result = $current
                    }
                }
                else {
                    $result = $current
                }
            }
        }

        return $result
    }
}
