class TemplateAst : TemplateRootAst {

    [string]${`$Schema} = "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"

    [string]$ContentVersion = "1.0.0.0"

    [string]$ApiProfile

    [TemplateParameterAst[]]$Parameters

    [TemplateVariableAst[]]$Variables

    [TemplateResourceAst[]]$Resources

    [TemplateOutputAst[]]$Outputs

    [TemplateFunctionAst[]]$Functions

    TemplateAst ([string]$Path) {
        if (Test-Path -Path $Path) {
            $InputObject = Get-Content -Path $Path -Raw | ConvertFrom-Json

            if ($this.ValidateRequiredTemplateProperties($InputObject)) {
                $this.SetProperties($InputObject)
            }
            else {
                Write-Error -Message "Invalid template provided" -ErrorAction Stop
            }
        }
        else {
            Write-Error -Message "Invalid Path provided." -ErrorAction Stop
        }
    }
    
    TemplateAst ([PSCustomObject]$InputObject) {
        if ($this.ValidateRequiredTemplateProperties($InputObject)) {
            $this.SetProperties($InputObject)
        }
    }

    [bool] ValidateRequiredTemplateProperties ([PSCustomObject]$InputObject) {
        if (-not($InputObject.PSObject.Properties.Name.Contains('$schema'))) {
            return $false
        }
        if (-not($InputObject.PSObject.Properties.Name.Contains('contentVersion'))) {
            return $false
        }
        if (-not($InputObject.PSObject.Properties.Name.Contains('resources'))) {
            return $false
        }
        return $true
    }

    [void] SetProperties ([PSCustomObject]$InputObject) {

        if ($this.$('$schema') -ne $InputObject.$('$schema')) {
            $this.$('$schema') = $InputObject.$('$schema')
        }

        $this.ContentVersion = $InputObject.ContentVersion
            
        if ($InputObject.ApiProfile) {
            $this.ApiProfile = $InputObject.ApiProfile
        }
    }

}
