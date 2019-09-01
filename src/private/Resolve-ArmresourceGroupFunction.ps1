Function Resolve-ArmresourceGroupFunction {
    [cmdletbinding()]
    param (
        [parameter()]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    if (-not $Script:SubscriptionId) {
        $Script:SubscriptionId = Resolve-ArmSubscriptionFunction | Select-Object -ExpandProperty Id
    }
    if (-not $Script:ResourceGroupName) {
        $Script:ResourceGroupName = New-Guid | Select-Object -ExpandProperty Guid
    }
    [PSCustomObject]@{
        id = "/subscriptions/$($Script:SubscriptionId)/resourceGroups/$Script:ResourceGroupName"
        name = "$Script:resourceGroupName"
        type = "Microsoft.Resources/resourceGroups"
        location = "resourceGroupLocation"
        managedBy = "{identifier-of-managing-resource}"
        tags = @{
        }
        properties = @{
          provisioningState = "{status}"
        }
      }
}
