class TemplateFunctionAst : TemplateRootAst {
    [string]$namespace

    [TemplateFunctionMemberAst[]]$members

    TemplateFunctionAst ([PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {
        $this.Parent = $Parent

        $this.Namespace = $InputObject.Namespace
        $this.Members = $InputObject.Members
    }
}
