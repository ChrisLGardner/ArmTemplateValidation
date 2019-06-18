# Based on conde from the ARM VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/src/TLE.ts

class ArmToken {
    [ArmTokenType]$Type
    [ArmSpan]$Span
    [String]$StringValue
    [int]$Length

    [ArmToken] static create([ArmTokenType]$TokenType, [int]$StartIndex, [string]$StringValue) {
        if ($null -eq $TokenType -or $null -eq $StringValue) {
            Write-Error -Message "TokenType and StringValue must both have a value and cannot be null" -ErrorAction Stop
        }

        $t = [ArmToken]::New()
        $t.Type = $TokenType
        $t.Span = [ArmSpan]::New($StartIndex, $StringValue.length)
        $t.StringValue = $stringValue
        $t.length = $StringValue.length
        return $t
    }

    [ArmTokenType] getTokenType() {
        return $this.Type
    }

    [ArmToken] static createLeftParenthesis([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::LeftParenthesis, $StartIndex, "(")
    }

    [ArmToken] static createRightParenthesis([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::RightParenthesis, $StartIndex, ")")
    }

    [ArmToken] static createLeftSquareBracket([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::LeftSquareBracket, $StartIndex, "[")
    }

    [ArmToken] static createRightSquareBracket([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::RightSquareBracket, $StartIndex, "]")
    }

    [ArmToken] static createComma([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::Comma, $StartIndex, ",")
    }

    [ArmToken] static createPeriod([int]$StartIndex) {
        return [ArmToken]::Create([ArmTokenType]::Period, $StartIndex, ".")
    }

    [ArmToken] static createWhitespace([int]$StartIndex, [string]$StringValue) {
        if ($null -eq $StringValue) {
            Write-Error -Message "Must not be null or greater than 1 character wide" -ErrorAction Stop
        }

        return [ArmToken]::Create([ArmTokenType]::Whitespace, $startIndex, $stringValue)
    }

    [ArmToken] static createQuotedString([int]$StartIndex, [string]$StringValue) {
        $QuoteCharacters = '"',"'" -join '|'
        if ([String]::IsNullOrWhiteSpace($StringValue) -or $StringValue[0] -notmatch $QuoteCharacters) {
            Write-Error -Message "String much start with a quote character and be greater than 1 character long." -ErrorAction Stop
        }

        return [ArmToken]::Create([ArmTokenType]::QuotedString, $startIndex, $stringValue)
    }

    [ArmToken] static createNumber([int]$StartIndex, [string]$StringValue) {
        if ($null -eq $StringValue -or $StringValue.Length -lt 1 -or $StringValue[0] -notmatch '-|\d') {
            Write-Error -Message "Must be an integer" -ErrorAction Stop
        }

        return [ArmToken]::Create([ArmTokenType]::Number, $startIndex, $stringValue)
    }

    [ArmToken] static createLiteral([int]$StartIndex, [string]$StringValue) {
        if ([String]::IsNullOrEmpty($StringValue)) {
            Write-Error -Message "Must be a string with legnth greater than 1" -ErrorAction Stop
        }

        return [ArmToken]::Create([ArmTokenType]::Literal, $startIndex, $stringValue)
    }
}
