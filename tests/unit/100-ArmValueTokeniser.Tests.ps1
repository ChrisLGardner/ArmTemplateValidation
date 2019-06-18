# Based on tests from the ARM tools VS Code extension
# h$ttps://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmValueTokeniser" -Tag "ArmValueTokeniser" {

        Context "readToken()" {
            It "with null stringValue" {
                { [ArmValueTokeniser]::fromString($null) } | Should -Throw
            }

            It "with '' stringValue" {
                { [ArmValueTokeniser]::fromString("") } | Should -Throw
            }

            It "with empty TLE expression" {
                $tt = [ArmValueTokeniser]::fromString("[]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(1))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with empty TLE object with whitespace inside" {
                $tt = [ArmValueTokeniser]::fromString("[ ]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(1, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(2))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with comma" {
                $tt = [ArmValueTokeniser]::fromString(",")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createComma(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with escaped single-quoted empty string" {
                $tt = [ArmValueTokeniser]::fromString("''")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(0, "''"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with unterminated double-quoted string" {
                $tt = [ArmValueTokeniser]::fromString("'hello'")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(0, "'hello'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with unterminated single-quoted string" {
                $tt = [ArmValueTokeniser]::fromString("'hello")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(0, "'hello"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with double-quoted string with escaped back-slash inside" {
                $tt = [ArmValueTokeniser]::fromString("'C:\Users\'")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(0, "'C:\Users\'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with double-quoted string with escaped double-quote inside" {
                $tt = [ArmValueTokeniser]::fromString("'hellothere'")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(0, "'hellothere'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with zero" {
                $tt = [ArmValueTokeniser]::fromString("0")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createNumber(0, "0"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with positive number" {
                $tt = [ArmValueTokeniser]::fromString("123")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createNumber(0, "123"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with negative number" {
                $tt = [ArmValueTokeniser]::fromString("-456")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createNumber(0, "-456"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with floating-point number" {
                $tt = [ArmValueTokeniser]::fromString("7.8")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createNumber(0, "7.8"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with expression with single constant string" {
                $tt = [ArmValueTokeniser]::fromString("[ 'apples']")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(1, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(2, "'apples'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(10))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with true" {
                $tt = [ArmValueTokeniser]::fromString("true")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(0, "true"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with value that starts with '.'" {
                $tt = [ArmValueTokeniser]::fromString(". hello there")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createPeriod(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(1, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(2, "hello"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(7, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(8, "there"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with literal that ends with a number" {
                $tt = [ArmValueTokeniser]::fromString("base64")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(0, "base64"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with several invalid literals" {
                $tt = [ArmValueTokeniser]::fromString(".[]82348923asdglih   asl .,'")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createPeriod(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(1))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(2))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createNumber(3, "82348923"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(11, "asdglih"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(18, "   "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(21, "asl"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(24, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createPeriod(25))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createComma(26))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(27, "'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with function TLE with no arguments" {
                $tt = [ArmValueTokeniser]::fromString("[concat()]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightParenthesis(8))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(9))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with function TLE with no arguments with no closing right square bracket" {
                $tt = [ArmValueTokeniser]::fromString("[concat()")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightParenthesis(8))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with function TLE with one argument" {
                $tt = [ArmValueTokeniser]::fromString("[concat('Seattle')]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(8, "'Seattle'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightParenthesis(17))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(18))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            It "with function TLE with two arguments" {
                $tt = [ArmValueTokeniser]::fromString("[concat('Seattle', 'WA')]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(8, "'Seattle'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createComma(17))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(18, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(19, "'WA'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightParenthesis(23))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(24))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }

            Context "Quoted TLE strings" {
                It "simple string" {
                    $tt = [ArmValueTokeniser]::fromString("['Seattle']")
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(1, "'Seattle'"))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(10))
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }

                It "empty string" {
                    $tt = [ArmValueTokeniser]::fromString("['']")
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(1, "''"))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(3))
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }

                It "with single escaped apostrophe" {
                    $tt = [ArmValueTokeniser]::fromString("['That\'s all, folks!']")
                    Assert-Equivalent -Actual $tt.readToken() -Expected  ([ArmToken]::createLeftSquareBracket(0))
                    Assert-Equivalent -Actual $tt.readToken() -Expected  ([ArmToken]::createQuotedString(1, "'That\'s all, folks!'"))
                    Assert-Equivalent -Actual $tt.readToken() -Expected  ([ArmToken]::createRightSquareBracket(22))
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }

                It "with multiple escaped apostrophes" {
                    $tt = [ArmValueTokeniser]::fromString("['That\'s all, \'folks\'!']")
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(1, "'That\'s all, \'folks\'!'"))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(26))
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }

                It "with escaped apostrophes at beginning and end of expression" {
                    $tt = [ArmValueTokeniser]::fromString("['That is all, folks!']")
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(1, "'That is all, folks!'"))
                    Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(22))
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }

                It "https://github.com/Microsoft/vscode-azurearmtools/issues/34" {
                    $tt = [ArmValueTokeniser]::fromString("[concat(reference(parameters('publicIpName')).dnsSettings.fqdn, '  sudo docker volume rm \'dockercompose_cert-volume\' sudo docker-compose up')]")
                    $expected = @(
                        "[",
                        "concat",
                        "(",
                        "reference",
                        "(",
                        "parameters",
                        "(",
                        "'publicIpName'",
                        ")",
                        ")",
                        ".",
                        "dnsSettings",
                        ".",
                        "fqdn",
                        ",",
                        " ",
                        "'  sudo docker volume rm \'dockercompose_cert-volume\' sudo docker-compose up'",
                        ")",
                        "]"
                    )
                    foreach ($expectedToken in $expected) {
                        Assert-Equivalent -Actual $tt.readToken().stringValue -Expected $expectedToken
                    }
                    Assert-Equivalent -Actual $tt.readToken() -Expected $null
                }
            }

            It "with function TLE with multiple arguments" {
                $tt = [ArmValueTokeniser]::fromString("[concat('Seattle', 'WA', 'USA')]")
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(8, "'Seattle'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createComma(17))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(18, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(19, "'WA'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createComma(23))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createWhitespace(24, " "))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createQuotedString(25, "'USA'"))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightParenthesis(30))
                Assert-Equivalent -Actual $tt.readToken() -Expected ([ArmToken]::createRightSquareBracket(31))
                Assert-Equivalent -Actual $tt.readToken() -Expected ($null)
            }
        }
    }
}
