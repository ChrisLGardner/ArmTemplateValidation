Function Resolve-ArmformatFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )
}
