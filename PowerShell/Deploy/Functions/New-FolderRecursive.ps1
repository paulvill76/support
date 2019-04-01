
#Function to create a folder and any child folders
Function New-FolderRecursive
{
    [cmdletbinding(SupportsShouldProcess = $True)]
    Param(
        [string]$Path
        , [switch]$Force
    )
    $PathPart = @()
    $WindowsDeliminator = '\'
    $UnixDeliminator = '/'
    $PathDeliminator = Switch ([environment]::OSVersion.Platform) {'Win32NT' {$WindowsDeliminator}'Unix' {$UnixDeliminator}}
    # Determine if the last part of the path contains a file extension
    If ( (Split-Path -Path:($Path) -Leaf) -match '\.[a-zA-Z0-9]+$')
    {
        $Path = Split-Path -Path:($Path) -Parent
    }
    # Split path into each folder
    $SplitFullPath = ($Path -split ('(\' + $WindowsDeliminator + '|\' + $UnixDeliminator + ')'))
    ForEach ( $Directory In $SplitFullPath | Where-Object {$_ -and $_ -notin ($WindowsDeliminator, $UnixDeliminator)} )
    {
        $PathPart += $Directory
        $NewPath = $PathPart -join $PathDeliminator
        If ( !( Test-Path -Path:($NewPath) ))
        {
            If ($Force)
            {
                New-Item -ItemType:('directory') -Path:($NewPath) -Force
            }
            Else
            {
                New-Item -ItemType:('directory') -Path:($NewPath)
            }
        }
    }
}