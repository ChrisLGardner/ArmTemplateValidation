using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateVariableAst" -Tag "TemplateVariableAst" {

        BeforeAll {
            Mock -CommandName Resolve-ArmFunction -MockWith {'MockedValue'}
            $EmptyTemplate = [TemplateRootAst]::New()
        }

        Context "Testing ResolveValue method with strings" {

            It "Should assign the value of a simple string to Value" {
                $Sut = [TemplateVariableAst]::New('Test','Value',$EmptyTemplate)

                $Sut.Name | Should -Be 'Test'
                $Sut.Value | Should -Be 'Value'
                $Sut.RawValue | Should -Be 'Value'
                $Sut.Parent | Should -Be $EmptyTemplate
            }

            It "Should call Resolve-ArmFunction when value contains an ARM function" {
                $Sut = [TemplateVariableAst]::New('Test',"[Example('Function','Value')]",$EmptyTemplate)

                $Sut.Name | Should -Be 'Test'
                $Sut.Value | Should -Be 'MockedValue'
                $Sut.RawValue | Should -Be "[Example('Function','Value')]"
                $Sut.Parent | Should -Be $EmptyTemplate
                Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
            }
        }

        Context "Testing ResolveValue method with objects" {

            It "Should iterate through all the properties of a single layer object" {
                $Object = [PSCustomObject]@{
                    Name = 'TestValue'
                    Function = "[Example('Test','String','Value')]"
                }

                $Sut = [TemplateVariableAst]::New('Test',$Object,$EmptyTemplate)

                $Sut.Name | Should -Be 'Test'
                $Sut.RawValue | Should -Be $Object
                $Sut.Value.Name | Should -Be 'TestValue'
                $Sut.Value.Function | Should -Be 'MockedValue'
                $Sut.Parent | Should -Be $EmptyTemplate

                Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
            }

            It "Should iterate through all the properties of a single layer object" {
                $Object = [PSCustomObject]@{
                    Name = 'TestValue'
                    Nested = [PSCustomObject]@{
                        Property = "[Example('Test','String','Value')]"
                        ExtraData = 'OtherValue'
                    }
                }

                $Sut = [TemplateVariableAst]::New('Test',$Object,$EmptyTemplate)

                $Sut.Name | Should -Be 'Test'
                $Sut.RawValue | Should -Be $Object
                $Sut.Value.Name | Should -Be 'TestValue'
                $Sut.Value.Nested.Property | Should -Be 'MockedValue'
                $Sut.Value.Nested.ExtraData | Should -Be 'OtherValue'
                $Sut.Parent | Should -Be $EmptyTemplate

                Assert-MockCalled -CommandName Resolve-ArmFunction -Times 1 -Scope It
            }
        }
    }
}
