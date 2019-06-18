# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmFunctionValue" -Tag "ArmFunctionValue" {
        Context "Testing constructor" {
             It "Should throw with null nameToken" {
                $leftParenthesis = [ArmToken]::createLeftParenthesis(5)
                $CommaToken = @()
                $arguments = @()
                $rightParenthesis = [ArmToken]::createRightParenthesis(10)
                { [ArmFunctionValue]::New($null, $leftParenthesis, $CommaToken, $arguments, $rightParenthesis) } | Should -Throw
            }

             It "Should not throw with null leftParenthesisToken" {
                $name = [ArmToken]::createLiteral(1, "test")
                $CommaToken = @()
                $arguments = @()
                $rightParenthesis = [ArmToken]::createRightParenthesis(10)

                $Sut = [ArmFunctionValue]::New($name, $null, $CommaToken, $arguments, $rightParenthesis)

                Assert-Equivalent -Actual $Sut.nameToken -Expected ($name)
                $Sut.leftParenthesisToken | Should -BeNullOrEmpty
                $Sut.argumentExpression | Should -HaveCount 0
                Assert-Equivalent -Actual $Sut.rightParenthesisToken -Expected ($rightParenthesis)
            }

             It "Should throw with null argumentExpression" {
                $name = [ArmToken]::createLiteral(1, "test")
                $CommaToken = @()
                $leftParenthesis = [ArmToken]::createLeftParenthesis(5)
                $rightParenthesis = [ArmToken]::createRightParenthesis(10)

                { [ArmFunctionValue]::New($name, $leftParenthesis, $CommaToken, $null, $rightParenthesis) } | Should -Throw
            }

             It "Should not throw with null rightParenthesisToken" {
                $name = [ArmToken]::createLiteral(1, "test")
                $CommaToken = @()
                $leftParenthesis = [ArmToken]::createLeftParenthesis(5)
                $arguments = @()

                $Sut = [ArmFunctionValue]::New($name, $leftParenthesis, $CommaToken, $arguments, $null)

                Assert-Equivalent -Actual $Sut.nameToken -Expected ($name)
                Assert-Equivalent -Actual $Sut.leftParenthesisToken -Expected ($leftParenthesis)
                $Sut.argumentExpression | Should -HaveCount 0
                $Sut.rightParenthesisToken | Should -BeNullOrEmpty
            }
        }

        Context "Testing getSpan()" {

            BeforeEach {
                [ArmParser]::Errors = @()
            }

            It "Should with name" {
                $Sut = [ArmParser]::Parse("[concat]").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 6))
            }

            It "Should with left parenthesis" {
                $Sut = [ArmParser]::Parse("[concat(]").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 7))
            }

            It "Should with one argument and no right parenthesis" {
                $Sut = [ArmParser]::Parse("[concat(70").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 7))
            }

            It "Should with two arguments and no right parenthesis" {
                $Sut = [ArmParser]::Parse("[concat(70, 3").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 10))
            }

            It "Should with left and right parenthesis and no arguments" {
                $Sut = [ArmParser]::Parse("[concat()").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 8))
            }

            It "Should with left and right parenthesis and arguments" {
                $Sut = [ArmParser]::Parse("[concat('hello', 'world')").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 24))
            }

            It "Should with last argument missing and no right parenthesis" {
                $Sut = [ArmParser]::Parse("[concat('hello',").expression
                $Sut.GetType() | Should -Be "ArmFunctionValue"
                Assert-Equivalent -Actual $Sut.GetSpan() -Expected ([ArmSpan]::New(1, 15))
            }
        }
    }
}
