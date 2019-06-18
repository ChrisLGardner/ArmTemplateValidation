class ResourcePlan : TemplateRootAst {
    [string]$PromotionCode
    [string]$Publisher
    [string]$Product
    [string]$Version

    ResourcePlan ([PSCustomObject]$InputObject, [TemplateRootAst]$Parent) {

        $this.Parent = $Parent

        if ($InputObject.PSObject.Properties.Name -notmatch 'name|PromotionCode|Publisher|Product|Version') {
            Write-Error -Message "No matching properties, expected one or more of: Name, PromotionCode, Publisher, Product, Version" -ErrorAction Stop
        }

        foreach ($Property in $InputObject.PSObject.Properties.Name.Where({$_ -match 'name|PromotionCode|Publisher|Product|Version'})) {
            $this.$Property = $InputObject.$Property
        }
    }
}
