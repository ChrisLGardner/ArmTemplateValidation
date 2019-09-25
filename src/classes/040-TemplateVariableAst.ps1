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

}
