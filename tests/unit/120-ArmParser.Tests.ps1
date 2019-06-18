# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmParser" -Tag "ArmParser" {

        Context "parse(string)" {

            BeforeEach {
                [ArmParser]::Errors = @()
            }

            It "with null stringValue" {
                {[ArmParser]::Parse($null)} | Should -Throw
            }

            It "with empty stringValue" {
                {[ArmParser]::Parse("")} | Should -Throw
            }

            It "with non-empty non-quoted stringValue" {
                {[ArmParser]::Parse("hello")} | Should -Throw
            }

            It "with single double-quote character" {
                $Sut = [ArmParser]::Parse('"')
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.leftSquareBracketToken | Should -BeNullOrEmpty
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0

                Assert-Equivalent -Actual $Sut.expression -Expected ([ArmStringValue]::New([ArmToken]::createQuotedString(0, '"')))
            }

            It "with empty quoted string" {
                $Sut = [ArmParser]::parse('""')
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.leftSquareBracketToken | Should -BeNullOrEmpty
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0

                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createQuotedString(0, '""')))
            }

            It "with non-empty quoted string" {
                $Sut = [ArmParser]::parse('"hello"')
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.LeftSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createQuotedString(0, '"hello"')))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0
            }

            It "with left square bracket (but no right square bracket)" {
                $Sut = [ArmParser]::parse("[")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                $Sut.Expression | Should -BeNullOrEmpty
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(0, 1), "Expected a right square bracket (']').")
                        [ArmIssue]::New([ArmSpan]::New(0, 1), "Expected a function or property expression.")
                    )
            }

            It "with two left square brackets" {
                $Sut = [ArmParser]::parse("[[")
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.LeftSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createLiteral(0, "[[")))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0
            }

            It "with two left square brackets and a right square bracket" {
                $Sut = [ArmParser]::parse("[[]")
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.LeftSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createLiteral(0, "[[]")))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0
            }

            It "with two left square brackets and a literal" {
                $Sut = [ArmParser]::parse("[[hello")
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.LeftSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createLiteral(0, "[[hello")))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0
            }

            It "with left and right square brackets" {
                $Sut = [ArmParser]::parse("[]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                $Sut.Expression | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(1))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(0, 2), "Expected a function or property expression."))
            }

            It "with left and right square brackets after whitespace" {
                $Sut = [ArmParser]::parse("  []")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(2))
                $Sut.Expression | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(3))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(2, 2), "Expected a function or property expression."))
            }

            It "with left and right square brackets with whitespace between them" {
                $Sut = [ArmParser]::parse("[    ]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                $Sut.Expression | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(5))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(0, 6), "Expected a function or property expression."))
            }

            It "with right square bracket" {
                $Sut = [ArmParser]::parse("']'")
                $Sut | Should -Not -BeNullOrEmpty
                $Sut.LeftSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmStringValue]::New([ArmToken]::createQuotedString(0, "']'")))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                $Sut.Errors | Should -HaveCount 0
            }

            It "with function name without parentheses, arguments, or right square bracket" {
                $Sut = [ArmParser]::parse("[concat")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.expression -Expected ([ArmFunctionValue]::New([ArmToken]::createLiteral(1, "concat"), $null, @(), @(), $null))
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(1, 6), "Missing function argument list.")
                        [ArmIssue]::New([ArmSpan]::New(6, 1), "Expected a right square bracket (']').")
                    )
            }

            It "with function name without parentheses or arguments" {
                $Sut = [ArmParser]::parse("[concat]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New([ArmToken]::createLiteral(1, "concat"), $null, @(), @(), $null))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(7))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(1, 6), "Missing function argument list."))
            }

            It "with function name and left parenthesis without right square bracket" {
                $Sut = [ArmParser]::parse("[concat (")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "concat"),
                        [ArmToken]::createLeftParenthesis(8),
                        @(),
                        @(),
                        $null
                    )
                )
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(8, 1), "Expected a right parenthesis (')').")
                        [ArmIssue]::New([ArmSpan]::New(8, 1), "Expected a right square bracket (']').")
                    )
            }

            It "with function name and left parenthesis" {
                $Sut = [ArmParser]::parse("[concat (]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "concat"),
                        [ArmToken]::createLeftParenthesis(8),
                        @(),
                        @(),
                        $null
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(9))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(9, 1), "Expected a right parenthesis (')')."))
            }

            It "with function name and right parenthesis" {
                $Sut = [ArmParser]::parse("[concat)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "concat"),
                        $null,
                        @(),
                        @(),
                        $null
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(8))
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(7, 1), "Expected the end of the string.")
                        [ArmIssue]::New([ArmSpan]::New(1, 6), "Missing function argument list.")
                    )
            }

            It "with function with no arguments" {
                $Sut = [ArmParser]::parse(" [ concat (    )  ]  ")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(1))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(3, "concat"),
                        [ArmToken]::createLeftParenthesis(10),
                        @(),
                        @(),
                        [ArmToken]::createRightParenthesis(15)
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(18))
                $Sut.Errors | Should -HaveCount 0
            }

            It "with function with one number argument" {
                $Sut = [ArmParser]::parse("[concat(12)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(11))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(10))
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected 1

                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected $concat
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createNumber(8, "12"))
            }

            It "with function with no closing double quote or right square bracket" {
                $Sut = [ArmParser]::parse("[concat()")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "concat"),
                        [ArmToken]::createLeftParenthesis(7),
                        @(),
                        @(),
                        [ArmToken]::createRightParenthesis(8)
                    )
                )
                $Sut.rightSquareBracketToken | Should -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(8, 1), "Expected a right square bracket (']')."))
            }

            It "with function with one string argument" {
                $Sut = [ArmParser]::parse("[concat('test')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(15))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(14))
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (1)
                $arg1 = $concat.ArgumentExpression[0]
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'test'"))
            }

            It "with function with one string argument with square brackets" {
                $Sut = [ArmParser]::parse("[concat('test@()')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(18))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(17))
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (1)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'test@()'"))
            }

            It "with function with one string argument and a comma" {
                $Sut = [ArmParser]::parse("[concat('test',)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(16))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(15, 1), "Expected a constant string, function, or property expression."))

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.CommaToken[0] -Expected ([ArmToken]::createComma(14))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (2)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'test'"))
                $arg2 = $concat.ArgumentExpression[1]
                Assert-Equivalent -Actual $arg2 -Expected ($null)
            }

            It "with function with missing first argument and string second argument" {
                $Sut = [ArmParser]::parse("[concat(,'test')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(16))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(8, 1), "Expected a constant string, function, or property expression."))

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.CommaToken[0] -Expected (([ArmToken]::createComma(8)))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (2)
                $arg1 = $concat.ArgumentExpression[0]
                Assert-Equivalent -Actual $arg1 -Expected ($null)
                $arg2 = $concat.ArgumentExpression[1]
                $arg2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg2.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg2.token -Expected ([ArmToken]::createQuotedString(9, "'test'"))
            }

            It "with function with one missing argument and no right parenthesis" {
                $Sut = [ArmParser]::parse("[concat('a1',")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ($null)
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(12, 1), "Expected a constant string, function, or property expression.")
                        [ArmIssue]::New([ArmSpan]::New(12, 1), "Expected a right square bracket (']').")
                    )

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.CommaToken[0] -Expected ([ArmToken]::createComma(12))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ($null)
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (2)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'a1'"))
                $arg2 = $concat.ArgumentExpression[1]
                Assert-Equivalent -Actual $arg2 -Expected ($null)
            }

            It "with function with three missing arguments" {
                $Sut = [ArmParser]::parse("[concat(,,)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "concat"),
                        [ArmToken]::createLeftParenthesis(7),
                        @(
                            ([ArmToken]::createComma(8))
                            ([ArmToken]::createComma(9))
                        ),
                        @(
                            $null
                            $null
                            $null
                        ),
                        [ArmToken]::createRightParenthesis(10)
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(11))
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(8, 1), "Expected a constant string, function, or property expression.")
                        [ArmIssue]::New([ArmSpan]::New(9, 1), "Expected a constant string, function, or property expression.")
                        [ArmIssue]::New([ArmSpan]::New(10, 1), "Expected a constant string, function, or property expression.")
                    )
            }

            It "with function with two arguments" {
                $Sut = [ArmParser]::parse("[concat('a', 'b')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(17))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(16))
                Assert-Equivalent -Actual $concat.CommaToken[0] -Expected ([ArmToken]::createComma(11))
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (2)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'a'"))
                $arg2 = $concat.ArgumentExpression[1]
                $arg2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg2.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg2.token -Expected ([ArmToken]::createQuotedString(13, "'b'"))
            }

            It "with function with three arguments" {
                $Sut = [ArmParser]::parse("[concat('a', 'b', 3)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(20))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(19))
                Assert-Equivalent -Actual $concat.CommaToken -Expected @(
                        ([ArmToken]::createComma(11))
                        ([ArmToken]::createComma(16))
                    )
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (3)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'a'"))
                $arg2 = $concat.ArgumentExpression[1]
                $arg2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg2.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg2.token -Expected ([ArmToken]::createQuotedString(13, "'b'"))
                $arg3 = $concat.ArgumentExpression[2]
                $arg3 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg3.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg3.token -Expected ([ArmToken]::createNumber(18, "3"))
            }

            It "with function with function argument" {
                $Sut = [ArmParser]::parse("[concat('a', add(5, 7), 3)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(26))
                $Sut.Errors | Should -HaveCount 0

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(25))
                Assert-Equivalent -Actual $concat.CommaToken -Expected @(
                        ([ArmToken]::createComma(11))
                        ([ArmToken]::createComma(22))
                    )
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (3)
                $concatarg1 = $concat.ArgumentExpression[0]
                $concatArg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concatArg1.parent -Expected $concat
                Assert-Equivalent -Actual $concatArg1.token -Expected ([ArmToken]::createQuotedString(8, "'a'"))
                $concatArg2 = $concat.ArgumentExpression[1]
                $concatArg2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concatArg2.parent -Expected $concat
                Assert-Equivalent -Actual $concatArg2.nameToken -Expected ([ArmToken]::createLiteral(13, "add"))
                Assert-Equivalent -Actual $concatArg2.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(16))
                Assert-Equivalent -Actual $concatArg2.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(21))
                Assert-Equivalent -Actual $concatArg2.CommaToken[0] -Expected ([ArmToken]::createComma(18))
                Assert-Equivalent -Actual $concatArg2.ArgumentExpression.length -Expected 2
                $addArg1 = $concatArg2.ArgumentExpression[0]
                $addArg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $addArg1.parent -Expected $concatArg2
                Assert-Equivalent -Actual $addArg1.token -Expected ([ArmToken]::createNumber(17, "5"))
                $addArg2 = $concatArg2.ArgumentExpression[1]
                $addArg2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $addArg2.parent -Expected $concatArg2
                Assert-Equivalent -Actual $addArg2.token -Expected ([ArmToken]::createNumber(20, "7"))
                $concatArg3 = $concat.ArgumentExpression[2]
                $concatArg3 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concatArg3.parent -Expected $concat
                Assert-Equivalent -Actual $concatArg3.token -Expected ([ArmToken]::createNumber(24, "3"))
            }

            It "with function with single single-quote argument" {
                $Sut = [ArmParser]::parse("[concat(')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ($null)
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(8, 3), "A constant string is missing an end quote.")
                        [ArmIssue]::New([ArmSpan]::New(10, 1), "Expected a right square bracket (']').")
                    )

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ($null)
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (1)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "')]"))
            }

            It "with function with missing comma between two arguments" {
                $Sut = [ArmParser]::parse("[concat('world'12)]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(18))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(15, 2), "Expected a comma (',')."))

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(17))
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (1)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'world'"))
            }

            It "with function with missing comma between three arguments" {
                $Sut = [ArmParser]::parse("[concat('world'12'again')]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(25))
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(15, 2), "Expected a comma (',').")
                        [ArmIssue]::New([ArmSpan]::New(17, 7), "Expected a comma (',').")
                    )

                $concat = $Sut.Expression
                $Concat | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $concat.parent -Expected ($null)
                Assert-Equivalent -Actual $concat.nameToken -Expected ([ArmToken]::createLiteral(1, "concat"))
                Assert-Equivalent -Actual $concat.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(7))
                Assert-Equivalent -Actual $concat.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(24))
                $Concat.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $concat.ArgumentExpression.length -Expected (1)
                $arg1 = $concat.ArgumentExpression[0]
                $arg1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $arg1.parent -Expected ($concat)
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(8, "'world'"))
            }

            It "with property access" {
                $Sut = [ArmParser]::parse("[resourceGroup().name]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(21))
                $Sut.Errors | Should -HaveCount 0

                $PropertyAccess = $Sut.expression
                $PropertyAccess | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $PropertyAccess.parent -Expected ($null)
                Assert-Equivalent -Actual $PropertyAccess.nameToken -Expected ([ArmToken]::createLiteral(17, "name"))
                Assert-Equivalent -Actual $PropertyAccess.periodToken -Expected ([ArmToken]::createPeriod(16))
                $resourceGroup = $PropertyAccess.source
                $ResourceGroup | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ResourceGroup.parent -Expected $PropertyAccess
                Assert-Equivalent -Actual $ResourceGroup.nameToken -Expected ([ArmToken]::createLiteral(1, "resourceGroup"))
                Assert-Equivalent -Actual $ResourceGroup.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(14))
                Assert-Equivalent -Actual $ResourceGroup.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                $ResourceGroup.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $ResourceGroup.ArgumentExpression -Expected @()
            }

            It "with property access with missing period" {
                $Sut = [ArmParser]::parse("[resourceGroup()name]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "resourceGroup"),
                        [ArmToken]::createLeftParenthesis(14),
                        @(),
                        @(),
                        [ArmToken]::createRightParenthesis(15)
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(20))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(16, 4), "Expected the end of the string."))
            }

            It "with quoted string instead of literal for property access" {
                $Sut = [ArmParser]::parse("[resourceGroup().'name']")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(23))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(17, 6), "Expected a literal value."))

                $PropertyAccess = $Sut.expression
                $PropertyAccess | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $PropertyAccess.parent -Expected ($null)
                Assert-Equivalent -Actual $PropertyAccess.nameToken -Expected ($null)
                Assert-Equivalent -Actual $PropertyAccess.periodToken -Expected ([ArmToken]::createPeriod(16))
                $resourceGroup = $PropertyAccess.source
                $ResourceGroup | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ResourceGroup.parent -Expected $PropertyAccess
                Assert-Equivalent -Actual $ResourceGroup.nameToken -Expected ([ArmToken]::createLiteral(1, "resourceGroup"))
                Assert-Equivalent -Actual $ResourceGroup.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(14))
                Assert-Equivalent -Actual $ResourceGroup.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                Assert-Equivalent -Actual $ResourceGroup.CommaToken -Expected @()
                Assert-Equivalent -Actual $ResourceGroup.ArgumentExpression -Expected @()
            }

            It "with .property access with missing property name" {
                $Sut = [ArmParser]::parse("[resourceGroup().]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(17))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(17, 1), "Expected a literal value."))

                $PropertyAccess = $Sut.expression
                $PropertyAccess | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $PropertyAccess.parent -Expected ($null)
                Assert-Equivalent -Actual $PropertyAccess.nameToken -Expected ($null)
                Assert-Equivalent -Actual $PropertyAccess.periodToken -Expected ([ArmToken]::createPeriod(16))
                $resourceGroup= $PropertyAccess.source
                $ResourceGroup | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ResourceGroup.parent -Expected $PropertyAccess
                Assert-Equivalent -Actual $ResourceGroup.nameToken -Expected ([ArmToken]::createLiteral(1, "resourceGroup"))
                Assert-Equivalent -Actual $ResourceGroup.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(14))
                Assert-Equivalent -Actual $ResourceGroup.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                Assert-Equivalent -Actual $ResourceGroup.CommaToken -Expected @()
                Assert-Equivalent -Actual $ResourceGroup.ArgumentExpression -Expected @()
            }

            It "with a two-deep property access" {
                $Sut = [ArmParser]::parse("[resourceGroup().name.length]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(28))
                $Sut.Errors | Should -HaveCount 0

                $length = $Sut.expression
                $length | Should -Not -BeNullOrEmpty
                $length.parent | Should -BeNullOrEmpty $null
                Assert-Equivalent -Actual $length.nameToken -Expected ([ArmToken]::createLiteral(22, "length"))
                Assert-Equivalent -Actual $length.periodToken -Expected ([ArmToken]::createPeriod(21))
                $name = $length.source
                $name | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $name.parent -Expected $length
                Assert-Equivalent -Actual $name.nameToken -Expected ([ArmToken]::createLiteral(17, "name"))
                Assert-Equivalent -Actual $name.periodToken -Expected ([ArmToken]::createPeriod(16))
                $resourceGroup= $name.source
                $ResourceGroup | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ResourceGroup.parent -Expected $name
                Assert-Equivalent -Actual $ResourceGroup.nameToken -Expected ([ArmToken]::createLiteral(1, "resourceGroup"))
                Assert-Equivalent -Actual $ResourceGroup.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(14))
                Assert-Equivalent -Actual $ResourceGroup.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(15))
                Assert-Equivalent -Actual $ResourceGroup.CommaToken -Expected @()
                Assert-Equivalent -Actual $ResourceGroup.ArgumentExpression -Expected @()
            }

            It "with array access" {
                $Sut = [ArmParser]::parse("[variables('a')[15]]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(19))
                $Sut.Errors | Should -HaveCount 0

                $arrayAccess = $Sut.Expression
                $arrayAccess | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ArrayAccess.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(18))
                $index = $ArrayAccess.index
                $index | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $index.parent -Expected $ArrayAccess
                Assert-Equivalent -Actual $index.token  -Expected  ([ArmToken]::createNumber(16, "15"))
                Assert-Equivalent -Actual $ArrayAccess.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(15))
                $variables = $ArrayAccess.source
                $variables | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $variables.parent -Expected $ArrayAccess
                Assert-Equivalent -Actual $variables.nameToken -Expected ([ArmToken]::createLiteral(1, "variables"))
                Assert-Equivalent -Actual $variables.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(10))
                Assert-Equivalent -Actual $variables.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(14))
                $variables.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $variables.ArgumentExpression.length -Expected 1
                $arg1 = $variables.ArgumentExpression[0]
                Assert-Equivalent -Actual $arg1.parent -Expected $variables
                Assert-Equivalent -Actual $arg1.token -Expected ([ArmToken]::createQuotedString(11, "'a'"))
            }

            It "with two array accesses" {
                $Sut = [ArmParser]::parse("[variables('a')[15]['fido']]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(27))
                $Sut.Errors | Should -HaveCount 0

                $ArrayAccess1 = $Sut.expression
                $arrayAccess1 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ArrayAccess1.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(26))
                Assert-Equivalent -Actual $ArrayAccess1.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(19))
                $fido = $ArrayAccess1.index
                $fido | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $fido.parent -Expected $ArrayAccess1
                Assert-Equivalent -Actual $fido.token -Expected ([ArmToken]::createQuotedString(20, "'fido'"))
                $ArrayAccess2 = $ArrayAccess1.source
                $arrayAccess2 | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ArrayAccess2.parent -Expected $ArrayAccess1
                Assert-Equivalent -Actual $ArrayAccess2.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(18))
                Assert-Equivalent -Actual $ArrayAccess2.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(15))
                $fifteen = $ArrayAccess2.index
                $fifteen | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $fifteen.parent -Expected $ArrayAccess2
                Assert-Equivalent -Actual $fifteen.token -Expected ([ArmToken]::createNumber(16, "15"))
                $variables= $ArrayAccess2.source
                $variables | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $variables.parent -Expected $ArrayAccess2
                Assert-Equivalent -Actual $variables.nameToken -Expected ([ArmToken]::createLiteral(1, "variables"))
                Assert-Equivalent -Actual $variables.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(10))
                Assert-Equivalent -Actual $variables.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(14))
                $variables.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $variables.ArgumentExpression.length -Expected 1
                $a = $variables.ArgumentExpression[0]
                $a | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $a.parent -Expected $variables
                Assert-Equivalent -Actual $a.token -Expected ([ArmToken]::createQuotedString(11, "'a'"))
            }

            It "with array access with function index" {
                $Sut = [ArmParser]::parse("[variables('a')[add(12,3)]]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(26))
                $Sut.Errors | Should -HaveCount 0

                $ArrayAccess = $Sut.expression
                $arrayAccess | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $ArrayAccess.parent -Expected $null
                Assert-Equivalent -Actual $ArrayAccess.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(25))
                Assert-Equivalent -Actual $ArrayAccess.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(15))
                $add = $ArrayAccess.index
                $add | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $add.parent -Expected $ArrayAccess
                Assert-Equivalent -Actual $add.nameToken -Expected ([ArmToken]::createLiteral(16, "add"))
                Assert-Equivalent -Actual $add.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(19))
                Assert-Equivalent -Actual $add.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(24))
                Assert-Equivalent -Actual $add.CommaToken[0] -Expected ([ArmToken]::createComma(22))
                Assert-Equivalent -Actual $add.ArgumentExpression.length -Expected 2
                $addArg1 = $add.ArgumentExpression[0]
                Assert-Equivalent -Actual $addArg1.parent -Expected $add
                Assert-Equivalent -Actual $addArg1.token -Expected ([ArmToken]::createNumber(20, "12"))
                $addArg2 = $add.ArgumentExpression[1]
                Assert-Equivalent -Actual $addArg2.parent -Expected $add
                Assert-Equivalent -Actual $addArg2.token -Expected ([ArmToken]::createNumber(23, "3"))
                $variables = $ArrayAccess.source
                $variables | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $variables.parent -Expected $ArrayAccess
                Assert-Equivalent -Actual $variables.nameToken -Expected ([ArmToken]::createLiteral(1, "variables"))
                Assert-Equivalent -Actual $variables.leftParenthesisToken -Expected ([ArmToken]::createLeftParenthesis(10))
                Assert-Equivalent -Actual $variables.rightParenthesisToken -Expected ([ArmToken]::createRightParenthesis(14))
                $variables.CommaToken | Should -HaveCount 0
                Assert-Equivalent -Actual $variables.ArgumentExpression.length -Expected 1
                $a = $variables.ArgumentExpression[0]
                $a | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $a.parent -Expected $variables
                Assert-Equivalent -Actual $a.token -Expected ([ArmToken]::createQuotedString(11, "'a'"))
            }

            It "with function after string" {
                $Sut = [ArmParser]::parse("[hello()'world']")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "hello"),
                        [ArmToken]::createLeftParenthesis(6),
                        @(),
                        @(),
                        [ArmToken]::createRightParenthesis(7)
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(15))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(8, 7), "Expected the end of the string."))
            }

            It "with function after string" {
                $Sut = [ArmParser]::parse("[hello'world'()]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "hello"),
                        [ArmToken]::createLeftParenthesis(13),
                        @(),
                        @(),
                        [ArmToken]::createRightParenthesis(14)
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(15))
                Assert-Equivalent -Actual $Sut.Errors[0] -Expected ([ArmIssue]::New([ArmSpan]::New(6, 7), "Expected the end of the string."))
            }

            It "with string followed by literal" {
                $Sut = [ArmParser]::parse("['world'hello]")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(8, "hello"),
                         $null,
                        @(),
                        @(),
                         $null
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(13))
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(1, 7), "Expected a literal value.")
                        [ArmIssue]::New([ArmSpan]::New(8, 5), "Missing function argument list.")
                    )
            }

            It "with literal followed by string" {
                $Sut = [ArmParser]::parse("[hello'world']")
                $Sut | Should -Not -BeNullOrEmpty
                Assert-Equivalent -Actual $Sut.leftSquareBracketToken -Expected ([ArmToken]::createLeftSquareBracket(0))
                Assert-Equivalent -Actual $Sut.Expression -Expected ([ArmFunctionValue]::New(
                        [ArmToken]::createLiteral(1, "hello"),
                        $null,
                        @(),
                        @(),
                        $null
                    )
                )
                Assert-Equivalent -Actual $Sut.rightSquareBracketToken -Expected ([ArmToken]::createRightSquareBracket(13))
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(6, 7), "Expected the end of the string.")
                        [ArmIssue]::New([ArmSpan]::New(1, 5), "Missing function argument list.")
                    )
            }

            It "with [concat(parameters('_artifactsLocation'), '/', '/scripts/azuremysql.sh', parameters('_artifactsLocationSasToken'))], )]"{
                $Sut = [ArmParser]::parse("[concat(parameters('_artifactsLocation'), '/', '/scripts/azuremysql.sh', parameters('_artifactsLocationSasToken'))], )]")
                Assert-Equivalent -Actual $Sut.Errors -Expected @(
                        [ArmIssue]::New([ArmSpan]::New(115, 1), "Nothing should exist after the closing ']' except for whitespace.")
                        [ArmIssue]::New([ArmSpan]::New(117, 1), "Nothing should exist after the closing ']' except for whitespace.")
                        [ArmIssue]::New([ArmSpan]::New(118, 1), "Nothing should exist after the closing ']' except for whitespace.")
                    )
            }
        }
    }
}
