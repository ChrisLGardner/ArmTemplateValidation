Function Resolve-ArmutcNowFunction {
    [cmdletbinding()]
    param (
        [parameter()]
        [ArmStringValue]$Arguments,

        [parameter()]
        [TemplateRootAst]$Template
    )

    if ($Template -isnot [TemplateParameterAst]) {
        Write-Error -Message "You can't use UtcNow function except in the Parameters block of a tempalte"
    }
    else {
        if ($Arguments) {
            (Get-Date).ToString($Arguments.ToString())
        }
        else {
            (Get-Date).ToString('yyyyMMddTHHmmssZ')
        }
    }
}
