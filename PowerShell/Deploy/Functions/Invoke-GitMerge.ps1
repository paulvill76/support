Function Invoke-GitMerge
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$SourceBranch,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$TargetBranch
    )
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack).Where( {$_.Command -notin ($MyName, $MyName.Replace('.ps1', ''))}).Command -join ','
    $CommitMessage = 'Merge ' + $SourceBranch + ' into ' + $TargetBranch + '; Called by:' + $ParentScriptName + ';'
    Write-Host ('[status]SOURCE BRANCH:' + $SourceBranch + ';TARGET BRANCH:' + $TargetBranch + ';')
    If ($SourceBranch -eq 'refs/heads/' + $TargetBranch )
    {
        Write-Host ('[status]Building ' + $TargetBranch + ' branch so no merge is needed.')
    }
    Else
    {
        Write-Host ('[status]GIT FETCH ORIGIN')
        git fetch origin
        Write-Host ('[status]GIT CHECKOUT ' + $SourceBranch)
        git checkout $SourceBranch
        Write-Host ('[status]GIT CHECKOUT ' + $TargetBranch)
        git checkout $TargetBranch
        Write-Host ('[status]GIT STATUS')
        git status
        Write-Host ('[status]GIT MERGE ' + $SourceBranch + ' -m ' + $CommitMessage)
        git merge $SourceBranch -m $CommitMessage
        Write-Host ('[status]GIT STATUS')
        git status
        Write-Host ('[status]GIT PUSH ORIGIN')
        git push origin
        Write-Host ('[status]GIT STATUS')
        git status
    }
}