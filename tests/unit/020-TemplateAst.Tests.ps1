using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing ArmTemplateAst" -Tag "ArmTemplateAst" {

        Context "Testing TemplateAst Constructor with path" {

            It "Should write an error when a template with no `$schema is provided" {
                {[TemplateAst]::New("$PSScriptRoot\InvalidPath\FakeTemplate.json")} | Should -Throw "Invalid Path provided."
            }

            It "Should write an error when a template with no `$schema is provided" {
                {[TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoSchema.json")} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no contentVersion is provided" {
                {[TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoContentVersion.json")} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no resources is provided" {
                {[TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\NoResources.json")} | Should -Throw "Invalid template provided"
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
                    $Sut.Functions.GetType().Name | Should -Be 'TemplateFunctionAst'
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
                    resources = 'ValidResources'
                }
            }

            It "Should write an error when a template with no `$schema is provided" {
                {[TemplateAst]::New($NoSchema)} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no contentVersion is provided" {
                {[TemplateAst]::New($NoContentVersion)} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no resources is provided" {
                {[TemplateAst]::New($NoResources)} | Should -Throw "Invalid template provided"
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
                    resources = 'ValidResources'
                }
            }

            It "Should write an error when a template with no `$schema is provided" {
                {[TemplateAst]::New($NoSchema, $EmptyParent)} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no contentVersion is provided" {
                {[TemplateAst]::New($NoContentVersion, $EmptyParent)} | Should -Throw "Invalid template provided"
            }

            It "Should write an error when a template with no resources is provided" {
                {[TemplateAst]::New($NoResources, $EmptyParent)} | Should -Throw "Invalid template provided"
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
