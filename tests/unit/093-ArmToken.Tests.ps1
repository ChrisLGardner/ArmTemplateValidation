# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmToken" -Tag "ArmToken" {

        Context "Testing createLeftParenthesis(number)" {
            It "Should Negative startIndex" {
                $Sut = [ArmToken]::createLeftParenthesis(-1)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(-1, 1))
                $Sut.StringValue | Should -Be "("
            }

            It "Should Zero startIndex" {
                $Sut = [ArmToken]::createLeftParenthesis(0)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(0, 1))
                $Sut.StringValue | Should -Be "("
            }

            It "Should Positive startIndex" {
                $Sut = [ArmToken]::createLeftParenthesis(7)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(7, 1))
                $Sut.StringValue | Should -Be "("
            }
        }

        Context "Testing createRightParenthesis(number)" {
            It "Should Negative startIndex" {
                $Sut = [ArmToken]::createRightParenthesis(-1)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(-1, 1))
                $Sut.StringValue | Should -Be ")"
            }

            It "Should Zero startIndex" {
                $Sut = [ArmToken]::createRightParenthesis(0)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(0, 1))
                $Sut.StringValue | Should -Be ")"
            }

            It "Should Positive startIndex" {
                $Sut = [ArmToken]::createRightParenthesis(7)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightParenthesis)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(7, 1))
                $Sut.StringValue | Should -Be ")"
            }
        }

        Context "Testing createLeftSquareBracket(number)" {
            It "Should Negative startIndex" {
                $Sut = [ArmToken]::createLeftSquareBracket(-1)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(-1, 1))
                $Sut.StringValue | Should -Be "["
            }

            It "Should Zero startIndex" {
                $Sut = [ArmToken]::createLeftSquareBracket(0)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(0, 1))
                $Sut.StringValue | Should -Be "["
            }

            It "Should Positive startIndex" {
                $Sut = [ArmToken]::createLeftSquareBracket(7)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::LeftSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(7, 1))
                $Sut.StringValue | Should -Be "["
            }
        }

        Context "Testing createRightSquareBracket(number)" {
            It "Should Negative startIndex" {
                $Sut = [ArmToken]::createRightSquareBracket(-1)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(-1, 1))
                $Sut.StringValue | Should -Be "]"
            }

            It "Should Zero startIndex" {
                $Sut = [ArmToken]::createRightSquareBracket(0)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(0, 1))
                $Sut.StringValue | Should -Be "]"
            }

            It "Should Positive startIndex" {
                $Sut = [ArmToken]::createRightSquareBracket(7)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::RightSquareBracket)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(7, 1))
                $Sut.StringValue | Should -Be "]"
            }
        }

        Context "Testing createComma(number)" {
            It "Should Negative startIndex" {
                $Sut = [ArmToken]::createComma(-1)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::Comma)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(-1, 1))
                $Sut.StringValue | Should -Be ","
            }

            It "Should Zero startIndex" {
                $Sut = [ArmToken]::createComma(0)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::Comma)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(0, 1))
                $Sut.StringValue | Should -Be ","
            }

            It "Should Positive startIndex" {
                $Sut = [ArmToken]::createComma(7)
                $Sut.GetTokenType() | Should -Be ([ArmTokenType]::Comma)
                Assert-Equivalent -Actual $Sut.Span -Expected ([ArmSpan]::New(7, 1))
                $Sut.StringValue | Should -Be ","
            }
        }
    }
}
