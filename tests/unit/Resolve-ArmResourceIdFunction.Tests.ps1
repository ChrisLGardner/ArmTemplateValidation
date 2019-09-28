using module ..\..\Output\ArmTemplateValidation

InModuleScope ArmTemplateValidation {

    Describe "Testing Resolve-ArmResourceIdFunction" -Tag "Resolve-ArmResourceIdFunction" {

        BeforeAll {
            $Script:SubscriptionId = '80714cf6-6d45-4a21-845c-7db81ab37921'
            $Script:ResourceGroupName = '18d3902c-4fed-4d24-85c3-b64a09425a38'

            $EmptyTemplate = [TemplateRootAst]::New()
            $Subscription = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, "/subscriptions/$Script:SubscriptionId")))
            $ResourceGroup = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, "/subscriptions/$Script:SubscriptionId/resourceGroups/$Script:ResourceGroupName")))
            $ResourceType = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, 'Microsoft.Network/VirtualNetworks')))
            $MultipleResourceType = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, 'Microsoft.Network/VirtualNetworks/Subnets')))
            $ResourceName = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, 'VirtualNetworkName')))
            $ResourceSubName = [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, 'Subnet123')))
        }

        Context "Testing with no subscription or resource group specified and only one segment" {

            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $ResourceType,$ResourceName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName'
            }
        }

        Context "Testing with no subscription or resource group specified and 2 segments" {
            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $MultipleResourceType,$ResourceName,$ResourceSubName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName/Subnets/Subnet123'
            }
        }

        Context "Testing with no subscription but with resource group specified and only one segment" {
            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $ResourceType,$ResourceName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName'
            }
        }

        Context "Testing with no subscription but with resource group specified and 2 segments" {
            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $MultipleResourceType,$ResourceName,$ResourceSubName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName/Subnets/Subnet123'
            }
        }

        Context "Testing with subscription and resource group specified and only one segment" {
            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $ResourceType,$ResourceName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName'
            }
        }

        Context "Testing with subscription and resource group specified and 2 segments" {
            It "Should return the correct full string containing the subscription, resource group, resource type, and resource name" {
                $Sut = Resolve-ArmResourceIdFunction -Arguments $MultipleResourceType,$ResourceName,$ResourceSubName -Template $EmptyTemplate

                $Sut | Should -Be '/subscriptions/80714cf6-6d45-4a21-845c-7db81ab37921/resourceGroups/18d3902c-4fed-4d24-85c3-b64a09425a38/Microsoft.Network/VirtualNetworks/VirtualNetworkName/Subnets/Subnet123'
            }
        }
    }
}
