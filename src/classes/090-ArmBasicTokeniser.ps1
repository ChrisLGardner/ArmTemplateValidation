class ArmBasicTokeniser {

    [string]$text
    [int]$textLength
    [int]$textIndex = -1

    [ArmBasicToken]$currentToken

    ArmBasicTokeniser ([string]$text) {
        $this.text = $text
        $this.textLength = $text.Length
    }

    #Get whether this Tokenizer has started tokenizing its text string.
    [bool] hasStarted() {
        return 0 -le $this.textIndex
    }

    <#
        Get the current Token that this Tokenizer has parsed from the source text. If this Tokenizer
        hasn't started parsing the source text, or if it has parsed the entire source text, then this
        will return undefined.
    #>
    [ArmBasicToken] current() {
        return $this.currentToken
    }

    # Get the current character that this Tokenizer is pointing at.
    [string] currentCharacter() {
        if (0 -le $this.textIndex -and $this.TextIndex -lt $this.TextLength) {
            return $this.Text[$this.TextIndex]
        }
        else {
            return $null
        }
    }

    # Move this Tokenizer to the next character in its source text.
    [void] nextCharacter(){
        $this.textIndex++
    }

    # Move this Tokenizer to the next Token in the source text string.
    [bool] moveNext() {
        if (-not $this.hasStarted()) {
            $this.nextCharacter()
        }

        if (-not $this.currentCharacter()) {
            $this.currentToken = $null
        }
        else {
            switch ($this.currentCharacter()) {
                "{"{
                    $this.currentToken = $Script:LeftCurlyBracket
                    $this.nextCharacter()
                    break
                }
                "}" {
                    $this.currentToken = $Script:RightCurlyBracket
                    $this.nextCharacter()
                    break
                }
                "[" {
                    $this.currentToken = $Script:LeftSquareBracket
                    $this.nextCharacter()
                    break
                }
                "]" {
                    $this.currentToken = $Script:RightSquareBracket
                    $this.nextCharacter()
                    break
                }
                "(" {
                    $this.currentToken = $Script:LeftParenthesis
                    $this.nextCharacter()
                    break
                }
                ")" {
                    $this.currentToken = $Script:RightParenthesis
                    $this.nextCharacter()
                    break
                }
                "_" {
                    $this.currentToken = $Script:Underscore
                    $this.nextCharacter()
                    break
                }
                "." {
                    $this.currentToken = $Script:Period
                    $this.nextCharacter()
                    break
                }
                "-" {
                    $this.currentToken = $Script:Dash
                    $this.nextCharacter()
                    break
                }
                "+" {
                    $this.currentToken = $Script:Plus
                    $this.nextCharacter()
                    break
                }
                "," {
                    $this.currentToken = $Script:Comma
                    $this.nextCharacter()
                    break
                }
                ":" {
                    $this.currentToken = $Script:Colon
                    $this.nextCharacter()
                    break
                }
                "'" {
                    $this.currentToken = $Script:SingleQuote
                    $this.nextCharacter()
                    break
                }
                '"' {
                    $this.currentToken = $Script:DoubleQuote
                    $this.nextCharacter()
                    break
                }
                "\" {
                    $this.currentToken = $Script:Backslash
                    $this.nextCharacter()
                    break
                }
                "/" {
                    $this.currentToken = $Script:ForwardSlash
                    $this.nextCharacter()
                    break
                }
                "*" {
                    $this.currentToken = $Script:Asterisk
                    $this.nextCharacter()
                    break
                }
                " " {
                    $this.currentToken = $Script:Space
                    $this.nextCharacter()
                    break
                }
                default {
                    if ($this.currentCharacter() -match '[a-z]') {
                        $this.currentToken = [ArmBasicToken]::New($this.readWhile('[a-z]'), [ArmBasicTokenType]::Letters)
                    }
                    elseif ($this.currentCharacter() -match '[0-9]') {
                        $this.currentToken = [ArmBasicToken]::New($this.readWhile('[0-9]'), [ArmBasicTokenType]::Digits)
                    }
                    else {
                        $this.currentToken = [ArmBasicToken]::New($this.currentCharacter(), [ArmBasicTokenType]::Unrecognized)
                        $this.nextCharacter()
                    }
                    break
                }
            }
        }

        return [bool]$this.currentToken
    }

    <#
        Read and return a sequence of characters from the source text that match the provided
        condition function.
    #>
    [string] readWhile([string]$RegexPattern) {
        $result = $this.currentCharacter()
        $this.nextCharacter()

        while ($this.currentCharacter() -and $this.currentCharacter() -match $RegexPattern) {
            $result += $this.currentCharacter()
            $this.nextCharacter()
        }

        return $result
    }
}
