Using Module ..\..\output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing ResourcePlan" -Tag "ResourcePlan" {

        Context "Testing constructor" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()

                $NoMatchingProperties = [PSCustomObject]@{
                    Distance = '1234'
                }
                $NameProperty = [PSCustomObject]@{
                    Name = 'Standard_LRS'
                }
                $PromotionCodeProperty = [PSCustomObject]@{
                    PromotionCode = 'F'
                }
                $PublisherProperty = [PSCustomObject]@{
                    Publisher = 'Medium'
                }
                $ProductProperty = [PSCustomObject]@{
                    Product = 'S1'
                }
                $VersionProperty = [PSCustomObject]@{
                    Version = 2
                }
            }

            It "Should throw when provided an object with no matching properties" {
                {[ResourcePlan]::New($NoMatchingProperties, $EmptyParent)} | Should -Throw "No matching properties, expected one or more of: Name, PromotionCode, Publisher, Product, Version"
            }

            $PropertyTestCases = @(
                @{
                    Property = 'Name'
                    InputObject = $NameProperty
                }
                @{
                    Property = 'PromotionCode'
                    InputObject = $PromotionCodeProperty
                }
                @{
                    Property = 'Publisher'
                    InputObject = $PublisherProperty
                }
                @{
                    Property = 'Product'
                    InputObject = $ProductProperty
                }
                @{
                    Property = 'Version'
                    InputObject = $VersionProperty
                }
            )

            It "Should set <property> property to specified value" {
                param (
                    $InputObject,
                    $Property
                )

                ([ResourcePlan]::New($InputObject, $EmptyParent)).$Property | Should -Be $InputObject.$Property
            } -TestCases $PropertyTestCases
        }
    }
}
