class TemplateOutputAst : TemplateRootAst {

    [string]$Type

    [PSObject]$Value

    TemplateOutputAst ([string]$OutputName, [PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {
        $this.Parent = $Parent

        if (-not($InputObject.type)) {
            Write-Error -Message "Output - Missing required properties, expected: Type" -ErrorAction Stop
        }

        $this.Name = $OutputName

        foreach ($Property in $InputObject.PSObject.Properties.Name) {
            $this.$Property = $InputObject.$Property
        }
    }
}
