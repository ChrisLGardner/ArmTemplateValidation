# Based on tests from the ARM tools VS Code extension
# https://github.com/microsoft/vscode-azurearmtools/blob/69198cd81ddead89492a257167c9dad6eb724a25/test/Language.test.ts
using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {
    Describe "Testing ArmSpan" -Tag "ArmSpan" {
        Context "constructor()" {
            $ConstructorTestCases = @(
                @{
                    startIndex = -1
                    length = 3
                }
                @{
                    startIndex = 0
                    length = 3
                }
                @{
                    startIndex = 10
                    length = -3
                }
                @{
                    startIndex = 11
                    length = 0
                }
                @{
                    startIndex = 21
                    length = 3
                }
            )

            It "with <startIndex> <length>" {
                param (
                    $StartIndex,
                    $Length
                )


                $Sut = [ArmSpan]::New($StartIndex, $length)
                $Sut.startIndex | Should -Be $startIndex
                $Sut.length | Should -Be $length
                $Sut.afterEndIndex() | Should -Be ($startIndex + $length) -Because "Wrong afterEndIndex"

                if ($length -gt 0) {
                    $length--
                }
                else {
                    $Length = 0
                }
                $Sut.endIndex() | Should -Be ($startIndex + $length) -Because "Wrong endIndex"
            } -TestCases $ConstructorTestCases
        }

        Context "contains()" {
            It "With index less than startIndex" {
                [ArmSpan]::New(3, 4).contains(2, $false) | Should -Be $false
            }

            It "With index equal to startIndex" {
                [ArmSpan]::New(3, 4).contains(3, $false) | Should -Be $true
            }

            It "With index between the start and end indexes" {
                [ArmSpan]::New(3, 4).contains(5, $false) | Should -Be $true
            }

            It "With index equal to endIndex" {
                [ArmSpan]::New(3, 4).contains(6, $false) | Should -Be $true
            }

            It "With index directly after end index" {
                [ArmSpan]::New(3, 4).contains(7, $false) | Should -Be $false
            }
        }

        Context "union()" {
            It "With null" {
                $Sut = [ArmSpan]::New(5, 7)
                Assert-Equivalent -Actual $Sut.union($null) -Expected $Sut
            }

            It "With same span" {
                $Sut = [ArmSpan]::New(5, 7)
                Assert-Equivalent -Actual $Sut.union($Sut) -Expected $Sut
            }

            It "With equal span" {
                $Sut = [ArmSpan]::New(5, 7)
                Assert-Equivalent -Actual $Sut.union([ArmSpan]::New(5, 7)) -Expected $Sut
            }

            It "With subset span" {
                $Sut = [ArmSpan]::New(5, 17)
                Assert-Equivalent -Actual $Sut.union([ArmSpan]::New(10, 2)) -Expected $Sut
            }
        }

        Context "translate()" {
            It "with 0 movement" {
                $Sut = [ArmSpan]::New(1, 2)
                $Sut.translate(0) | Should -Be $Sut
                Assert-Equivalent -Actual $Sut.translate(0) -Expected ([ArmSpan]::New(1, 2))
            }

            It "with 1 movement" {
                $Sut = [ArmSpan]::New(1, 2)
                $Sut.translate(1) | Should -Not -Be ([ArmSpan]::New(2, 2))
                Assert-Equivalent -Actual $Sut.translate(1) -Expected ([ArmSpan]::New(2, 2))
            }

            It "with -1 movement" {
                $Sut = [ArmSpan]::New(1, 2)
                $Sut.translate(-1) | Should -Not -Be ([ArmSpan]::New(0, 2))
                Assert-Equivalent -Actual $Sut.translate(-1) -Expected ([ArmSpan]::New(0, 2))
            }
        }

        It "Should correctly output [1,3] when toString() is called for a span with index 1 and length 2" {
            Assert-Equivalent -Actual ([ArmSpan]::New(1, 2).toString()) -Expected "[1, 3]"
        }
    }
}
