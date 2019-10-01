Function Resolve-ArmFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory, ParameterSetName = 'InputString')]
        [string]$InputString,

        [parameter(ParameterSetName = 'InputObject')]
        [ArmValue]$InputObject,

        [parameter()]
        [TemplateRootAst]$Template
    )

    if ($PSCmdlet.ParameterSetName -eq 'InputString') {
        $Tokens = [ArmParser]::Parse($InputString).Expression
    }

    if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
        $Tokens = $InputObject
    }

    if ($Tokens -is [ArmPropertyAccess]) {
        $Properties = while ($tokens -is [ArmPropertyAccess]) {
            $Tokens.NameToken.StringValue
            $Tokens = $Tokens.Source
        }
    }
    $Function = $Tokens.NameToken.StringValue

    $Arguments = foreach ($argument in $Tokens.ArgumentExpression) {
        if ($argument.NameToken) {
            Resolve-ArmFunction -InputObject $argument -Template $Template
        }
        else {
            $argument
        }
    }

    $Command = Get-Command -Name "Resolve-Arm${Function}Function"

    $Output = & $Command $Arguments $Template

    if ($Properties) {
        if ($Properties[-1] -eq 'outputs') {
            $Properties[-2] = "Where({`$_.name -eq $($Properties[-2])})"
        }
        if ($Output -is [TemplateResourceAst]) {
            $Properties += 'Template','Properties'
        }
        [Array]::Reverse($Properties)
        foreach ($Prop in $Properties) {
            $Output = $Output.$Prop
        }
    }
    $Output
}

