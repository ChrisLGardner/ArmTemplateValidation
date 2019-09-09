function Invoke-ArmTemplateValidation {
    [cmdletbinding()]
    [OutputType([TemplateAst])]
    param (
        [parameter(Mandatory)]
        [ValidateScript({
            if (-not (Test-Path -Path $_)) {
                Write-Error "Invalid path specified from template. Please check file exists." -ErrorAction Stop
            }
            $true
        })]
        [String]$Path,

        [parameter()]
        [Hashtable]$Parameters,

        [parameter()]
        [ValidateScript({
            if (-not (Test-Path -Path $_)) {
                Write-Error "Invalid path specified from template parameters. Please check file exists." -ErrorAction Stop
            }
            $true
        })]
        [string]$ParameterFile
    )

    $AllParameters = @()

    if ($PSBoundParameters.ContainsKey('Parameters')) {
        foreach ($Parameter in $Parameters.Keys) {
            $AllParameters += [PSCustomObject]@{
                $Parameter = [PSCustomObject]@{
                    Value = $Parameters[$Parameter]
                }
            }
        }
    }

    if ($PSBoundParameters.ContainsKey('ParameterFile')) {
        $ParameterFileImport = Get-Content -Path $ParameterFile -Raw | ConvertFrom-Json

        foreach ($Parameter in $ParameterFileImport.Parameters.PSObject.Properties.Name) {
            $AllParameters += [PSCustomObject]@{
                $Parameter = $ParameterFileImport.Parameters.$Parameter
            }
        }
    }

    if ($AllParameters.Count -gt 0) {
        $Template = [TemplateAst]::New($Path, $AllParameters)
    }
    else {
        $Template = [TemplateAst]::New($Path)
    }

    $Template
}
