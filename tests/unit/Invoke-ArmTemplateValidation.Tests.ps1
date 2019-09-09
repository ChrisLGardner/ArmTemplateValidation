using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Invoke-ArmTemplateValidation" -Tag "Invoke-ArmTemplateValidation" {

        Context "When providing just a template" {

            Context "For a valid template" {

                BeforeAll {
                    $Sut = Invoke-ArmTemplateValidation -Path "$PSScriptRoot\TestData\InvokeTemplateValidation\OneResource.json"
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have no errors" {
                    $Sut.Errors.Count | Should -Be 0
                }

                It "Should be return true for the valid property of the template" {
                    $Sut.Valid | Should -Be $True
                }

            }

            Context "For an invalid tempalte" {

                BeforeAll {
                    $Sut = Invoke-ArmTemplateValidation -Path "$PSScriptRoot\TestData\InvokeTemplateValidation\NoResources.json"
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have 1 error" {
                    $Sut.Errors.Count | Should -Be 1
                    $Sut.Errors | Should -Be 'Invalid template: Does not contain any resources'
                }

                It "Should be return false for the valid property of the template" {
                    $Sut.Valid | Should -Be $false
                }
            }
        }

        Context "When providing a template and parameter file" {

            Context "For a valid template" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\Parameters.json"
                        ParameterFile = "$PSScriptRoot\TestData\InvokeTemplateValidation\parameters.parameters.json"
                    }
                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have no errors" {
                    $Sut.Errors.Count | Should -Be 0
                }

                It "Should be return true for the valid property of the template" {
                    $Sut.Valid | Should -Be $True
                }
            }

            Context "For an invalid tempalte" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\InvalidParameters.json"
                        ParameterFile = "$PSScriptRoot\TestData\InvokeTemplateValidation\parameters.parameters.json"
                    }
                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have 1 error" {
                    $Sut.Errors.Count | Should -Be 1
                    $Sut.Errors | Should -Be 'Invalid template: Resource does not contain a valid type'
                }

                It "Should be return false for the valid property of the template" {
                    $Sut.Valid | Should -Be $false
                }
            }
        }

        Context "When providing a template and parameters hashtable" {

            Context "For a valid template" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\Parameters.json"
                        Parameters = @{
                            StorageAccountName = 'testname'
                        }
                    }

                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have no errors" {
                    $Sut.Errors.Count | Should -Be 0
                }

                It "Should be return true for the valid property of the template" {
                    $Sut.Valid | Should -Be $True
                }

            }

            Context "For an invalid tempalte" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\InvalidParameters.json"
                        Parameters = @{
                            StorageAccountName = 'testname'
                        }
                    }

                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have 1 error" {
                    $Sut.Errors.Count | Should -Be 1
                    $Sut.Errors | Should -Be 'Invalid template: Resource does not contain a valid type'
                }

                It "Should be return false for the valid property of the template" {
                    $Sut.Valid | Should -Be $false
                }
            }
        }

        Context "When providing a template, parameter file, and parameters hashtable" {

            Context "For a valid template" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\MultipleParameters.json"
                        ParameterFile = "$PSScriptRoot\TestData\InvokeTemplateValidation\parameters.parameters.json"
                        Parameters = @{
                            StorageSku = 'Standard_LRS'
                        }
                    }
                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have no errors" {
                    $Sut.Errors.Count | Should -Be 0
                }

                It "Should be return true for the valid property of the template" {
                    $Sut.Valid | Should -Be $True
                }

            }

            Context "For an invalid tempalte" {

                BeforeAll {
                    $InvokeSplat = @{
                        Path = "$PSScriptRoot\TestData\InvokeTemplateValidation\InvalidMultipleParameters.json"
                        ParameterFile = "$PSScriptRoot\TestData\InvokeTemplateValidation\parameters.parameters.json"
                        Parameters = @{
                            StorageSku = 'Standard_LRS'
                        }
                    }
                    $Sut = Invoke-ArmTemplateValidation @InvokeSplat
                }

                It "Should return a TemplateAst object" {
                    $Sut.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should have 1 error" {
                    $Sut.Errors.Count | Should -Be 1
                    $Sut.Errors | Should -Be 'Invalid template: Resource does not contain a valid type'
                }

                It "Should be return false for the valid property of the template" {
                    $Sut.Valid | Should -Be $false
                }
            }
        }
    }
}
