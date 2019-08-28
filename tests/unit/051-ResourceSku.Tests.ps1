using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing ResourceSku" -Tag "ResourceSku" {

        Context "Testing constructor" {

            BeforeAll {
                $EmptyParent = [TemplateRootAst]::New()

                $NoMatchingProperties = [PSCustomObject]@{
                    Distance = '1234'
                }
                $NameProperty = [PSCustomObject]@{
                    Name = 'Standard_LRS'
                }
                $TierProperty = [PSCustomObject]@{
                    Tier = 'F'
                }
                $SizeProperty = [PSCustomObject]@{
                    Size = 'Medium'
                }
                $FamilyProperty = [PSCustomObject]@{
                    Family = 'S1'
                }
                $CapacityProperty = [PSCustomObject]@{
                    Capacity = 2
                }
            }

            It "Should throw when provided an object with no matching properties" {
                {[ResourceSku]::New($NoMatchingProperties, $EmptyParent)} | Should -Throw "No matching properties, expected one or more of: Name, Tier, Size, Family, Capacity"
            }

            $PropertyTestCases = @(
                @{
                    Property = 'Name'
                    InputObject = $NameProperty
                }
                @{
                    Property = 'Tier'
                    InputObject = $TierProperty
                }
                @{
                    Property = 'Size'
                    InputObject = $SizeProperty
                }
                @{
                    Property = 'Family'
                    InputObject = $FamilyProperty
                }
                @{
                    Property = 'Capacity'
                    InputObject = $CapacityProperty
                }
            )

            It "Should set <property> property to specified value" {
                param (
                    $InputObject,
                    $Property
                )

                ([ResourceSku]::New($InputObject, $EmptyParent)).$Property | Should -Be $InputObject.$Property
            } -TestCases $PropertyTestCases
        }
    }
}
