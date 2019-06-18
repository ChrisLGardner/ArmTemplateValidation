# Based on code from the VS Code extension for ARM:
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/src/TLE.ts

# A TLE Tokenisser that generates Tokens from a TLE string.
class ArmValueTokeniser {

    [ArmBasicTokeniser]$BasicTokeniser

    [ArmToken]$current

    [int]$currentTokenStartIndex = 0

    [ArmValueTokeniser] static fromString([string]$stringValue) {

        if ([String]::IsNullOrEmpty($StringValue)) {
            Write-Error -Message "String cannot be null" -ErrorAction Stop
        }

        $tt = [ArmValueTokeniser]::New()
        $tt.BasicTokeniser = [ArmBasicTokeniser]::New($stringValue)
        return $tt
    }

    [bool] hasStarted() {
        return $this.BasicTokeniser.hasStarted()
    }

    [bool] hasCurrent() {
        return $this.current -ne $null
    }

    [ArmToken] GetCurrent() {
        return $this.current
    }

    [void] nextBasicToken() {
        $this.BasicTokeniser.moveNext()
    }

    [ArmBasicToken] GetCurrentBasicToken() {
        return $this.BasicTokeniser.current()
    }

    [ArmToken] readToken() {
        if ($this.hasStarted() -eq $false) {
            $this.nextBasicToken()
        }
        elseif ($this.hasCurrent()) {
            $this.currentTokenStartIndex += $this.current.length
        }

        $this.current = $null
        if ($this.GetCurrentBasicToken()) {
            switch ($this.GetCurrentBasicToken().GetTokenType()) {
                {$_ -eq [ArmBasicTokenType]::LeftParenthesis} {
                    $this.current = [ArmToken]::createLeftParenthesis($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::RightParenthesis} {
                    $this.current = [ArmToken]::createRightParenthesis($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::LeftSquareBracket} {
                    $this.current = [ArmToken]::createLeftSquareBracket($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::RightSquareBracket} {
                    $this.current = [ArmToken]::createRightSquareBracket($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::Comma} {
                    $this.current = [ArmToken]::createComma($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::Period} {
                    $this.current = [ArmToken]::createPeriod($this.currentTokenStartIndex)
                    $this.nextBasicToken()
                    break
                }
                {$_ -eq [ArmBasicTokenType]::Space} {
                    $this.current = [ArmToken]::createWhitespace($this.currentTokenStartIndex, (Get-ArmTokeniserWhitespace -Iterator $this.BasicTokeniser).Text -join '')
                    break
                }
                {$_ -eq [ArmBasicTokenType]::DoubleQuote -or
                 $_ -eq [ArmBasicTokenType]::SingleQuote} {
                    $this.current = [ArmToken]::createQuotedString($this.currentTokenStartIndex, (Get-ArmTokeniserQuotedString -Iterator $this.BasicTokeniser).Text -join '')
                    break
                }
                {$_ -eq [ArmBasicTokenType]::Dash -or
                 $_ -eq [ArmBasicTokenType]::Digits} {
                    $this.current = [ArmToken]::createNumber($this.currentTokenStartIndex, (Get-ArmTokeniserNumber -Iterator $this.BasicTokeniser).Text -join '')
                    break
                }
                default {
                    $literalTokens = @($this.GetCurrentBasicToken())
                    $this.nextBasicToken()

                    while ($this.GetCurrentBasicToken() -and
                        ($this.GetCurrentBasicToken().GetTokenType() -eq [ArmBasicTokenType]::Letters -or
                            $this.GetCurrentBasicToken().GetTokenType() -eq [ArmBasicTokenType]::Digits -or
                            $this.GetCurrentBasicToken().GetTokenType() -eq [ArmBasicTokenType]::Underscore)) {
                        $literalTokens += $this.GetCurrentBasicToken()
                        $this.nextBasicToken()
                    }

                    $this.current = [ArmToken]::createLiteral($this.currentTokenStartIndex, ($literalTokens.text -join ''))
                    break
                }
            }
        }

        return $this.current
    }

    [bool] next() {
        $result = $this.readToken() -ne $null
        $this.skipWhitespace()
        return $result
    }

    [void] skipWhitespace() {
        while ($this.hasCurrent() -and $this.current.GetTokenType() -eq [ArmTokenType]::Whitespace) {
            $this.next()
        }
    }
}
