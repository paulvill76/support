. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Validating help file fields have been populated')
$HelpFilePopulation = Get-ChildItem -Path:($Folder_Docs) | Select-String -Pattern:('(\{\{)(.*?)(\}\})')
If ($HelpFilePopulation)
{
    $HelpFilePopulation
    Write-Error ('Go populate the help files!')
}
Else
{
    Write-Host ('[success]HelpFilePopulation returned no results')
}
