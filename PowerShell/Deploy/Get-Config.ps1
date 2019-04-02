<#
Notes: Search for: Not used
References:
    -Building a PowerShell Module: https://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/
    -Decorating PowerShell Objects (.ps1xml): https://ramblingcookiemonster.github.io/Decorating-Objects/
    -Run Git commands in a script: https://docs.microsoft.com/en-us/azure/devops/pipelines/scripts/git-commands?view=azure-devops&tabs=yaml
    -How to Write a PowerShell Module Manifest: https://docs.microsoft.com/en-us/powershell/developer/module/how-to-write-a-powershell-module-manifest
    -BuildHelpers Invoke-Git.ps1: https://github.com/RamblingCookieMonster/BuildHelpers/blob/master/BuildHelpers/Public/Invoke-Git.ps1
#>
# Set variables from Azure Pipelines
$ModuleName = $env:moduleName
$ModuleFolderName = $env:moduleFolderName
$JCAPIKEY = $env:xApiKey
$SingleAdminAPIKey = $env:xApiKey
$NuGetApiKey = $env:nuGetApiKey
$GitSourceBranch = $env:BUILD_SOURCEBRANCHNAME
$GitTargetBranch = $env:targetBranchName
$ScriptRoot = Switch ($env:deployFolder) { $true { $env:deployFolder } Default { $PSScriptRoot } }
$Folder_ModuleRootPath = (Get-Item -Path:($ScriptRoot)).Parent.FullName
$ReleaseType = 'Major' # TODO Convert to Env variable
## For testing locally
# $ModuleName = 'JumpCloud'
# $ModuleFolderName = 'JumpCloud Module'
# $JCAPIKEY = ''
# $SingleAdminAPIKey = ''
# $NuGetApiKey = ''
# $GitSourceBranch = ''
# $GitTargetBranch = ''
# Define OS specific variables
$WindowsDeliminator = '\'
$UnixDeliminator = '/'
$PathDeliminator = Switch ([environment]::OSVersion.Platform) { 'Win32NT' { $WindowsDeliminator }'Unix' { $UnixDeliminator } }
# Define folder path variables
$RequiredFolders = ('Docs', 'Private', 'Public', 'Tests', 'LICENSE', ($ModuleName + '.psm1'), ($ModuleName + '.psd1'))
$Folder_Module = $Folder_ModuleRootPath + $PathDeliminator + $ModuleFolderName
$Folder_Private = $Folder_Module + $PathDeliminator + 'Private'
$Folder_Public = $Folder_Module + $PathDeliminator + 'Public'
$Folder_HelpFiles = $Folder_Module + $PathDeliminator + 'en-US'
$Folder_Tests = $Folder_Module + $PathDeliminator + 'Tests'
$Folder_Docs = $Folder_Module + $PathDeliminator + 'Docs'
# Define file path variables
$File_Psm1 = $Folder_Module + $PathDeliminator + $ModuleName + '.psm1'
$File_Psd1 = $Folder_Module + $PathDeliminator + $ModuleName + '.psd1'
$File_License = $Folder_Module + $PathDeliminator + 'LICENSE' # Not used
$File_Ps1Xml = $Folder_Module + $PathDeliminator + $ModuleName + '.Format.ps1xml'# Not used
$File_HelpTxt = $Folder_HelpFiles + $PathDeliminator + 'about_' + $ModuleName + '.help.txt'# Not used
$File_TestsPs1_Template = '{0}\{1}.{2}.Tests.ps1'# Not used
$File_ModuleMd = $Folder_Docs + $PathDeliminator + $ModuleName + '.md'# Not used
# Get module function names
$Functions_Public = If (Test-Path -Path:($Folder_Public)) { Get-ChildItem -Path:($Folder_Public + $PathDeliminator + '*.ps1') -Recurse }
$Functions_Private = If (Test-Path -Path:($Folder_Private)) { Get-ChildItem -Path:($Folder_Private + $PathDeliminator + '*.ps1') -Recurse } # Not used
# Load deploy functions
$DeployFunctions = @(Get-ChildItem -Path:($PSScriptRoot + '\Functions\*.ps1') -Recurse)
Foreach ($DeployFunction In $DeployFunctions)
{
    Try
    {
        . $DeployFunction.FullName
    }
    Catch
    {
        Write-Error -Message:("Failed to import function $($DeployFunction.FullName): $_")
    }
}
# TODO:Temporary work around
If (Test-Path -Path:($Folder_Module + '\Tests')) { Remove-Item -Path:($Folder_Module + '\Tests') -Force -Recurse }
If (Test-Path -Path:($Folder_Module + '\test')) { Rename-Item -Path:($Folder_Module + '\test') -NewName:('Tests') -Force }
###########################################################################
# KEEP                    | Docs
# KEEP                    | Private
# KEEP                    | Public
# KEEP (RENAME Tests)     | test
# KEEP                    | LICENSE
# KEEP                    | JumpCloud.psm1
# UPDATE FROM SCRIPT VARS | JumpCloud.psd1
# REMOVE                  | ModuleUpdate.ps1
# REMOVE                  | en-Us
# ADD (TBD)               | Template.Format.ps1xml