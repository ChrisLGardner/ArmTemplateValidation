using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Resolve-ArmFunction" -Tag "Resolve-ArmFunction" {

        Context "Testing correct ARM functions are called when passed strings containing them" {
            $ArmFunctionSignatures = Get-Content -Path "$PSScriptRoot\TestData\FunctionSignatures.json" -Raw | ConvertFrom-Json

            BeforeAll {
                $EmptyTemplate = [TemplateRootAst]::New()

                $ArmFunctionSignatures = Get-Content -Path "$PSScriptRoot\TestData\FunctionSignatures.json" -Raw | ConvertFrom-Json
                foreach ($ArmFunction in $ArmFunctionSignatures.FunctionSignatures) {
                    Mock -CommandName "Resolve-Arm$($ArmFunction.Name)Function" -MockWith {}
                }
            }


            $ArmFunctionTestCases = foreach ($ArmFunction in $ArmFunctionSignatures.FunctionSignatures) {
                @{
                    InputString = "[$($ArmFunction.Name)('Data')]"
                    FunctionName = "Resolve-Arm$($ArmFunction.Name)Function"
                }
            }

            It "Should call the <FunctionName> mock based on the input string <InputString>" {
                param (
                    $InputString,
                    $FunctionName
                )

                $null = Resolve-ArmFunction -InputString $InputString -Template $EmptyTemplate

                Assert-MockCalled -CommandName $FunctionName -Times 1 -Scope It
            } -TestCases $ArmFunctionTestCases
        }

        Context "Testing correct functions are called when passed ArmValue objects" {

            BeforeAll {
                $EmptyTemplate = [TemplateRootAst]::New()

                $ArmFunctionSignatures = Get-Content -Path "$PSScriptRoot\TestData\FunctionSignatures.json" -Raw | ConvertFrom-Json
                foreach ($ArmFunction in $ArmFunctionSignatures.FunctionSignatures) {
                    Mock -CommandName "Resolve-Arm$($ArmFunction.Name)Function" -MockWith {}
                }
            }

            It "Should call the concat function when passed an ArmValue for [contact('test','data')]" {
                $Sut = [ArmParser]::Parse("[concat('test','data')]")

                $null = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                Assert-MockCalled -CommandName Resolve-ArmConcatFunction -Times 1 -Scope It
            }

            It "Should call the concat and resourceId functions when passed an ArmValue for [concat(resourceId('Microsoft.Test/Data','TestItem'),'Data')]" {
                $Sut = [ArmParser]::Parse("[concat(resourceId('Microsoft.Test/Data','TestItem'),'Data')]")

                $null = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                Assert-MockCalled -CommandName Resolve-ArmConcatFunction -Times 1 -Scope It
                Assert-MockCalled -CommandName Resolve-ArmResourceIdFunction -Times 1 -Scope It
            }

            It "Should call the concat, add, and resourceId functions when passed an ArmValue for [concat(resourceId('Microsoft.Test/Data','TestItem'),'Data', add(1,2))]" {
                $Sut = [ArmParser]::Parse("[concat(resourceId('Microsoft.Test/Data','TestItem'),'Data', add(1,2))]")

                $null = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                Assert-MockCalled -CommandName Resolve-ArmConcatFunction -Times 1 -Scope It
                Assert-MockCalled -CommandName Resolve-ArmResourceIdFunction -Times 1 -Scope It
                Assert-MockCalled -CommandName Resolve-ArmAddFunction -Times 1 -Scope It
            }
        }
    }
}
