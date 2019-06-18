@{
    PSDependOptions = @{
        Target = '.\Dependencies'
        AddToPath = $true
    }
    'Pester' = @{
        Version = '4.8.1'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'psake' = @{
        Version = '4.8.0'
    }
    'BuildHelpers' = @{
        Version = '2.0.8'
    }
    'PowerShellBuild' = @{
        Version = '0.3.0'
    }
    'Assert' = @{
        Version = '0.9.5'
    }
}
