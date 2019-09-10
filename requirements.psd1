@{
    PSDependOptions = @{
        Target = '.\Dependencies'
        AddToPath = $true
    }
    'Pester' = @{
        Version = '4.9.0'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'psake' = @{
        Version = '4.8.0'
    }
    'BuildHelpers' = @{
        Version = '2.0.10'
    }
    'PowerShellBuild' = @{
        Version = '0.4.0'
    }
    'Assert' = @{
        Version = '0.9.5'
    }
    'Configuration' = @{
        Version = '1.3.1'
    }
    'PSScriptAnalyzer' = @{
        Version = '1.18.2'
    }
}
