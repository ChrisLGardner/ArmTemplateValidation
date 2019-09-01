class TemplateVariableAst : TemplateRootAst {

    [PSObject]$Value

    [PSObject]$RawValue

    TemplateVariableAst ([string]$VariableName, [PSObject]$InputObject, [TemplateRootAst]$Parent) {

        $this.Parent = $Parent
        $this.Name = $VariableName
        $this.RawValue = $InputObject

        if ($this.RawValue.GetType().Name -eq 'PSCustomObject') {
            $this.Value = $this.ResolveValue($this.RawValue)
        }
        elseif ($this.RawValue -match '^\[') {
            $this.Value = Resolve-ArmFunction -InputString $this.RawValue -Template ($this)
        }
        else {
            $this.Value = $this.RawValue
        }
    }

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
