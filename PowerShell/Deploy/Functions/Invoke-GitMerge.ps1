Function Invoke-GitMerge
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$SourceBranch,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][string]$TargetBranch
    )
    # Install BuildHelpers module and import commands used
    If (!(Get-Module -Name:('BuildHelpers') -ListAvailable)) { Install-Module -Name:('BuildHelpers') -Force }
    If (Get-Module -Name:('BuildHelpers') -ListAvailable) { Import-Module -Name:('BuildHelpers') -Function:('Invoke-Git') }
    # Logging
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack).Where( { $_.Command -notin ($MyName, $MyName.Replace('.ps1', '')) }).Command -join ','
    $CommitMessage = 'Merge ' + $SourceBranch + ' into ' + $TargetBranch + '; Called by:' + $ParentScriptName + ';'
    Write-Host ('[status]SOURCE BRANCH:' + $SourceBranch + ';TARGET BRANCH:' + $TargetBranch + ';')
    If ($SourceBranch -eq 'refs/heads/' + $TargetBranch )
    {
        Write-Host ('[status]Building ' + $TargetBranch + ' branch so no merge is needed.')
    }
    Else
    {
        Invoke-Git -Arguments:('fetch origin')
        Invoke-Git -Arguments:('checkout ' + $SourceBranch)
        Invoke-Git -Arguments:('checkout ' + $TargetBranch)
        Invoke-Git -Arguments:('status')
        Invoke-Git -Arguments:('merge ' + $SourceBranch + ' -m ' + $CommitMessage)
        Invoke-Git -Arguments:('status')
        Invoke-Git -Arguments:('push origin')
        Invoke-Git -Arguments:('status')
    }
}