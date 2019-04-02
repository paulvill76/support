. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Importing current module: ' + $ModuleName)
Import-Module ($File_Psm1) -Force
Write-Host ('[status]Installing module: PlatyPS')
Install-Module -Name:('PlatyPS') -Force
Write-Host ('[status]Creating/Updating help files')
$Functions_Public | ForEach-Object {
    $FunctionName = $_.BaseName
    $FilePath_Md = $Folder_Docs + '\' + $FunctionName + '.md'
    If (Test-Path -Path:($FilePath_Md))
    {
        Update-MarkdownHelp -Path:($FilePath_Md) -Force
    }
    Else
    {
        New-MarkdownHelp  -Command:($FunctionName) -OutputFolder:($Folder_Docs) -Force
    }
}
# Create new ExternalHelp file
Write-Host ('[status]Creating new external help file')
New-ExternalHelp -Path:($Folder_Docs) -OutputPath:($Folder_HelpFiles) -Force

# Get-Command -Module:('PlatyPS') | % { "Get-Help -Name:('$_')"}
### Unused ###
# Get-Help -Name:('Get-HelpPreview')
# Get-Help -Name:('Get-MarkdownMetadata')

# Get-Help -Name:('New-ExternalHelpCab')
# Get-Help -Name:('New-MarkdownAboutHelp')
# Get-Help -Name:('New-YamlHelp')
# Get-Help -Name:('Update-MarkdownHelpModule')

# Get-Help -Name:('Merge-MarkdownHelp')

### Used ###
# Get-Help -Name:('New-MarkdownHelp') -Examples
# Get-Help -Name:('Update-MarkdownHelp') -Examples
# Get-Help -Name:('New-ExternalHelp')