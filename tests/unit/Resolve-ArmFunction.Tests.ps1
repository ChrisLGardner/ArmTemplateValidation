Using Module ..\..\output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Resolve-ArmFunction" -Tag "Resolve-ArmFunction" {

        Context "Testing correct ARM functions are called" {
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
    }
}
