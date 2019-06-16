param (
    [System.Io.FileInfo]$Path
)

$ArmTemplates = Get-ChildItem -Path $Path -Filter *.json | Where-Object Fullname -notlike '*.parameters.json'

foreach ($Template in $ArmTemplates) {
    Describe "Validating $($Template.fullname)" {
        
        $Script:InvalidJson = $true

        It "Should be a valid JSON file" {
            try {
                $Script:TemplateObject = Get-Content -Path $Template.Fullname -Raw | ConvertFrom-Json
                $Script:InvalidJson = $false
            }
            catch {
                $false | Should -Be $true -Because "Template is not valid JSON: $($_.Exception.Message.split('{')[0])"
            }
        }

        It "Should have all required elements" -Skip:$Script:InvalidJson {
            $Script:TemplateObject.PSObject.Properties.Name | Should -Be @('$schema','contentVersion','parameters','variables','resources','outputs')
        }

        It "Should have a valid content version" -Skip:$Script:InvalidJson {
            $Script:TemplateObject.contentVersion -as [Version] | Should -Not -BeNullOrEmpty -Because "it was a valid version number"
        }

        It "Should have no High severity issues from the AzSK best practices scanner" -Skip:$Script:InvalidJson {

        }

        It "Should not use unapproved parameter names" -Skip:$Script:InvalidJson {
            $Script:TemplateObject.parameters.PSObject.Properties.Name | Should -Not -BeIn @()
        }

        It "Should pass all required parameters to nested templates" -Skip:$Script:InvalidJson {

        }

        It "Should only use outputs that are from nested templates" -Skip:$Script:InvalidJson {

        }

        It "Should not use any properties that don't exist on objects" -Skip:$Script:InvalidJson {

        }
    }
}
