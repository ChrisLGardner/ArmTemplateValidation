Function Resolve-ArmmulFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )
}
