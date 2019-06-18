# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a7b24dc6f5d31c5fc48b34d0f16f99b24e1f4de1/test/Tokenizer.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmBasicToken" -Tag "ArmBasicToken" {

        Context "Testing Constructor" {

            $ConstructorTestCases = @(
                @{
                    InputString = "("
                    InputType = [ArmBasicTokenType]::LeftParenthesis
                }
                @{
                    InputString = "hello"
                    InputType = [ArmBasicTokenType]::Letters
                }
            )

            It "Should do other thing with <InputString> and it's type" {
                param (
                    $InputString,
                    $InputType
                )

                $Sut = [ArmBasicToken]::New($InputString, $InputType)

                $Sut.toString() | Should -Be $InputString
                $Sut.length() | Should -Be $InputString.length
                $Sut.GetTokenType() | Should -Be $InputType
            } -TestCases $ConstructorTestCases
        }

        Context "Testing pre-created tokens" {

            It "Should have LeftCurlyBracket variable be the same as a new '{' token" {
                $Compare = [ArmBasicToken]::New('{',[ArmBasicTokenType]::LeftCurlyBracket)

                Assert-Equivalent -Actual $Script:LeftCurlyBracket -Expected $Compare
            }

            It "Should have RightCurlyBracket variable be the same as a new '}' token" {
                Assert-Equivalent -Actual $Script:RightCurlyBracket -Expected ([ArmBasicToken]::New("}", [ArmBasicTokenType]::RightCurlyBracket))
            }

            It "Should have LeftSquareBracket variable be the same as a new '[' token" {
                Assert-Equivalent -Actual $Script:LeftSquareBracket -Expected ([ArmBasicToken]::New("[", [ArmBasicTokenType]::LeftSquareBracket))
            }

            It "Should have RightSquareBracket variable be the same as a new ']' token" {
                Assert-Equivalent -Actual $Script:RightSquareBracket -Expected ([ArmBasicToken]::New("]", [ArmBasicTokenType]::RightSquareBracket))
            }

            It "Should have LeftParenthesis variable be the same as a new '(' token" {
                Assert-Equivalent -Actual $Script:LeftParenthesis -Expected ([ArmBasicToken]::New("(", [ArmBasicTokenType]::LeftParenthesis))
            }

            It "Should have RightParenthesis variable be the same as a new ')' token" {
                Assert-Equivalent -Actual $Script:RightParenthesis -Expected ([ArmBasicToken]::New(")", [ArmBasicTokenType]::RightParenthesis))
            }

            It "Should have Underscore variable be the same as a new '_' token" {
                Assert-Equivalent -Actual $Script:Underscore -Expected ([ArmBasicToken]::New("_", [ArmBasicTokenType]::Underscore))
            }

            It "Should have Period variable be the same as a new '.' token" {
                Assert-Equivalent -Actual $Script:Period -Expected ([ArmBasicToken]::New(".", [ArmBasicTokenType]::Period))
            }

            It "Should have Dash variable be the same as a new '-' token" {
                Assert-Equivalent -Actual $Script:Dash -Expected ([ArmBasicToken]::New("-", [ArmBasicTokenType]::Dash))
            }

            It "Should have Plus variable be the same as a new '+' token" {
                Assert-Equivalent -Actual $Script:Plus -Expected ([ArmBasicToken]::New("+", [ArmBasicTokenType]::Plus))
            }

            It "Should have Comma variable be the same as a new ',' token" {
                Assert-Equivalent -Actual $Script:Comma -Expected ([ArmBasicToken]::New(",", [ArmBasicTokenType]::Comma))
            }

            It "Should have Colon variable be the same as a new ':' token" {
                Assert-Equivalent -Actual $Script:Colon -Expected ([ArmBasicToken]::New(":", [ArmBasicTokenType]::Colon))
            }

            It "Should have SingleQuote variable be the same as a new ' token" {
                Assert-Equivalent -Actual $Script:SingleQuote -Expected ([ArmBasicToken]::New("'", [ArmBasicTokenType]::SingleQuote))
            }

            It 'Should have DoubleQuote variable be the same as a new " token' {
                Assert-Equivalent -Actual $Script:DoubleQuote -Expected ([ArmBasicToken]::New('"', [ArmBasicTokenType]::DoubleQuote))
            }

            It "Should have Backslash variable be the same as a new '\' token" {
                Assert-Equivalent -Actual $Script:Backslash -Expected ([ArmBasicToken]::New("\", [ArmBasicTokenType]::Backslash))
            }

            It "Should have ForwardSlash variable be the same as a new '/' token" {
                Assert-Equivalent -Actual $Script:ForwardSlash -Expected ([ArmBasicToken]::New("/", [ArmBasicTokenType]::ForwardSlash))
            }

            It "Should have Asterisk variable be the same as a new '*' token" {
                Assert-Equivalent -Actual $Script:Asterisk -Expected ([ArmBasicToken]::New("*", [ArmBasicTokenType]::Asterisk))
            }

            It "Should have Space variable be the same as a new ' ' token" {
                Assert-Equivalent -Actual $Script:Space -Expected ([ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space))
            }
        }
    }
}
