using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Resolve-ArmUtcNowFunction" -Tag "Resolve-ArmUtcNowFunction" {

        BeforeAll {
            Mock -CommandName Get-Date -MockWith {
                [DateTime]::new(1970,01,01,12,00,00)
            }
            $Parameter = [PSCustomObject]@{
                type = 'string'
            }
            $ParameterAst = [TemplateParameterAst]::New('Test',$Parameter, [TemplateRootAst]::New())
        }

        It "Should throw when tempalte isn't a TemplateParameterAst" {
            $BadAst = [TemplateRootAst]::New()

            {Resolve-ArmUtcNowFunction -Arguments 'yyyy' -Template $BadAst} | Should -Throw
        }

        It "Should resolve to ISO 8601 (yyyyMMddTHHmmssZ) when no arguments are provided" {
            $Sut = Resolve-ArmUtcNowFunction -Template $ParameterAst

            $Sut | Should -Be '19700101T120000Z'
        }

        It "Should resolve to dd-MM-yyyy when provided that format as an argument" {
            $argumentValue = [ArmStringValue]::New(
                [ArmToken]::Create(
                    [ArmTokenType]::QuotedString,
                    0,
                    'dd-MM-yyyy'
                )
            )
            $Sut = Resolve-ArmUtcNowFunction -Arguments $argumentValue -Template $ParameterAst

            $Sut | Should -Be '01-01-1970'
        }
    }
}
