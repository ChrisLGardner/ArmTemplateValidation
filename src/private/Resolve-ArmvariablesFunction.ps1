Function Resolve-ArmvariablesFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    Get-ArmPropertyValue -Name $Arguments.Token.StringValue -Type 'Variable' -Template $Template
}
