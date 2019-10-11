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

                Mock -CommandName Resolve-ArmReferenceFunction -MockWith {
                    [PSCustomObject]@{
                        SomeObject = @(
                            [PSCustomObject]@{
                                Name = 'test'
                                value = 'othertest'
                            }
                        )
                        inputs = 'teststring'
                    }
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

            It "Should handle property access for [reference('test','item').inputs]" {
                $Sut = Resolve-ArmFunction -InputString "[reference('test','item').inputs]" -Template $EmptyTemplate

                $Sut | Should -Be 'teststring'
            }

            It "Should handle property access for multiple properties deep in [reference('test','item').SomeObject.value]" {
                $Sut = Resolve-ArmFunction -InputString "[reference('test','item').SomeObject.value]" -Template $EmptyTemplate

                $Sut | Should -Be 'othertest'
            }
        }

        Context "Testing correct functions are called when passed ArmValue objects" {

            BeforeAll {
                $EmptyTemplate = [TemplateRootAst]::New()

                $ArmFunctionSignatures = Get-Content -Path "$PSScriptRoot\TestData\FunctionSignatures.json" -Raw | ConvertFrom-Json
                foreach ($ArmFunction in $ArmFunctionSignatures.FunctionSignatures) {
                    Mock -CommandName "Resolve-Arm$($ArmFunction.Name)Function" -MockWith {}
                }
                Mock -CommandName Resolve-ArmReferenceFunction -MockWith {
                    [PSCustomObject]@{
                        SomeObject = @(
                            [PSCustomObject]@{
                                Name = 'test'
                                value = 'othertest'
                            }
                        )
                        inputs = 'teststring'
                    }
                }
                Mock -CommandName Resolve-ArmReferenceFunction -MockWith {
                    [TemplateResourceAst]::New([PSCustomObject]@{
                        Type = 'Microsoft.Resources/Deployment'
                        Name = 'ExampleDeployment'
                        ApiVersion = '1970-01-01'
                        Properties = [PSCustomObject]@{
                            Template = [PSCustomObject]@{
                                Outputs = @(
                                    [PSCustomObject]@{
                                        Name = 'example'
                                        value = 'OutputValue'
                                    }
                                )
                            }
                        }
                    }, ([TemplateRootAst]::New()))
                } -ParameterFilter {$Arguments[0].Token.StringValue -eq "'thing'"}
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

            It "Should handle property access for [reference('test','item').inputs]" {
                $Sut = [ArmParser]::Parse("[reference('test','item').inputs]")

                $result = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                $Result | Should -Be 'teststring'
            }

            It "Should handle property access for multiple properties deep in [reference('test','item').SomeObject.value]" {
                $Sut = [ArmParser]::Parse("[reference('test','item').SomeObject.value]")

                $result = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                $Result | Should -Be 'othertest'
            }

            It "Should handle returning values inside the outputs section of linked or nested tempaltes when passed [reference('thing').Outputs.example.value]" {
                $Sut = [ArmParser]::Parse("[reference('thing').Outputs.example.value]")

                $Result = Resolve-ArmFunction -InputObject $Sut.Expression -Template $EmptyTemplate

                $Result | Should -Be 'OutputValue'
            }

        }
    }
}
