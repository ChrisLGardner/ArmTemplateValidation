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

    & $Command $Arguments $Template
}

