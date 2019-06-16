class TemplateResourceAst : TemplateRootAst {

    [string]$Type

    [string]$ApiVersion

    [string]$Location

    [string[]]$DependsOn

    [hashtable]$Tags

    [PSObject]$Properties

    [string]$Condition

    [string]$Comments

    [TemplateCopyAst]$Copy

    [string]$Kind

    [TemplateResourceAst[]]$Resources

    [ResourceSku]$Sku

    [ResourcePlan]$Plan
}
