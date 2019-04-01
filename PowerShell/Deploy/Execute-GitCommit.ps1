# Load config
. ($env:deployFolder + '\Get-Config.ps1')
Write-Host ('[status]Commit changes to:' + $GitSourceBranch + ';')
Invoke-GitCommit -BranchName:($GitSourceBranch)