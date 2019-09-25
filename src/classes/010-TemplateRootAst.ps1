class TemplateRootAst {
    [string]$Name

    [TemplateRootAst]$Parent

    TemplateRootAst () {}


    [PSObject] ResolveValue ([PSObject]$InputObject) {

        if ($InputObject -is [String] -and $InputObject -match '^\[') {
            $InputObject = Resolve-ArmFunction -InputString $InputObject -Template ($this)
        }
        elseif ($InputObject -is [Array]) {
            foreach ($item in $InputObject) {
                $item = $this.ResolveValue($Item)
            }
        }
        elseif ($InputObject -isnot [String]) {
            foreach ($property in $InputObject.PSObject.Properties.Name) {
                if ($InputObject.$property.GetType().Name -eq 'PSCustomObject') {
                    $InputObject.$Property = $this.ResolveValue($InputObject.$Property)
                }
                elseif ($InputObject.$property -is [Array]) {
                    foreach ($item in $InputObject.$property) {
                        $item = $this.ResolveValue($Item)
                    }
                }
                elseif ($InputObject.$Property -match '^\[') {
                    $InputObject.$property = Resolve-ArmFunction -InputString $InputObject.$property -Template ($this)
                }
            }
        }

        return $InputObject
    }
}
