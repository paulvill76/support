# Load config
. ($PSScriptRoot + '\' + 'Get-Config.ps1')
# Run Pester tests to make sure its not failing any tests
$PesterResults = Invoke-Pester -Script @{ Path = $Folder_Tests; Parameters = @{ JCAPIKEY = $JCAPIKEY; SingleAdminAPIKey = $SingleAdminAPIKey; }; } -PassThru
If ($PesterResults.FailedCount -gt 0)
{
    $PesterResults
    Write-Error "Failed [$($PesterResults.FailedCount)] Pester tests"
}