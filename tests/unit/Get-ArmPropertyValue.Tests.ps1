using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Get-ArmPropertyValue" -Tag "Get-ArmPropertyValue" {

        Context "When using an element inside a TemplateAst" {

            BeforeAll {
                $ExampleTemplate = [TemplateAst]::New(
                    [PSCustomObject]@{
                        '$schema' = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
                        contentVersion = "1.0.0.0"
                        resources = @(
                            [PSCustomObject]@{
                                type = "Microsoft.Storage/storageAccounts"
                                name = "teststorageaccount"
                                location = "WestEurope"
                                apiVersion = "2018-07-01"
                                sku = [PSCustomObject]@{
                                    name = "Standard_LRS"
                                }
                                kind = "StorageV2"
                                properties = @{}
                            }
                        )
                        Parameters = [PSCustomObject]@{
                            ExampleDefaultParam = [PSCustomObject]@{
                                type = 'string'
                                DefaultValue = 'Test123'
                            }
                            ExampleParam = [PSCustomObject]@{
                                type = 'string'
                                Value = 'Test456'
                            }
                            OtherParam = [PSCustomObject]@{
                                type = 'string'
                            }
                        }
                        Variables = [PSCustomObject]@{
                            ExampleVar = "Test789"
                            OtherVar = "TestAbc"
                            ObjectVar = [PSCustomObject]@{
                                Name = 'Object'
                                Value = 'SomeValue'
                            }
                        }
                        Outputs = [PSCustomObject]@{
                            ExampleOutput = [PSCustomObject]@{
                                type = 'string'
                                Value = 'TestDef'
                            }
                            OtherOutput = [PSCustomObject]@{
                                type = 'string'
                                Value = 'TestGhi'
                            }
                        }
                    }
                )
            }

            It "Should return the variable named 'ExampleVar' from the parent template of a variable" {
                $Sut = Get-ArmPropertyValue -Name ExampleVar -Type 'Variable' -Template $ExampleTemplate.Variables[1]

                $Sut | Should -Be 'Test789'
            }

            It "Should return the parameter named 'ExampleParam' from the parent template of a variable" {
                $Sut = Get-ArmPropertyValue -Name ExampleParam -Type 'Parameter' -Template $ExampleTemplate.Variables[1]

                $Sut | Should -Be 'Test456'
            }

            It "Should return the parameter named 'ExampleDefaultParam' from the parent template of a variable" {
                $Sut = Get-ArmPropertyValue -Name ExampleDefaultParam -Type 'Parameter' -Template $ExampleTemplate.Variables[1]

                $Sut | Should -Be 'Test123'
            }

            It "Should return the parameter named 'ExampleParam' from the parent template of a parameter" {
                $Sut = Get-ArmPropertyValue -Name ExampleParam -Type 'Parameter' -Template $ExampleTemplate.Parameters[2]

                $Sut | Should -Be 'Test456'
            }

            It "Should return the variable named 'ExampleVar' from the parent template of an output" {
                $Sut = Get-ArmPropertyValue -Name ExampleVar -Type 'Variable' -Template $ExampleTemplate.Outputs[1]

                $Sut | Should -Be 'Test789'
            }

            It "Should return the parameter named 'ExampleParam' from the parent template of an output" {
                $Sut = Get-ArmPropertyValue -Name ExampleParam -Type 'Parameter' -Template $ExampleTemplate.Outputs[1]

                $Sut | Should -Be 'Test456'
            }

            It "Should return the variable named 'ExampleVar' from the parent template of a resource" {
                $Sut = Get-ArmPropertyValue -Name ExampleVar -Type 'Variable' -Template $ExampleTemplate.Resources[0]

                $Sut | Should -Be 'Test789'
            }

            It "Should return the parameter named 'ExampleParam' from the parent template of a resource" {
                $Sut = Get-ArmPropertyValue -Name ExampleParam -Type 'Parameter' -Template $ExampleTemplate.Resources[0]

                $Sut | Should -Be 'Test456'
            }

            It "Should return an object when the content of a variable is an object from the parent template of a resource" {
                $Sut = Get-ArmPropertyValue -Name ObjectVar -Type 'Variable' -Template $ExampleTemplate.Resources[0]

                $Sut | Should -BeOfType [PSCustomObject]
                $Sut.Name | Should -Be 'Object'
                $Sut.Value | Should -Be 'SomeValue'
            }

        }

        Context "When using an element inside a nested TemplateAst" {

            BeforeAll {
                $ExampleTemplate = [TemplateAst]::New(
                    [PSCustomObject]@{
                        '$schema' = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
                        contentVersion = "1.0.0.0"
                        resources = @(
                            [PSCustomObject]@{
                                apiVersion = "2017-05-10"
                                name = "ExtraStorageAccount"
                                type = "Microsoft.Resources/deployments"
                                resourceGroup = "[parameters('ExampleParam')]"
                                properties = [PSCustomObject]@{
                                    mode = "Incremental"
                                    template = [PSCustomObject]@{
                                        '$schema' = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
                                        contentVersion = "1.0.0.0"
                                        parameters = [PSCustomObject]@{
                                            StorageAccountName = [PSCustomObject]@{
                                                type = 'string'
                                            }
                                            location = [PSCUstomObject]@{
                                                type = 'string'
                                            }
                                        }
                                        resources = @(
                                            [PSCustomObject]@{
                                                type = "Microsoft.Storage/storageAccounts"
                                                name = "teststorageaccount"
                                                location = "WestEurope"
                                                apiVersion = "2018-07-01"
                                                sku = [PSCustomObject]@{
                                                    name = "Standard_LRS"
                                                }
                                                kind = "StorageV2"
                                                properties = @{}
                                            }
                                        )
                                    }
                                    parameters = [PSCustomObject]@{
                                        StorageAccountName = [PSCustomObject]@{
                                            value = "testName"
                                        }
                                        location = [PSCustomObject]@{
                                            value = "WestEurope"
                                        }
                                    }
                                }
                            }
                        )
                        Parameters = [PSCustomObject]@{
                            ExampleDefaultParam = [PSCustomObject]@{
                                type = 'string'
                                DefaultValue = 'Test123'
                            }
                            ExampleParam = [PSCustomObject]@{
                                type = 'string'
                                Value = 'Test456'
                            }
                            OtherParam = [PSCustomObject]@{
                                type = 'string'
                            }
                        }
                        Variables = [PSCustomObject]@{
                            ExampleVar = "Test789"
                            OtherVar = "TestAbc"
                            ObjectVar = [PSCustomObject]@{
                                Name = 'Object'
                                Value = 'SomeValue'
                            }
                        }
                        Outputs = [PSCustomObject]@{
                            ExampleOutput = [PSCustomObject]@{
                                type = 'string'
                                Value = 'TestDef'
                            }
                            OtherOutput = [PSCustomObject]@{
                                type = 'string'
                                Value = 'TestGhi'
                            }
                        }
                    }
                )
            }

            It "Should return the variable named 'ExampleVar' in a parent template of a variable from a nested template" {
                $Sut = Get-ArmPropertyValue -Name ExampleVar -Type 'Variable' -Template $ExampleTemplate.Resources[0].Properties.Template

                $Sut | Should -Be 'Test789'
            }

            It "Should return null for the parameter named 'ExampleParam' from a nested template when the value isn't being passed into the child template" {
                $Sut = Get-ArmPropertyValue -Name ExampleParam -Type 'Parameter' -Template $ExampleTemplate.Resources[0].Properties.Template

                $Sut | Should -BeNullOrEmpty
            }

            It "Should return the parameter named 'ExampleVar' in a parent template of a parameter from a nested template parameter" {
                $Sut = Get-ArmPropertyValue -Name ExampleVar -Type 'Variable' -Template $ExampleTemplate.Resources[0].Properties.Template.Parameters[0]

                $Sut | Should -Be 'Test789'
            }

            It "Should return the parameter named 'location' property in a nested resource template from within a nested parameter." {
                $Sut = Get-ArmPropertyValue -Name location -Type 'Parameter' -Template $ExampleTemplate.Resources[0].Properties.Template.Parameters[1]

                $Sut | Should -Be 'WestEurope'
            }
        }
    }
}
