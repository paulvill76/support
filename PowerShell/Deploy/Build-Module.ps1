. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Check PowerShell Gallery for module version info')
$PSGalleryInfo = Get-PSGalleryModuleVersion -Name:($ModuleName) -ReleaseType:($ReleaseType) #('Major', 'Minor', 'Patch')
$ModuleVersion = $PSGalleryInfo.NextVersion
Write-Host ('[status]PowerShell Gallery Name:' + $PSGalleryInfo.Name + ';CurrentVersion:' + $PSGalleryInfo.Version + '; NextVersion:' + $ModuleVersion )
###########################################################################
Write-Host ('[status]Validate that module root structure is valid')
ForEach ($RequiredItem In ($RequiredFolders + $RequiredFiles))
{
    $RequiredItemPath = $Folder_Module + $PathDeliminator + $RequiredItem
    If (!(Test-Path -Path:($RequiredItemPath)))
    {
        Write-Error ('A required folder path does not exist:' + $RequiredItemPath)
    }
}
# ###########################################################################
Write-Host ('[status]Building New-JCModuleManifest')
New-JCModuleManifest -Path:($File_Psd1) `
    -FunctionsToExport:($Functions_Public.BaseName | Sort-Object) `
    -RootModule:((Get-Item -Path:($File_Psm1)).Name) `
    -ModuleVersion:($ModuleVersion)
# -FormatsToProcess:((Get-Item -Path:($File_Ps1Xml)).Name)
