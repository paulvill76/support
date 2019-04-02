# Load config
. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Commit changes to:' + $GitSourceBranch + ';')
Invoke-GitCommit -BranchName:($GitSourceBranch)
Write-Host ('[status]Merge ' + $GitSourceBranch + ' to ' + $GitTargetBranch)
Invoke-GitMerge -SourceBranch:($GitSourceBranch) -TargetBranch:($GitTargetBranch)
