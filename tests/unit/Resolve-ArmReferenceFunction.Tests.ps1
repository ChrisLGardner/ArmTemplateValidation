using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Resolve-ArmResourceIdFunction" -Tag "Resolve-ArmResourceIdFunction" {

        BeforeAll {
            $Template = [TemplateAst]::New("$PSScriptRoot\TestData\TemplateAst\OneResource.json")
        }

        Context "Testing with a resource name" {

            BeforeAll {
                $Name = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, 'teststorageaccount')))

                $Sut = Resolve-ArmReferenceFunction -Arguments $Name -Template $Template.Resources[0]
            }

            It "Should return the resource AST" {
                $Sut.GetType().Name | Should -Be 'TemplateResourceAst'
            }

            It "Should return the correct names resource AST" {
                $Sut.Name | Should -Be 'teststorageaccount'
            }
        }

        Context "Testing with a resource Id" {

        }
    }
}
