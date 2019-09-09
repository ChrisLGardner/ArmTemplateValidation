using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing ArmTemplateAst" -Tag "ArmTemplateAst" {

        Context "Testing TemplateAst Constructor with path" {

            It "Should write an error when a template with no `$schema is provided" {
                {[TemplateAst]::New("$PSScriptRoot\InvalidPath\FakeTemplate.json")} | Should -Throw "Invalid Path provided."
            }

            It "Should log an error when a template with no `$schema is provided" {
                ([TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoSchema.json")).Errors | Should -Be 'Invalid Template: does not contain a $schema element'
            }

            It "Should log an error when a template with no contentVersion is provided" {
                ([TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoContentVersion.json")).Errors | Should -Be "Invalid Template: does not contain a contentVersion element"
            }

            It "Should log an error when a template with no resources is provided" {
                ([TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoResources.json")).Errors | Should -Be "Invalid Template: does not contain any resources"
            }

            Context "Template with a single resource" {

                BeforeAll {
                    $Sut = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\OneResource.json")
                }

                It "Should have one resource" {
                    $Sut.Resources | Should -HaveCount 1
                }

                It "Should have resource of type TemplateResourceAst" {
                    $Sut.Resources.GetType().Name | Should -Be 'TemplateResourceAst[]'
                }
            }

            Context "Template with multiple resources" {

                BeforeAll {
                    $Sut = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\MultipleResources.json")
                }

                It "Should have three resources" {
                    $Sut.Resources | Should -HaveCount 3
                }

                It "Should have resource of type TemplateResourceAst" {
                    $Sut.Resources[0].GetType().Name | Should -Be 'TemplateResourceAst'
                    $Sut.Resources[1].GetType().Name | Should -Be 'TemplateResourceAst'
                    $Sut.Resources[2].GetType().Name | Should -Be 'TemplateResourceAst'
                }
            }

            Context "Template with a single parameter" {

                BeforeAll {
                    $Sut = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\Parameters.json")
                }

                It "Should have one parameter" {
                    $Sut.Parameters | Should -HaveCount 1
                }

                It "Should have parameter of type TemplateParameterAst" {
                    $Sut.Parameters.GetType().Name | Should -Be 'TemplateParameterAst[]'
                }
            }

            Context "Template with a single variables" {

                BeforeAll {
                    $Sut = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\Variables.json")
                }

                It "Should have one variable" {
                    $Sut.Variables | Should -HaveCount 1
                }

                It "Should have variable of type TemplateVariableAst" {
                    $Sut.Variables.GetType().Name | Should -Be 'TemplateVariableAst[]'
                }
            }

            Context "Template with a single function" {

                BeforeAll {
                    $Sut = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\Functions.json")
                }

                It "Should have one function" {
                    $Sut.Functions | Should -HaveCount 1
                }

                It "Should have function of type TemplateFunctionAst" {
                    $Sut.Functions.GetType().Name | Should -Be 'TemplateFunctionAst[]'
                }
            }
        }

        Context "Testing TemplateAst Constructor with a PSCustomObject" {

            BeforeAll {
                $NoSchema = [PSCustomObject]@{
                    Empty = "Template"
                }
                $NoContentVersion = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                }
                $NoResources = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                }
                $ValidTemplate = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                    resources = [PSCustomObject]@{
                        Name = 'ExampleResource'
                        Type = 'Microsoft.Test/Resource'
                        ApiVersion = '1970-01-01'
                    }
                }
            }

            It 'Should write an error when a template with no $schema is provided' {
                ([TemplateAst]::New($NoSchema)).Errors | Should -Be 'Invalid Template: does not contain a $schema element'
            }

            It "Should write an error when a template with no contentVersion is provided" {
                ([TemplateAst]::New($NoContentVersion)).Errors | Should -Be "Invalid Template: does not contain a contentVersion element"
            }

            It "Should write an error when a template with no resources is provided" {
                ([TemplateAst]::New($NoResources)).Errors | Should -Be "Invalid Template: does not contain any resources"
            }

            It "Should not write an error when a valid template is provided" {
                ([TemplateAst]::New($ValidTemplate)).Errors.Count | Should -Be 0
            }

        }

        Context "Testing TemplateAst Constructor with a PSCustomObject and empty parent" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()

                $NoSchema = [PSCustomObject]@{
                    Empty = "Template"
                }
                $NoContentVersion = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                }
                $NoResources = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                }
                $ValidTemplate = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                    resources = [PSCustomObject]@{
                        Name = 'ExampleResource'
                        Type = 'Microsoft.Test/Resource'
                        ApiVersion = '1970-01-01'
                    }
                }
            }

            It 'Should write an error when a template with no $schema is provided' {
                ([TemplateAst]::New($NoSchema, $EmptyParent)).Errors | Should -Be 'Invalid Template: does not contain a $schema element'
            }

            It "Should write an error when a template with no contentVersion is provided" {
                ([TemplateAst]::New($NoContentVersion, $EmptyParent)).Errors | Should -Be "Invalid Template: does not contain a contentVersion element"
            }

            It "Should write an error when a template with no resources is provided" {
                ([TemplateAst]::New($NoResources, $EmptyParent)).Errors | Should -Be "Invalid Template: does not contain any resources"
            }

            It "Should not write an error when a valid template is provided" {
                ([TemplateAst]::New($ValidTemplate, $EmptyParent)).Errors.Count | Should -Be 0
            }

        }

        Context "Testing HasRequiredTemplateProperties method" {

            BeforeAll {
                $NoSchema = [PSCustomObject]@{
                    Empty = "Template"
                }
                $NoContentVersion = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                }
                $NoResources = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                }
                $ValidTemplate = [PSCustomObject]@{
                    '$schema' = 'ValidSchema'
                    contentVersion = '2.0.0.0'
                    resources = 'ValidResources'
                }
            }

            BeforeEach {
                $Sut = [TemplateAst]::New()
            }

            It "Should return false when no `$schema is specified" {
                $Sut.HasRequiredTemplateProperties($NoSchema) | Should -Be $false
            }

            It "Should return false when no contentVersion is specified" {
                $Sut.HasRequiredTemplateProperties($NoContentVersion) | Should -Be $false
            }

            It "Should return false when no resources are specified" {
                $Sut.HasRequiredTemplateProperties($NoResources) | Should -Be $false
            }

            It "Should return true when all mandatory fields are specified" {
                $Sut.HasRequiredTemplateProperties($ValidTemplate) | Should -Be $true
            }

        }

    }
}
