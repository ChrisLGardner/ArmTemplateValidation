using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateResourceAst" -Tag "TemplateResourceAst" {

        BeforeAll {
            Mock -CommandName Resolve-ArmFunction -MockWith {'Test'}
            $EmptyParent = [TemplateRootAst]::New()
        }

        Context "Testing constructor with object" {

            BeforeAll {
                $NoApiVersion = [PSCustomObject]@{
                    name = 'NewResource'
                    type = 'Microsoft.Sql/SqlServer'
                }
                $InvalidApiVersion = [PSCustomObject]@{
                    name = 'NewResource'
                    type = 'Microsoft.Sql/SqlServer'
                    apiVersion = '18-17-10'
                }
                $NoType = [PSCustomObject]@{
                    name = 'NewResource'
                    apiVersion = '2018-07-10'
                }
                $InvalidType = [PSCustomObject]@{
                    name = 'NewResource'
                    apiVersion = '2018-07-10'
                    type = 'MicrosoftSqlServer'
                }
                $NoName = [PSCustomObject]@{
                    apiVersion = '2018-07-10'
                    Type = 'Microsoft.Sql/SqlServer'
                }

            }

            $RequiredProperties = @(
                @{
                    RequiredProperty = 'apiVersion'
                    InputObject = $NoApiVersion
                }
                @{
                    RequiredProperty = 'valid apiVersion'
                    InputObject = $InvalidApiVersion
                }
                @{
                    RequiredProperty = 'type'
                    InputObject = $NoType
                }
                @{
                    RequiredProperty = 'valid type'
                    InputObject = $InvalidType
                }
                @{
                    RequiredProperty = 'name'
                    InputObject = $NoName
                }
            )

            It "Should write an error when no <RequiredProperty> is provided" {
                Param (
                    $RequiredProperty,
                    $InputObject
                )

                {[TemplateResourceAst]::New($InputObject, $EmptyParent)} | Should -Throw "Missing one or more required properties."

            } -TestCases $RequiredProperties

            Context "Test Virtual Machine template" {

                BeforeAll {
                    $VirtualMachine = Get-Content -Path "$PSScriptRoot\TestData\TemplateResourceAst\VirtualMachine.json" -Raw | ConvertFrom-Json
                    $Sut = [TemplateResourceAst]::New($VirtualMachine, $EmptyParent)
                }

                It "Should set the type correctly" {
                    $Sut.Type | Should -Be $VirtualMachine.Type
                }

                It "Should set the apiVersion correctly" {
                    $Sut.ApiVersion | Should -Be $VirtualMachine.ApiVersion
                }

                It "Should set the name correctly" {
                    $Sut.name | Should -Be $VirtualMachine.name
                }

                It "Should set the location correctly" {
                    $Sut.location | Should -Be $VirtualMachine.location
                }

                It "Should set the dependsOn correctly" {
                    $Sut.dependsOn | Should -Be $VirtualMachine.dependsOn
                }

                It "Should set the properties correctly" {
                    $Sut.Properties.GetType().Name | Should -Be 'PSCustomObject'
                }
            }

            Context "Test Storage Account template" {

                BeforeAll {
                    $StorageAccount = Get-Content -Path "$PSScriptRoot\TestData\TemplateResourceAst\StorageAccount.json" -Raw | ConvertFrom-Json
                    $Sut = [TemplateResourceAst]::New($StorageAccount, $EmptyParent)
                }

                It "Should set the type correctly" {
                    $Sut.Type | Should -Be $StorageAccount.Type
                }

                It "Should set the apiVersion correctly" {
                    $Sut.ApiVersion | Should -Be $StorageAccount.ApiVersion
                }

                It "Should set the name correctly" {
                    $Sut.name | Should -Be $StorageAccount.name
                }

                It "Should set the location correctly" {
                    $Sut.location | Should -Be $StorageAccount.location
                }

                It "Should set the type of sku correctly" {
                    $Sut.Sku.GetType().FullName | Should -Be 'ResourceSku'
                }

                It "Should set the values of sku correctly" {
                    $Sut.sku.Name | Should -Be $StorageAccount.Sku.Name
                }

                It "Should set the kind correctly" {
                    $Sut.kind | Should -Be $StorageAccount.kind
                }

                It "Should not set any properties" {
                    $Sut.Properties | Should -BeNullOrEmpty
                }
            }

            Context "Test nested template resource" {
                BeforeAll {
                    $NestedTemplate = Get-Content -Path "$PSScriptRoot\TestData\TemplateResourceAst\NestedTemplate.json" -Raw | ConvertFrom-Json
                    $NestedTemplateProperties = $NestedTemplate.Properties.Template | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                    $Sut = [TemplateResourceAst]::New($NestedTemplate, $EmptyParent)
                }

                It "Should add original template object as TemplateRaw property" {
                    $Sut.Properties.TemplateRaw | Should -Not -BeNullOrEmpty
                }

                It "Should transform the nested template into a TemplateAst" {
                    $Sut.Properties.Template.GetType().Name | Should -Be 'TemplateAst'
                }

                It "Should add the raw value of the StoragAccountName parameter to the parameter object for passing into the nested template" {
                    $Sut.Properties.Parameters.StorageAccountName.ValueRaw | Should -Be 'testName'
                }

                It "Should add the raw value of the location parameter to the parameter object for passing into the nested template" {
                    $Sut.Properties.Parameters.location.ValueRaw | Should -Be 'WestEurope'
                }

            }

            Context "Test public linked template resource" {
                BeforeAll {
                    $PublicTemplate = Get-Content -Path "$PSScriptRoot\TestData\TemplateResourceAst\PublicLinkedTemplate.json" -Raw | ConvertFrom-Json
                    $Sut = [TemplateResourceAst]::New($PublicTemplate, $EmptyParent)
                }

                It "Should transform the linked template into a TemplateAst" {
                    $Sut.Properties.Template.GetType().Name | Should -Be 'TemplateAst'
                }
            }

            Context "Test private linked template resource" {
                BeforeAll {
                    $PrivateTemplate = Get-Content -Path "$PSScriptRoot\TestData\TemplateResourceAst\PrivateLinkedTemplate.json" -Raw | ConvertFrom-Json
                    $Sut = [TemplateResourceAst]::New($PrivateTemplate, $EmptyParent)
                }

                It "Should transform the linked template into a TemplateAst" {
                    $Sut.Properties.Template.GetType().Name | Should -Be 'TemplateAst'
                }
            }
        }

        Context "Testing ResolveTemplate" {

        }
    }
}
