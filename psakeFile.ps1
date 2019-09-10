param (
    [Version]$Version
)

properties {
    # Disable "compiling" module into monolithinc PSM1.
    # This modifies the default behavior from the "Build" task
    # in the PowerShellBuild shared psake task module
    $PSBPreference.Build.CompileModule = $true
    $PSBPreference.Test.OutputFile = '../Output/testResults.xml'
    $PSBPreference.Help.DefaultLocale = 'en'
}

task VersionManifest -action {
    $Manifest = Get-ChildItem -Path .\Src\*.psd1 | Select-String -Pattern 'RootModule' | Select-Object -ExpandProperty Path -First 1

    Update-MetaData -Path $Manifest -PropertyName ModuleVersion -Value $Version
}

task default -depends VersionManifest, Test

task Test -FromModule PowerShellBuild -Version '0.4.0'
