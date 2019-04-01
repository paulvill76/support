Function Invoke-GitCommit
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$BranchName
    )
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack).Where( {$_.Command -notin ($MyName, $MyName.Replace('.ps1', ''))}).Command -join ','
    $CommitMessage = 'Push to ' + $BranchName + '; Called by:' + $ParentScriptName + ';'
    $UserEmail = 'AzurePipelines@FakeEmail.com'
    $UserName = 'AzurePipelines'
    Write-Host ('[status]Git version')
    git --version
    Write-Host ('[status]Set git user email to: ' + $UserEmail)
    git config user.email $UserEmail
    Write-Host ('[status]Set git user name to: ' + $UserName)
    git config user.name $UserName
    Write-Host ('[status]Check git status')
    git status
    Write-Host ('[status]Git add all uncommitted changes')
    git add -A
    Write-Host ('[status]Git commit all changes with message: ' + $CommitMessage)
    git commit -a -m $CommitMessage
    Write-Host ('[status]Git push to: ' + $BranchName)
    git push --force origin HEAD:refs/heads/$BranchName
}