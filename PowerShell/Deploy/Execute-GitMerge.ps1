# Load config
. ($env:deployFolder + '\Get-Config.ps1')

Write-Host ('Commit changes to:' + $GitSourceBranch + ';')
Invoke-GitCommit -BranchName:($GitSourceBranch)

Write-Host ('Merge ' + $GitSourceBranch + ' to ' + $GitTargetBranch)
Invoke-GitMerge -SourceBranch:($GitSourceBranch) -TargetBranch:($GitTargetBranch)