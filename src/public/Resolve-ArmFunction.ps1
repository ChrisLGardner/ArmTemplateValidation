Function Resolve-ArmFunction {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$InputString,

        [parameter()]
        [TemplateRootAst]$Template
    )

    $Tokens = [ArmParser]::Parse($InputString)

    $Function = $Tokens.Expression.NameToken.StringValue

    $Arguments = $Tokens.Expression.ArgumentExpression

    $Command = Get-Command -Name "Resolve-Arm${Function}Function"

    & $Command $Arguments $Template
}

