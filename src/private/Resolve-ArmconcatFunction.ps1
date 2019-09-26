Function Resolve-ArmconcatFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    $Arguments.Token.StringValue -join '' -replace "'"
}
