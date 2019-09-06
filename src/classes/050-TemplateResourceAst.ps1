class TemplateResourceAst : TemplateRootAst {

    [string]$Type

    [string]$ApiVersion

    [string]$Location

    [string[]]$DependsOn

    [hashtable]$Tags

    [PSObject]$Properties

    [string]$Condition

    [string]$Comments

    [TemplateCopyAst]$Copy

    [string]$Kind

    [TemplateResourceAst[]]$Resources

    [ResourceSku]$Sku

    [ResourcePlan]$Plan

    [string]$ResourceGroup

    TemplateResourceAst ([PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {

        $this.Parent = $Parent

        if (-not($this.HasRequiredProperties($InputObject))) {
            Write-Error -Message "Missing one or more required properties." -ErrorAction Stop
        }

        foreach ($Property in $InputObject.PSObject.Properties.Name.Where({$_ -notin @('resources','copy','sku','plan')})) {
            $this.$Property = $InputObject.$Property
        }

        if ($InputObject.Sku) {
            $this.Sku = [ResourceSku]::New($InputObject.Sku, $this)
        }
        if ($InputObject.Plan) {
            $this.Plan = [ResourcePlan]::New($InputObject.Plan, $this)
        }

        if ($InputObject.Resources.Count -gt 0) {
            $this.Resources = foreach ($Resource in $InputObject.Resources) {
                [TemplateResourceAst]::New($Resource, $this)
            }
        }

        if ($InputObject.Type -eq "Microsoft.Resources/deployments" -and
            $InputObject.Properties.Template) {

            Add-Member -InputObject $this.Properties -MemberType NoteProperty -Name TemplateRaw -Value $InputObject.Properties.Template

            $this.Properties.Template = [TemplateAst]::New($InputObject.Properties.Template, $this)
        }
        elseif ($InputObject.Type -eq "Microsoft.Resources/deployments" -and
                $InputObject.Properties.templateLink) {

            Add-Member -InputObject $this.Properties -MemberType NoteProperty -Name TemplateRaw -Value $this.ResolveTemplate($InputObject.Properties.TemplateLink.Uri)

            Add-Member -InputObject $this.Properties -MemberType NoteProperty -Name Template -Value ([TemplateAst]::New($this.Properties.TemplateRaw, $this))
        }
    }

    [bool] HasRequiredProperties ([PSCustomObject]$InputObject) {
        if (-not($InputObject.apiVersion -and
                    $InputObject.apiVersion -match '^\d{4}-\d{2}-\d{2}(-preview)?$')) {
            return $false
        }
        if (-not($InputObject.type -and
                    $InputObject.type -match '[a-z\.]+(\/[a-z]+)+')) {
            return $false
        }
        if (-not($InputObject.name)) {
            return $false
        }
        return $true
    }

    [PSCustomObject] ResolveTemplate ([string]$TemplateUri) {
        if ($TemplateUri -match '^\[') {
            $TemplateUri = Resolve-ArmFunction -InputString $TemplateUri -Template $this.Parent
        }

        $TemplateOutput = Invoke-RestMethod -Uri $TemplateUri -ErrorAction Stop

        return $TemplateOutput
    }
}
