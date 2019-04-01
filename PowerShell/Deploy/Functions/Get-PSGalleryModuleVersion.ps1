Function Get-PSGalleryModuleVersion
{
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('Major', 'Minor', 'Patch')][string]$ReleaseType
    )
    # Check to see if module already exists to set version number
    $PowerShellGalleryModule = Find-Module -Name:($Name) -ErrorAction:('Ignore')
    If ([string]::IsNullOrEmpty($PowerShellGalleryModule))
    {
        $NextVersion = Switch ($ReleaseType)
        {
            'Major' { '1.0.0' }
            'Minor' { '0.1.0' }
            'Patch' { '0.0.1' }
        }
    }
    Else
    {
        $CurrentModuleVersion = [PSCustomObject]@{
            'Name'    = $PowerShellGalleryModule.Name;
            'Version' = $PowerShellGalleryModule.Version;
            'Major'   = [int]($PowerShellGalleryModule.Version -split '\.')[0];
            'Minor'   = [int]($PowerShellGalleryModule.Version -split '\.')[1];
            'Patch'   = [int]($PowerShellGalleryModule.Version -split '\.')[2];
        }
        Switch ($ReleaseType)
        {
            'Major' { $CurrentModuleVersion.Major = $CurrentModuleVersion.Major + 1 }
            'Minor' { $CurrentModuleVersion.Minor = $CurrentModuleVersion.Minor + 1 }
            'Patch' { $CurrentModuleVersion.Patch = $CurrentModuleVersion.Patch + 1 }
        }
        $NextVersion = ($CurrentModuleVersion.Major, $CurrentModuleVersion.Minor, $CurrentModuleVersion.Patch) -join '.'
        # Add-Member -InputObject:($CurrentModuleVersion) -MemberType:('NoteProperty') -Name:('NextVersion') -Value:($NextVersion)

    }
    Return $NextVersion
}