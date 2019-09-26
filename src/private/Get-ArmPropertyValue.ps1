Function Get-ArmPropertyValue {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$Type,

        [parameter(Mandatory)]
        [string]$Name,

        [parameter(Mandatory)]
        [TemplateRootAst]$Template
    )

    $Name = $Name -replace '"' -replace "'"

    if ($template -isnot [TemplateAst] -and $template.parent -is [TemplateAst]) {
        $output = Get-ArmPropertyValue -Type $Type -Name $Name -Template $Template.Parent
    }
    elseif ($Type -eq 'Variable') {
        if ($Template.Variables.Where({$_.Name -eq $Name})) {
            $output = $Template.Variables.Where({$_.Name -eq $Name}).Value
        }
        elseif ($Template.Parent -is [TemplateResourceAst] -and $Template.Parent.Type -eq 'Microsoft.Resources/Deployments') {
            $output = Get-ArmPropertyValue -Type $Type -Name $Name -Template $Template.Parent.Parent
        }
    }
    elseif ($Type -eq 'Parameter') {
        if ($Template.Parent -is [TemplateResourceAst] -and $Template.Parent.Type -eq 'Microsoft.Resources/Deployments') {
            $output = $Template.Parent.Properties.Parameters.$Name.Value
        }
        elseif ($Template.Parameters.Where({$_.Name -eq $Name})) {
            if ($null -eq $Template.Parameters.Where({$_.Name -eq $Name}).Value) {
                $output = $Template.Parameters.Where({$_.Name -eq $Name}).DefaultValue
            }
            else {
                $output = $Template.Parameters.Where({$_.Name -eq $Name}).Value
            }
        }
    }

    if ($output -and $output -isnot [ArmValue] -and $output.GetType().Name -ne 'PSCustomObject') {
        [ArmStringValue]::New(([ArmToken]::Create([ArmTokenType]::Literal, 0, $output)))
    }
    else {
        $output
    }
}
