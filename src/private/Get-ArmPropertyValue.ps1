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

    if ($template -isnot [TemplateAst] -and $template.parent -is [TemplateAst]) {
        Get-ArmPropertyValue -Type $Type -Name $Name -Template $Template.Parent
    }
    elseif ($Type -eq 'Variable') {
        if ($Template.Variables.Where({$_.Name -eq $Name})) {
            $Template.Variables.Where({$_.Name -eq $Name}).Value
        }
        elseif ($Template.Parent -is [TemplateResourceAst] -and $Template.Parent.Type -eq 'Microsoft.Resources/Deployments') {
            Get-ArmPropertyValue -Type $Type -Name $Name -Template $Template.Parent.Parent
        }
    }
    elseif ($Type -eq 'Parameter') {
        if ($Template.Parent -is [TemplateResourceAst] -and $Template.Parent.Type -eq 'Microsoft.Resources/Deployments') {
            $Template.Parent.Properties.Parameters.$Name.Value
        }
        elseif ($Template.Parameters.Where({$_.Name -eq $Name})) {
            if ($null -eq $Template.Parameters.Where({$_.Name -eq $Name}).Value) {
                $Template.Parameters.Where({$_.Name -eq $Name}).DefaultValue
            }
            else {
                $Template.Parameters.Where({$_.Name -eq $Name}).Value
            }
        }

    }
    else {

    }
}
