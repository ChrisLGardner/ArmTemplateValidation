Using Module ..\..\output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateParameterAst" -Tag "TemplateParameterAst" {

        Context "Testing constructor" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()
                $MissingType = [PSCustomObject]@{
                    DefaultValue = '1234'
                }
            }

            It "Throws an error when required properties aren't provided" {
                {[TemplateParameterAst]::New('MissingType', $MissingType, $EmptyParent)} | Should -Throw "Missing required properties, expected: Type"
            }

        }
    }
}
