using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing TemplateOutputAst" -Tag "TemplateOutputAst" {

        Context "Testing constructor" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()
                $MissingType = [PSCustomObject]@{
                    Value = '1234'
                }
            }

            It "Throws an error when required properties aren't provided" {
                {[TemplateOutputAst]::New('MissingType', $MissingType, $EmptyParent)} | Should -Throw "Output - Missing required properties, expected: Type"
            }

        }
    }
}
