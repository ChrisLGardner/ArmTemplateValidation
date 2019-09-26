class TemplateResourceAst : TemplateRootAst {

    [string]$Type

    [string]$ApiVersion

    [string]$Location

    [string[]]$DependsOn

    [PSCustomObject]$Tags

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

        $this.HasRequiredProperties($InputObject)

        foreach ($Property in $InputObject.PSObject.Properties.Name.Where({$_ -notin @('resources','copy','sku','plan')})) {
            $this.$Property = $this.ResolveValue($InputObject.$Property)
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

            $AddMemberSplat = @{
                InputObject = $this.Properties
                MemberType = "NoteProperty"
                Name = "TemplateRaw"
                Value = $InputObject.Properties.Template
            }
            Add-Member @AddMemberSplat

            $this.Properties.Template = [TemplateAst]::New($InputObject.Properties.Template, $this)
        }
        elseif ($InputObject.Type -eq "Microsoft.Resources/deployments" -and
                $InputObject.Properties.templateLink) {

            $AddMemberSplat = @{
                InputObject = $this.Properties
                MemberType = "NoteProperty"
                Name = "TemplateRaw"
                Value = $this.ResolveTemplate($InputObject.Properties.TemplateLink.Uri)
            }
            Add-Member @AddMemberSplat

            $AddMemberSplat = @{
                InputObject = $this.Properties
                MemberType = "NoteProperty"
                Name = "Template"
                Value = ([TemplateAst]::New($this.Properties.TemplateRaw, $this))
            }
            Add-Member @AddMemberSplat
        }

        if ($InputObject.Type -eq "Microsoft.Resources/deployments" -and
            $InputObject.Properties.Parameters) {

            foreach ($parameter in $InputObject.Properties.Parameters.PSObject.Properties.Name) {

                $AddMemberSplat = @{
                    InputObject = $InputObject.Properties.Parameters.$parameter
                    MemberType = "NoteProperty"
                    Name = "ValueRaw"
                    Value = $InputObject.Properties.Parameters.$parameter.Value
                }
                Add-Member @AddMemberSplat

                if ($InputObject.Properties.Parameters.$parameter.Value -match '^\[') {
                    $ResolveArmFunctionSplat = @{
                        InputString = $InputObject.Properties.Parameters.$parameter.Value
                        Template = $this
                    }
                    $InputObject.Properties.Parameters.$parameter.Value = Resolve-ArmFunction @ResolveArmFunctionSplat
                }
            }
        }
    }

    [bool] HasRequiredProperties ([PSCustomObject]$InputObject) {
        if (-not($InputObject.apiVersion -and
                    $InputObject.apiVersion -match '^\d{4}-\d{2}-\d{2}(-preview)?$')) {
            $this.Parent.Errors += 'Invalid template: Resource does not contain a valid ApiVersion'
            return $false
        }
        if (-not($InputObject.type -and
                    $InputObject.type -match '[a-z\.]+(\/[a-z]+)+')) {
            $this.Parent.Errors += 'Invalid template: Resource does not contain a valid type'
            return $false
        }
        if (-not($InputObject.name)) {
            $this.Parent.Errors += 'Invalid template: Resource does not contain a Name'
            return $false
        }
        return $true
    }

    [PSCustomObject] ResolveTemplate ([string]$TemplateUri) {
        if ($TemplateUri -match '^\[') {
            $TemplateUri = Resolve-ArmFunction -InputString $TemplateUri -Template $this.Parent
        }
        if ($TemplateUri -match '^http') {
            $TempPath = "$Env:Temp\$((New-Guid).guid).txt"
            $TemplateOutput = Invoke-RestMethod -Uri $TemplateUri -ErrorAction Stop -OutFile $TempPath
            $TemplateOutput = Get-Content -Path $TempPath | ConvertFrom-Json
            $Null = Remove-Item -Path $TempPath
        }
        else {
            $TemplateOutput = Get-Content -Path $TemplateUri -Raw | ConvertFrom-Json
        }

        return $TemplateOutput
    }
}
