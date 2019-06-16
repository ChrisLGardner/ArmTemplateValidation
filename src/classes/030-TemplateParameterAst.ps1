class TemplateParameterAst : TemplateRootAst {
    
    [string]$Type

    [hashtable]$Metadata

    [PSObject]$DefaultValue

    [PSObject]$Value

    [PSObject[]]$AllowedValues

    [int]$MinValue

    [int]$MaxValue

    [int]$MinLength

    [int]$MaxLength
}
