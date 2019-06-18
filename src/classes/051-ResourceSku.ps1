class ResourceSku : TemplateRootAst {
    [string]$Tier
    [string]$Size
    [string]$Family
    [int]$Capacity

    ResourceSku ([PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {

        $this.Parent = $Parent

        if ($InputObject.PSObject.Properties.Name -notmatch 'name|tier|size|family|capacity') {
            Write-Error -Message "No matching properties, expected one or more of: Name, Tier, Size, Family, Capacity" -ErrorAction Stop
        }

        foreach ($Property in $InputObject.PSObject.Properties.Name.Where({$_ -match 'name|tier|size|family|capacity'})) {
            $this.$Property = $InputObject.$Property
        }
    }
}
