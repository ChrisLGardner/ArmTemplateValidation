Function Resolve-ArmaddFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )
}
