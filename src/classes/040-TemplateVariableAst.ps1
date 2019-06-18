class TemplateVariableAst : TemplateRootAst {

    [PSObject]$Value

    TemplateVariableAst ([string]$VariableName, [PSObject]$InputObject, [TemplateRootAst]$Parent) {

        $this.Parent = $Parent
        $this.Name = $VariableName
        $this.Value = $InputObject
    }
}
