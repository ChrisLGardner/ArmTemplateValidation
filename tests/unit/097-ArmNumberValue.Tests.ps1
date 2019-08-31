# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/a2973e0a18b77380e8158910c7d12e1d8d5e71b5/test/TLE.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmNumberValue" -Tag "ArmNumberValue" {

        Context "contains(number)" {
            It "with character index less than start index" {
                $value = [ArmNumberValue]::New([ArmToken]::createNumber(3, "1"))
                $value.contains(0) | Should -Be $false
            }

            It "with character index equal to start index" {
                $value = [ArmNumberValue]::New([ArmToken]::createNumber(3, "17"))
                $Value.contains(3) | Should -Be $true
            }

            It "with character index inside value" {
                $value = [ArmNumberValue]::New([ArmToken]::createNumber(3, "1235235"))
                $Value.contains(7) | Should -Be $true
            }

            It "with character index after end index" {
                $value = [ArmNumberValue]::New([ArmToken]::createNumber(3, "1237"))
                $Value.contains(7) | Should -Be $true
            }

            It "with character index after end index" {
                $value = [ArmNumberValue]::New([ArmToken]::createNumber(3, "1237"))
                $Value.contains(7) | Should -Be $true
            }
        }
    }
}
