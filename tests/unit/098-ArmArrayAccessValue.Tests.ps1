# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmArrayAccessValue" -Tag "ArmArrayAccessValue" {

        Context "constructor" {
            It "with null _source" {
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(6)
                $index = [ArmNumberValue]::New([ArmToken]::createNumber(7, "3"))
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(8)
                { [ArmArrayAccessValue]::New($null, $leftSquareBracket, $index, $rightSquareBracket)} | Should -Throw
            }

            It "with null _leftSquareBracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $index = [ArmNumberValue]::New([ArmToken]::createNumber(7, "3"))
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(8)
                { [ArmArrayAccessValue]::New($Source, $null, $index, $rightSquareBracket) } | Should -Throw
            }

            It "with null _index" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(6)
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(8)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $rightSquareBracket)
                Assert-Equivalent -Actual $Source -Expected $arrayAccess.source
                Assert-Equivalent -Actual $leftSquareBracket -Expected $arrayAccess.leftSquareBracketToken
                Assert-Equivalent -Actual $null -Expected $arrayAccess.index
                Assert-Equivalent -Actual $rightSquareBracket -Expected $arrayAccess.rightSquareBracketToken
            }

            It "with null _rightSquareBracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(6)
                $index = [ArmNumberValue]::New([ArmToken]::createNumber(7, "3"))
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $index, $null)
                Assert-Equivalent -Actual $Source -Expected $arrayAccess.source
                Assert-Equivalent -Actual $leftSquareBracket -Expected $arrayAccess.leftSquareBracketToken
                Assert-Equivalent -Actual $index -Expected $arrayAccess.index
                Assert-Equivalent -Actual $null -Expected $arrayAccess.rightSquareBracketToken
            }

        }

        Context "getSpan()" {
            It "with no index or right square bracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(6)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $null)
                Assert-Equivalent -Actual $arrayAccess.getSpan() -Expected ([ArmSpan]::New(5, 2))
            }

            It "with whitespace between source and left square bracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(8)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $null)
                Assert-Equivalent -Actual $arrayAccess.getSpan() -Expected ([ArmSpan]::New(5,4))
            }

            It "with no right square bracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(8)
                $index = [ArmNumberValue]::New([ArmToken]::createNumber(10, "10"))
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $index, $null)
                Assert-Equivalent -Actual $arrayAccess.getSpan() -Expected ([ArmSpan]::New(5, 7))
            }

            It "with no index" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(8)
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(12)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $rightSquareBracket)
                Assert-Equivalent -Actual $arrayAccess.getSpan() -Expected ([ArmSpan]::New(5, 8))
            }

            It "with complete array access" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(8)
                $index = [ArmNumberValue]::New([ArmToken]::createNumber(10, "10"))
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(12)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $index, $rightSquareBracket)
                Assert-Equivalent -Actual $arrayAccess.getSpan() -Expected ([ArmSpan]::New(5, 8))
            }
        }

        Context "toString()" {
            It "with no index or right square bracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(10)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $null)
                Assert-Equivalent -Actual $arrayAccess.toString() -Expected "2["
            }

            It "with no right square bracket" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(10)
                $index = [ArmStringValue]::New([ArmToken]::createQuotedString(20, "'hello'"))
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $index, $null)
                Assert-Equivalent -Actual $arrayAccess.toString() -Expected "2['hello'"
            }

            It "with no index" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(10)
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(30)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $null, $rightSquareBracket)
                Assert-Equivalent -Actual $arrayAccess.toString() -Expected "2[]"
            }

            It "with a complete array access" {
                $source = [ArmNumberValue]::New([ArmToken]::createNumber(5, "2"))
                $leftSquareBracket = [ArmToken]::createLeftSquareBracket(10)
                $index = [ArmStringValue]::New([ArmToken]::createQuotedString(20, "'hello'"))
                $rightSquareBracket = [ArmToken]::createRightSquareBracket(30)
                $arrayAccess = [ArmArrayAccessValue]::New($Source, $leftSquareBracket, $index, $rightSquareBracket)
                Assert-Equivalent -Actual $arrayAccess.toString() -Expected "2['hello']"
            }
        }
    }
}
