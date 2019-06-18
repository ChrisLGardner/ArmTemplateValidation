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

            if ($this.HasRequiredTemplateProperties($InputObject)) {
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

    TemplateAst () {}

    TemplateAst ([PSCustomObject]$InputObject) {
        if ($this.HasRequiredTemplateProperties($InputObject)) {
            $this.SetProperties($InputObject)
        }
        else {
            Write-Error -Message "Invalid template provided" -ErrorAction Stop
        }
    }

    TemplateAst ([PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {
        $this.Parent = $Parent

        if ($this.HasRequiredTemplateProperties($InputObject)) {
            $this.SetProperties($InputObject)
        }
        else {
            Write-Error -Message "Invalid template provided" -ErrorAction Stop
        }
    }

    [bool] HasRequiredTemplateProperties ([PSCustomObject]$InputObject) {
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

        $this.SetResources($InputObject)

        if ($InputObject.ApiProfile) {
            $this.ApiProfile = $InputObject.ApiProfile
        }

        if ($InputObject.Parameters) {
            $this.SetParameters($InputObject)
        }

        if ($InputObject.Variables) {
            $this.SetVariables($InputObject)
        }

        if ($InputObject.Functions) {
            $this.SetFunctions($InputObject)
        }

        if ($InputObject.Outputs) {
            $this.SetOutputs($InputObject)
        }

    }

    [void] SetResources ([PSCustomObject]$InputObject) {
        $this.Resources = foreach ($Resource in $InputObject.Resources) {
            [TemplateResourceAst]::New($Resource, $this)
        }
    }

    [void] SetParameters ([PSCustomObject]$InputObject) {
        $this.Parameters = foreach ($Parameter in $InputObject.Parameters.PSObject.Properties.Name) {
            [TemplateParameterAst]::New($Parameter, $InputObject.Parameters.$Parameter, $this)
        }
    }

    [void] SetVariables ([PSCustomObject]$InputObject) {
        $this.Variables = foreach ($Variable in $InputObject.Variables.PSObject.Properties.Name) {
            [TemplateVariableAst]::New($Variable, $InputObject.Variables.$Variable, $this)
        }
    }

    [void] SetFunctions ([PSCustomObject]$InputObject) {
        $this.Functions = foreach ($Function in $InputObject.Functions) {
            [TemplateFunctionAst]::New($Function, $this)
        }
    }

    [void] SetOutputs ([PSCustomObject]$InputObject) {
        $this.Outputs = foreach ($Output in $InputObject.Outputs.PSObject.Properties.Name) {
            [TemplateOutputAst]::New($Output, $InputObject.Outputs.$Output, $this)
        }
    }

}
