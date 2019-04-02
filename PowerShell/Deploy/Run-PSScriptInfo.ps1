. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
# Run Test-ScriptFileInfo to make sure its not failing any tests
$ScriptFileInfoResults = Get-ChildItem -Path:($Folder_Public) -Recurse -File | ForEach-Object { Test-ScriptFileInfo -Path:($_.FullName) -ErrorAction:('Ignore') }
If ($ScriptFileInfoResults)
{
    $ScriptFileInfoResults
    Write-Error ('Go fix the ScriptFileInfo results!')
}
Else
{
    Write-Host ('[success]ScriptFileInfo returned no results')
}

# Test-ScriptFileInfo -Path:('')

# New-ScriptFileInfo -Path:('') `
#     -Description:('') `
#     -Version:('') `
#     -Guid:('') `
#     -Author:('') `
#     -CompanyName:('') `
#     -Copyright:('') `
#     -RequiredModules:('') `
#     -ExternalModuleDependencies:('') `
#     -RequiredScripts:('') `
#     -ExternalScriptDependencies:('') `
#     -Tags:('') `
#     -ProjectUri:('') `
#     -LicenseUri:('') `
#     -IconUri:('') `
#     -ReleaseNotes:('') `
#     -PrivateData:('')

# Update-ScriptFileInfo  -Path:('') `
#     -Description:('') `
#     -Version:('') `
#     -Guid:('') `
#     -Author:('') `
#     -CompanyName:('') `
#     -Copyright:('') `
#     -RequiredModules:('') `
#     -ExternalModuleDependencies:('') `
#     -RequiredScripts:('') `
#     -ExternalScriptDependencies:('') `
#     -Tags:('') `
#     -ProjectUri:('') `
#     -LicenseUri:('') `
#     -IconUri:('') `
#     -ReleaseNotes:('') `
#     -PrivateData:('')
