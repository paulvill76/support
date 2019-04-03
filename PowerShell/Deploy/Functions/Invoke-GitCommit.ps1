Function Invoke-GitCommit
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$BranchName
    )
    # Install BuildHelpers module and import commands used
    If (!(Get-Module -Name:('BuildHelpers') -ListAvailable)) { Install-Module -Name:('BuildHelpers') -Force }
    If (Get-Module -Name:('BuildHelpers') -ListAvailable) { Import-Module -Name:('BuildHelpers') -Function:('Invoke-Git') }
    # Logging
    $MyName = $MyInvocation.MyCommand.Name
    $ParentScriptName = (Get-PSCallStack).Where( {$_.Command -notin ($MyName, $MyName.Replace('.ps1', ''))}).Command -join ','
    $CommitMessage = 'Push to ' + $BranchName + '; Called by:' + $ParentScriptName + ';'
    $UserEmail = 'AzurePipelines@FakeEmail.com'
    $UserName = 'AzurePipelines'
    Invoke-Git -Arguments:('--version')
    Invoke-Git -Arguments:('config user.email ' + $UserEmail)
    Invoke-Git -Arguments:('config user.name ' + $UserName)
    Invoke-Git -Arguments:('status')
    Invoke-Git -Arguments:('add -A')
    Invoke-Git -Arguments:('commit -a -m ' + $CommitMessage)
    Invoke-Git -Arguments:('push --force origin HEAD:refs/heads/' + $BranchName)
}