class TemplateRootAst {
    [string]$Name

    [TemplateRootAst]$Parent

    TemplateRootAst () {}


    [PSObject] ResolveValue ([PSObject]$InputObject) {

        foreach ($property in $InputObject.PSObject.Properties.Name) {
            if ($InputObject.$property.GetType().Name -eq 'PSCustomObject') {
                $InputObject.$Property = $this.ResolveValue($InputObject.$Property)
            }
            elseif ($InputObject.$Property -match '^\[') {
                $InputObject.$property = Resolve-ArmFunction -InputString $InputObject.$property -Template ($this)
            }
        }

        return $InputObject
    }
}
