class TemplateParameterAst : TemplateRootAst {

    [string]$Type

    [PSCustomObject]$Metadata

    [PSObject]$DefaultValue

    [PSObject]$RawDefaultValue

    [PSObject]$Value

    [PSObject]$RawValue

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
            if ($Property -eq 'DefaultValue') {
                $this.RawDefaultValue = $InputObject.$Property

                if ($this.RawDefaultValue -match '^\[') {
                    $this.DefaultValue = Resolve-ArmFunction -InputString $this.RawDefaultValue -Template $this
                }
                else {
                    $this.DefaultValue = $this.RawDefaultValue
                }
            }
            elseif ($Property -eq 'Value') {
                $this.RawValue = $InputObject.$Property

                if ($this.RawValue.GetType().Name -eq 'PSCustomObject') {
                    $this.Value = $this.ResolveValue($this.RawValue)
                }
                elseif ($this.RawValue -match '^\[') {
                    $this.Value = Resolve-ArmFunction -InputString $this.RawValue -Template $this
                }
                else {
                    $this.Value = $this.RawValue
                }
            }
            else {
                $this.$Property = $InputObject.$Property
            }
        }
    }
}
