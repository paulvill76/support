. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Running pester tests in: ' + $Folder_Tests)
$PesterResults = Invoke-Pester -Script @{ Path = $Folder_Tests; Parameters = @{ JCAPIKEY = $JCAPIKEY; SingleAdminAPIKey = $SingleAdminAPIKey; }; } -PassThru
If ($PesterResults.FailedCount -gt 0)
{
    $PesterResults
    Write-Error "Failed [$($PesterResults.FailedCount)] Pester tests"
}
Else
{
    Write-Host ('[success]Pester tests returned no failures')
}
