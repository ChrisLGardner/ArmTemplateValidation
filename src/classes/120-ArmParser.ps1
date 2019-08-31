# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A parser for TLE strings.
class ArmParser {

    static [ArmIssue[]]$errors

    [ArmParserResult] static parse([String]$stringValue) {
        if ([String]::IsNullOrEmpty($StringValue)) {
            Write-Error -Message "TLE strings cannot be `$null and must be at least 1 character." -ErrorAction Stop
        }

        [ArmToken]$leftSquareBracketToken = $null
        [ArmValue]$expression = $null
        [ArmToken]$rightSquareBracketToken = $null

        if (2 -le $stringvalue.length -and $stringvalue.substring(0, 2) -eq "[[") {
            $expression = [ArmStringvalue]::New([ArmToken]::CreateLiteral(0, $stringvalue))
        }
        else {
            $tokeniser = [ArmValueTokeniser]::FromString($stringvalue)
            $tokeniser.next()

            if (-not $tokeniser.hasCurrent() -or $tokeniser.current.GetTokenType() -ne [ArmTokenType]::LeftSquareBracket) {
                $expression = [ArmStringValue]::New([ArmToken]::createQuotedString(0, $stringvalue))
            }
            else {
                $leftSquareBracketToken = $tokeniser.current
                $tokeniser.next()

                while (
                    $tokeniser.hasCurrent() -and
                    $tokeniser.current.GetTokenType() -ne [ArmTokenType]::Literal -and
                    $tokeniser.current.GetTokenType() -ne [ArmTokenType]::RightSquareBracket
                ) {
                    [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected a literal value."))
                    $tokeniser.next()
                }

                $expression = [ArmParser]::ParseExpression($tokeniser)

                while ($tokeniser.hasCurrent()) {
                    if ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightSquareBracket) {
                        $rightSquareBracketToken = $tokeniser.current
                        $tokeniser.next()
                        break
                    }
                    else {
                        [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected the end of the string."))
                        $tokeniser.next()
                    }
                }

                if ($rightSquareBracketToken -ne $null) {
                    while ($tokeniser.hasCurrent()) {
                        [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Nothing should exist after the closing ']' except for whitespace."))
                        $tokeniser.next()
                    }
                }
                else {
                    [ArmParser]::Errors += ([ArmIssue]::New([ArmSpan]::New($stringvalue.length - 1, 1), "Expected a right square bracket (']')."))
                }

                if ($expression -eq $null) {
                    $errorSpan = $leftSquareBracketToken.span
                    if ($null -ne $rightSquareBracketToken) {
                        $errorSpan = $errorSpan.union($rightSquareBracketToken.span)
                    }
                    [ArmParser]::Errors += ([ArmIssue]::New($errorSpan, "Expected a function or property expression."))
                }
            }
        }

        return [ArmParserResult]::New($leftSquareBracketToken, $expression, $rightSquareBracketToken, [ArmParser]::errors)
    }

    [ArmValue] static ParseExpression([ArmValueTokeniser]$tokeniser) {
        [ArmValue]$expression = $null

        if ($tokeniser.hasCurrent()) {
            $token = $tokeniser.current
            $tokenType = $token.GetTokenType()
            if ($tokenType -eq [ArmTokenType]::Literal) {
                $expression = [ArmParser]::ParseFunction($tokeniser)
            }
            elseif ($tokenType -eq [ArmTokenType]::QuotedString) {
                if (!$token.stringvalue.endsWith($token.stringvalue[0])) {
                    [ArmParser]::Errors += ([ArmIssue]::New($token.span, "A constant string is missing an end quote."))
                }
                $expression = [ArmStringValue]::New($token)
                $tokeniser.next()
            }
            elseif ($tokenType -eq [ArmTokenType]::Number) {
                $expression = [ArmNumberValue]::New($token)
                $tokeniser.next()
            }
            elseif ($tokenType -ne [ArmTokenType]::RightSquareBracket -and $tokenType -ne [ArmTokenType]::Comma) {
                [ArmParser]::Errors += ([ArmIssue]::New($token.span, "Template language expressions must start with a function."))
                $tokeniser.next()
            }
        }

        if ($null -ne $expression) {
            while ($tokeniser.hasCurrent()) {
                if ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::Period) {
                    $periodToken = $tokeniser.current
                    $tokeniser.next()

                    [ArmToken]$propertyNameToken = $null
                    [ArmSpan]$errorSpan = $null

                    if ($tokeniser.hasCurrent()) {
                        if ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::Literal) {
                            $propertyNameToken = $tokeniser.current
                            $tokeniser.next()
                        }
                        else {
                            $errorSpan = $tokeniser.current.span

                            $tokenType = $tokeniser.current.GetTokenType()
                            if ($tokenType -ne [ArmTokenType]::RightParenthesis -and
                                $tokenType -ne [ArmTokenType]::RightSquareBracket -and
                                $tokenType -ne [ArmTokenType]::Comma
                            ) {
                                $tokeniser.next()
                            }
                        }
                    }
                    else {
                        $errorSpan = $periodToken.span
                    }

                    if ($null -eq $propertyNameToken) {
                        if ($null -ne $errorSpan) {
                            [ArmParser]::Errors += ([ArmIssue]::New($errorSpan, "Expected a literal value."))
                        }
                    }

                    $expression = [ArmPropertyAccess]::New($expression, $periodToken, $propertyNameToken)
                }
                elseif ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::LeftSquareBracket) {
                    $leftSquareBracketToken = $tokeniser.current
                    $tokeniser.next()

                    $index = [ArmParser]::ParseExpression($tokeniser)

                    [ArmToken]$rightSquareBracketToken = $null
                    if ($tokeniser.hasCurrent() -and $tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightSquareBracket) {
                        $rightSquareBracketToken = $tokeniser.current
                        $tokeniser.next()
                    }

                    $expression = [ArmArrayAccessValue]::New($expression, $leftSquareBracketToken, $index, $rightSquareBracketToken)
                }
                else {
                    break
                }
            }
        }

