Function Resolve-ArmreferenceFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    if ($Arguments.Token.StringValue -notmatch '\/subscriptions\/') {
        if ($template -isnot [TemplateAst] -and $Template.Parent -is [TemplateAst]) {
            $Template.Parent.Resources.Where({$_.Name -eq $Arguments.Token.StringValue -replace "'"})
        }
        elseif ($Template -is [TemplateAst]) {
            $Template.Resources.Where({$_.Name -eq $Arguments.Token.StringValue -replace "'"})
        }
    }

}
