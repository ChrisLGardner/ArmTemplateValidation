# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmStringValue" -Tag "ArmStringValue" {
        Context "constructor()" {
            It "throws with null token" {
                {[ArmStringValue]::New($null)} | Should -Throw
            }
        }

        Context "contains(number)" {
            It "Should return false with character index less than start index" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello'"))
                $Sut.contains(4) | Should -Be $false
            }

            It "Should return true with character index equal to start index" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello'"))
                $Sut.Contains(5) | Should -Be $true
            }

            It "Should return true with character index inside value" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello'"))
                $Sut.Contains(7) | Should -Be $true
            }

            It "Should return true with character index equal to after end index with closing quote" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello'"))
                $Sut.Contains(12) | Should -Be $true
            }

            It "Should return true with character index equal to after end index without closing quote" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello"))
                $Sut.Contains(11) | Should -Be $true
            }

            It "Should return false with character index past after end index with closing quote" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello'"))
                $Sut.Contains(13) | Should -Be $false
            }

            It "Should return false with character index past after end index without closing quote" {
                $Sut = [ArmStringValue]::New([ArmToken]::createQuotedString(5, "'hello"))
                $Sut.Contains(13) | Should -Be $false
            }
        }
    }
}