        return $expression
    }

    [ArmFunctionValue] static ParseFunction([ArmValueTokeniser]$tokeniser) {
        if ($null -eq $tokeniser -or (-not $tokeniser.HasCurrent()) -or ($Tokeniser.current.GetTokenType() -ne [ArmTokenType]::Literal) -or [ArmParser]::errors.count -gt 0) {
            #Write-Error -Message "Tokeniser's current token must be a literal and there can be no errors so far"
        }

        $nameToken = $tokeniser.current
        $tokeniser.next()

        [ArmToken]$leftParenthesisToken = $null
        [ArmToken]$rightParenthesisToken = $null
        [ArmToken[]]$CommaToken = @()
        [ArmValue[]]$argumentExpressions = @()

        if ($tokeniser.hasCurrent()) {
            while ($tokeniser.hasCurrent()) {
                if ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::LeftParenthesis) {
                    $leftParenthesisToken = $tokeniser.current
                    $tokeniser.next()
                    break
                }
                elseif ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightSquareBracket) {
                    [ArmParser]::Errors += ([ArmIssue]::New($nameToken.span, "Missing function argument list."))
                    break
                }
                else {
                    [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected the end of the string."))
                    $tokeniser.next()
                }
            }
        }
        else {
            [ArmParser]::Errors += ([ArmIssue]::New($nameToken.span, "Missing function argument list."))
        }

        if ($tokeniser.hasCurrent()) {
            $expectingArgument = $true

            while ($tokeniser.hasCurrent()) {
                if ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightParenthesis -or $tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightSquareBracket) {
                    break
                }
                elseif ($expectingArgument) {
                    $expression = [ArmParser]::parseExpression($tokeniser)
                    if ($expression -eq $null -and $tokeniser.hasCurrent() -and $tokeniser.current.GetTokenType() -eq [ArmTokenType]::Comma) {
                        [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected a constant string, function, or property expression."))
                    }
                    $argumentExpressions += $expression
                    $expectingArgument = $false
                }
                elseif ($tokeniser.current.GetTokenType() -eq [ArmTokenType]::Comma) {
                    $expectingArgument = $true
                    $CommaToken += $tokeniser.current
                    $tokeniser.next()
                }
                else {
                    [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected a comma (',')."))
                    $tokeniser.next()
                }
            }

            if ([ArmParser]::isMissingArgument($expectingArgument, $leftParenthesisToken, $argumentExpressions.length, $tokeniser)) {
                $argumentExpressions += $null

                if ($tokeniser.hasCurrent()) {
                    $errorSpan = $tokeniser.current.span
                }
                else {
                    $errorSpan = $CommaToken[$CommaToken.length - 1].span
                }
                [ArmParser]::Errors += ([ArmIssue]::New($errorSpan, "Expected a constant string, function, or property expression."))
            }
        }
        elseif ($leftParenthesisToken -ne $null) {
            [ArmParser]::Errors += ([ArmIssue]::New($leftParenthesisToken.span, "Expected a right parenthesis (')')."))
        }

        if ($tokeniser.hasCurrent()) {
            switch ($tokeniser.current.GetTokenType()) {
                {$_ -eq [ArmTokenType]::RightParenthesis} {
                    $rightParenthesisToken = $tokeniser.current
                    $tokeniser.next()
                    break
                }
                {$_ -eq [ArmTokenType]::RightSquareBracket} {
                    if ($leftParenthesisToken -ne $null) {
                        [ArmParser]::Errors += ([ArmIssue]::New($tokeniser.current.span, "Expected a right parenthesis (')')."))
                    }
                    break
                }
            }
        }

        return [ArmFunctionValue]::New($nameToken, $leftParenthesisToken, $CommaToken, $argumentExpressions, $rightParenthesisToken)
    }

    [bool] static isMissingArgument([bool]$expectingArgument, [ArmToken]$leftParenthesisToken, [int]$existingArguments, [ArmValueTokeniser]$tokeniser) {
        $result = $false

        if ($expectingArgument -and $leftParenthesisToken -ne $null -and 0 -lt $existingArguments) {
            if (-not $tokeniser.hasCurrent()) {
                $result = $true
            }
            else {
                $result = $tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightParenthesis -or
                    $tokeniser.current.GetTokenType() -eq [ArmTokenType]::RightSquareBracket
            }
        }

        return $result
    }
}
