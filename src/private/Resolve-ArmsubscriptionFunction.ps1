Function Resolve-ArmsubscriptionFunction {
    [cmdletbinding()]
    param (
        [parameter()]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    if (-not $Script:SubscriptionId) {
        $Script:SubscriptionId = New-Guid | Select-Object -ExpandProperty Guid
    }
    if (-not $Script:TenantId) {
        $Script:TenantId = New-Guid | Select-Object -ExpandProperty Guid
    }

    [PSCustomObject]@{
        id = "/subscriptions/$($Script:SubscriptionId)"
        subscriptionId = "$($Script:SubscriptionId)"
        tenantId = "$($Script:TenantId)"
        displayName = "name-of-subscription"
    }
}
