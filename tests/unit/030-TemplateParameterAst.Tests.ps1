using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateParameterAst" -Tag "TemplateParameterAst" {

        BeforeAll {
            Mock -CommandName Resolve-ArmFunction -MockWith {'MockedValue'}
            $EmptyTemplate = [TemplateRootAst]::New()

        }

        Context "Testing constructor" {

            BeforeAll {
                $MissingType = [PSCustomObject]@{
                    DefaultValue = '1234'
                }
                $NormalParameter = [PSCustomObject]@{
                    type = 'string'
                }
                $ValueParameter = [PSCustomObject]@{
                    type = 'string'
                    value = 'abc123'
                }
                $DefaultValueParameter = [PSCustomObject]@{
                    type = 'string'
                    defaultValue = 'def456'
                }
            }

            It "Throws an error when required properties aren't provided" {
                {[TemplateParameterAst]::New('MissingType', $MissingType, $EmptyParent)} | Should -Throw "Missing required properties, expected: Type"
            }

            It "Should not throw when a parameter with required properties is provided" {
                {[TemplateParameterAst]::New('NormalParameter', $NormalParameter, $EmptyParent)} | Should -Not -Throw
            }

            It "Should set the value of the parameter when provided" {
                ([TemplateParameterAst]::New('ValueParam', $ValueParameter, $EmptyParent)).Value | Should -Be 'abc123'
            }

            It "Should set the defaultValue of the parameter when provided" {
                ([TemplateParameterAst]::New('DefaultValueParam', $DefaultValueParameter, $EmptyParent)).DefaultValue | Should -Be 'def456'
            }

        }

        Context "Testing ResolveValue method" {

            Context "Testing ResolveValue method with strings" {

                It "Should assign the value of a simple string to DefaultValue" {
                    $TestInput = [PSCustomObject]@{
                        Type = 'string'
                        DefaultValue = 'Value'
                    }

                    $Sut = [TemplateParameterAst]::New('Test', $TestInput, $EmptyTemplate)

                    $Sut.Name | Should -Be 'Test'
                    $Sut.DefaultValue | Should -Be 'Value'
                    $Sut.RawDefaultValue | Should -Be 'Value'
                    $Sut.Type | Should -Be 'string'
                    $Sut.Parent | Should -Be $EmptyTemplate
                }

                It "Should call Resolve-ArmFunction when DefaultValue contains an ARM function" {
                    $TestInput = [PSCustomObject]@{
                        Type = 'string'
                        DefaultValue = "[Example('Function','Value')]"
                    }

                    $Sut = [TemplateParameterAst]::New('Test', $TestInput, $EmptyTemplate)

                    $Sut.Name | Should -Be 'Test'
                    $Sut.DefaultValue | Should -Be 'MockedValue'
                    $Sut.RawDefaultValue | Should -Be "[Example('Function','Value')]"
                    $Sut.Type | Should -Be 'String'
                    $Sut.Parent | Should -Be $EmptyTemplate
                    Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
                }

                It "Should assign the value of a simple string to Value" {
                    $TestInput = [PSCustomObject]@{
                        Type = 'string'
                        Value = 'Value'
                    }

                    $Sut = [TemplateParameterAst]::New('Test', $TestInput, $EmptyTemplate)

                    $Sut.Name | Should -Be 'Test'
                    $Sut.Value | Should -Be 'Value'
                    $Sut.RawValue | Should -Be 'Value'
                    $Sut.Type | Should -Be 'string'
                    $Sut.Parent | Should -Be $EmptyTemplate
                }

                It "Should call Resolve-ArmFunction when Value contains an ARM function" {
                    $Object = [PSCustomObject]@{
                        Type = 'string'
                        value = "[Example('Test','String','Value')]"
                    }

                    $Sut = [TemplateParameterAst]::New('Test',$Object,$EmptyTemplate)

                    $Sut.Name | Should -Be 'Test'
                    $Sut.RawValue | Should -Be "[Example('Test','String','Value')]"
                    $Sut.Value | Should -Be 'MockedValue'
                    $Sut.Type | Should -Be 'string'
                    $Sut.Parent | Should -Be $EmptyTemplate

                    Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
                }
            }

            Context "Testing ResolveValue method with objects" {

                It "Should iterate through all the properties of a single layer object" {
                    $Object = [PSCustomObject]@{
                        type = 'object'
                        Value = [PSCustomObject]@{
                            Property = "[Example('Test','String','Value')]"
                            ExtraData = 'OtherValue'
                        }
                    }

                    $Sut = [TemplateParameterAst]::New('Test',$Object,$EmptyTemplate)

                    $Sut.Name | Should -Be 'Test'
                    $Sut.RawValue | Should -Be $Object.Value
                    $Sut.Value.Property | Should -Be 'MockedValue'
                    $Sut.Value.ExtraData | Should -Be 'OtherValue'
                    $Sut.Type | Should -Be 'object'
                    $Sut.Parent | Should -Be $EmptyTemplate

                    Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
                }
            }
        }
    }
}
