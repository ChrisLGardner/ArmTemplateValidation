---
external help file: ArmTemplateValidation-help.xml
Module Name: ArmTemplateValidation
online version:
schema: 2.0.0
---

# Invoke-ArmTemplateValidation

## SYNOPSIS

Validates that a provided ARM template is actually valid ARM without calling the ARM API.

## SYNTAX

```
Invoke-ArmTemplateValidation [-Path] <String> [[-Parameters] <Hashtable>] [[-ParameterFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Validates that a provided ARM template is actually valid ARM without calling the ARM API.

Any parameters or variables within the templates are expanded out where possible and any ARM functions
are ran, with some dummy values being populated in various situations where the API would generate it.

The function will return a TemplateAst object, containing the template and all it's nested resources, parameters, variables, outputs, and functions. The object will contain a Valid property which indicates if the template itself is actually valid. In the case where it is not a valid template then the Errors property will contain a list of issues that have been found with the template.

## EXAMPLES

### Example 1

```powershell
PS C:\> Invoke-ArmTemplateValidation -Path C:\Templates\azuredeploy.json

$Schema        : https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#
ContentVersion : 1.0.0.0
Valid          : True
ApiProfile     :
Parameters     :
Variables      :
Resources      : {teststorageaccount}
Outputs        :
Functions      :
Errors         :
Name           :
Parent         :
```

This will return a TemplateAst object that shows the various properties of an ARM template and if it's a valid template.

### Example 2

```powershell
PS C:\> Invoke-ArmTemplateValidation -Path C:\Templates\azuredeploy.json -ParameterFile C:\Templates\azuredeploy.parameters.json

$Schema        : https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#
ContentVersion : 1.0.0.0
Valid          : True
ApiProfile     :
Parameters     : {StorageAccountName}
Variables      :
Resources      : {[parameters('StorageAccountName')]}
Outputs        :
Functions      :
Errors         :
Name           :
Parent         :
```

This will take a template and it's related parameters file and then return a TemplateAst object that shows the various properties of an ARM template and if it's a valid template. Any values in the parameters file will be populated into the Value property on the relevant parameter in the template. If a parameter is provided in the Parameters file but not on the template then an error will be written out, rather than adding to the Errors log as the issue isn't strictly with the ARM template itself.

### Example 3

```powershell
PS C:\> $Parameters = @{
    StorageAccountName = 'teststorage'
}
PS C:\> Invoke-ArmTemplateValidation -Path C:\Templates\azuredeploy.json -Parameters $Parameters

$Schema        : https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#
ContentVersion : 1.0.0.0
Valid          : True
ApiProfile     :
Parameters     : {StorageAccountName}
Variables      :
Resources      : {[parameters('StorageAccountName')]}
Outputs        :
Functions      :
Errors         :
Name           :
Parent         :
```

This will take a template and a hashtable of parameter values and then return a TemplateAst object that shows the various properties of an ARM template and if it's a valid template. Any values in the parameters will be populated into the Value property on the relevant parameter in the template. If a parameter is provided in the Parameters but not on the template then an error will be written out, rather than adding to the Errors log as the issue isn't strictly with the ARM template itself.

## PARAMETERS

### -ParameterFile

File path to a ARM template parameters file. Should be a local file currently.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parameters

Hashtable containing ARM template parameters and the values to assign to them.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

File path to the ARM template to validate. Should be a local file currently.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### TemplateAst
## NOTES

## RELATED LINKS
