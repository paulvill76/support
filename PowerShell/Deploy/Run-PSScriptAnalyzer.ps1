. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Installing module: PSScriptAnalyzer')
Install-Module -Name:('PSScriptAnalyzer') -Force
Write-Host ('[status]Running PSScriptAnalyzer on: ' + $Folder_Module)
$ScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path:($Folder_Module)
If ($ScriptAnalyzerResults)
{
    $ScriptAnalyzerResults
    Write-Error ('Go fix the ScriptAnalyzer results!')
}
Else
{
    Write-Host ('[success]ScriptAnalyzer returned no results')
}