using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateParameterAst" -Tag "TemplateParameterAst" {

        Context "Testing constructor" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()
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
    }
}
