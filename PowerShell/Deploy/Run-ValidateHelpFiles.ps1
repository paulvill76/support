# Load config
. ($PSScriptRoot + '\' + 'Get-Config.ps1')
# Validate that help files have been populated
Write-Host ('[status]Validating help file fields have been populated')
$HelpFilePopulation = Get-ChildItem -Path:($Folder_Docs) | Select-String -Pattern:('(\{\{)(.*?)(\}\})')
If ($HelpFilePopulation)
{
    $HelpFilePopulation
    Write-Error ('Go populate the help files!')
}