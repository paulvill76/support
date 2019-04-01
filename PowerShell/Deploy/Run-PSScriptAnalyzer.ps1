# Load config
. ($PSScriptRoot + '\' + 'Get-Config.ps1')
# Install PSScriptAnalyzer
Install-Module -Name:('PSScriptAnalyzer') -Force
# Run PSScriptAnalyzer to make sure its not failing any tests
$ScriptAnalyzerResults = Invoke-ScriptAnalyzer -Path:($Folder_Module)
If ($ScriptAnalyzerResults)
{
    $ScriptAnalyzerResults
    Write-Error ('Go fix the ScriptAnalyzer results!')
}