Function Resolve-ArmparametersFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    Get-ArmPropertyValue -Name $Arguments.Token.StringValue -Type 'Parameter' -Template $Template
}
