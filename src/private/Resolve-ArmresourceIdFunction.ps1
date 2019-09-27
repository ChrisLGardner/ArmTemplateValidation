Function Resolve-ArmresourceIdFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [ArmValue[]]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    $Output = "$(Resolve-ArmResourceGroupFunction -Template $Template | Select-Object -ExpandProperty Id)/"
    $strings = $Arguments.Token.StringValue.Where({$_ -notmatch '\/subscriptions\/'})

    if ($strings[0] -match '(\/\w+){2,}') {
        $type = $strings[0] -split '\/'
        $parent = "$($type[0])/$($type[1])"
        $Output += "$parent/"

        for ($i = 1; $i -lt $strings.count; $i++) {
            $Output += "$($strings[$i])/"
            $Output += "$($Type[$i+1])/"
        }
    }
    else {
        $Output += $Strings -join '/'
    }

    $Output.TrimEnd('/')
}
