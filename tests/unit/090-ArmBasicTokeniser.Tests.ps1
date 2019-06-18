# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a7b24dc6f5d31c5fc48b34d0f16f99b24e1f4de1/test/Tokenizer.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmBasicTokeniser" -Tag "ArmBasicTokeniser" {

        Context "Testing constructor" {

            $ConstructorTestCases = @(
                @{
                    InputString = $null
                }
                @{
                    InputString = ""
                }
                @{
                    InputString = "hello"
                }
            )

            It "Should do something with <InputString>" {
                param (
                    $InputString
                )
                $Sut = [ArmBasicTokeniser]::New($InputString)

                $Sut.hasStarted() | Should -Be $false
                $Sut.current() | Should -Be $null
            } -TestCases $ConstructorTestCases
        }

        Context "Testing next() method" {
            $NextMethodTestCases = @(
                @{
                    InputString = $null
                    Result = $null
                }
                @{
                    InputString = ""
                    Result = $null
                }
                @{
                    InputString = "{"
                    Result = [ArmBasicToken]::New("{", [ArmBasicTokenType]::LeftCurlyBracket)
                }
                @{
                    InputString = "}"
                    Result = [ArmBasicToken]::New("}", [ArmBasicTokenType]::RightCurlyBracket)
                }
                @{
                    InputString = "["
                    Result = [ArmBasicToken]::New("[", [ArmBasicTokenType]::LeftSquareBracket)
                }
                @{
                    InputString = "]"
                    Result = [ArmBasicToken]::New("]", [ArmBasicTokenType]::RightSquareBracket)
                }
                @{
                    InputString = "("
                    Result = [ArmBasicToken]::New("(", [ArmBasicTokenType]::LeftParenthesis)
                }
                @{
                    InputString = ")"
                    Result = [ArmBasicToken]::New(")", [ArmBasicTokenType]::RightParenthesis)
                }
                @{
                    InputString = "_"
                    Result = [ArmBasicToken]::New("_", [ArmBasicTokenType]::Underscore)
                }
                @{
                    InputString = "."
                    Result = [ArmBasicToken]::New(".", [ArmBasicTokenType]::Period)
                }
                @{
                    InputString = "-"
                    Result = [ArmBasicToken]::New("-", [ArmBasicTokenType]::Dash)
                }
                @{
                    InputString = "+"
                    Result = [ArmBasicToken]::New("+", [ArmBasicTokenType]::Plus)
                }
                @{
                    InputString = ","
                    Result = [ArmBasicToken]::New(",", [ArmBasicTokenType]::Comma)
                }
                @{
                    InputString = ":"
                    Result = [ArmBasicToken]::New(":", [ArmBasicTokenType]::Colon)
                }
                @{
                    InputString = "'"
                    Result = [ArmBasicToken]::New("'", [ArmBasicTokenType]::SingleQuote)
                }
                @{
                    InputString = '"'
                    Result = [ArmBasicToken]::New('"', [ArmBasicTokenType]::DoubleQuote)
                }
                @{
                    InputString = "\"
                    Result = [ArmBasicToken]::New("\", [ArmBasicTokenType]::BackSlash)
                }
                @{
                    InputString = "/"
                    Result = [ArmBasicToken]::New("/", [ArmBasicTokenType]::ForwardSlash)
                }
                @{
                    InputString = "*"
                    Result = [ArmBasicToken]::New("*", [ArmBasicTokenType]::Asterisk)
                }
                @{
                    InputString = " "
                    Result = [ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space)
                }
                @{
                    InputString = "   "
                    Result = @(
                        [ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space)
                        [ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space)
                        [ArmBasicToken]::New(" ", [ArmBasicTokenType]::Space)
                    )
                }
                @{
                    InputString = "hello"
                    Result = [ArmBasicToken]::New("hello", [ArmBasicTokenType]::Letters)
                }
                @{
                    InputString = "a"
                    Result = [ArmBasicToken]::New("a", [ArmBasicTokenType]::Letters)
                }
                @{
                    InputString = "Z"
                    Result = [ArmBasicToken]::New("Z", [ArmBasicTokenType]::Letters)
                }
                @{
                    InputString = "1"
                    Result = [ArmBasicToken]::New("1", [ArmBasicTokenType]::Digits)
                }
                @{
                    InputString = "1234"
                    Result = [ArmBasicToken]::New("1234", [ArmBasicTokenType]::Digits)
                }
                @{
                    InputString = "#"
                    Result = [ArmBasicToken]::New("#",[ArmBasicTokenType]::Unrecognized)
                }
                @{
                    InputString = "^"
                    Result = [ArmBasicToken]::New("^",[ArmBasicTokenType]::Unrecognized)
                }
            )

            It "Should do something else with '<InputString>'" {
                param (
                    $InputString,
                    $Result
                )
                $Sut = [ArmBasicTokeniser]::New($InputString)

                foreach ($ExpectedToken in ($Result -as [ArmBasicToken[]])){
                    $Sut.moveNext()
                    $Sut.hasStarted() | Should -Be $true
                    Assert-Equivalent -Actual $Sut.current() -Expected $expectedToken
                }

                for ($i = 0; $i -lt 2;++$i) {
                    $Sut.moveNext()
                    $Sut.hasStarted() | Should -Be $true
                    $Sut.current() | Should -Be $null
                }
            } -TestCases $NextMethodTestCases
        }
    }
}
