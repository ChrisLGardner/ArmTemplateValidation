class TemplateParameterAst : TemplateRootAst {

    [string]$Type

    [PSCustomObject]$Metadata

    [PSObject]$DefaultValue

    [PSObject]$Value

    [PSObject[]]$AllowedValues

    [int]$MinValue

    [int]$MaxValue

    [int]$MinLength

    [int]$MaxLength

    TemplateParameterAst ([string]$ParameterName, [PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {
        $this.Parent = $Parent

        if (-not($InputObject.type)) {
            Write-Error -Message "Missing required properties, expected: Type" -ErrorAction Stop
        }

        $this.Name = $ParameterName

        foreach ($Property in $InputObject.PSObject.Properties.Name) {
            $this.$Property = $InputObject.$Property
        }
    }
}
