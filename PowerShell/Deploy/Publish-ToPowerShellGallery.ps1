. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
Write-Host ('[status]Publishing to PowerShell Gallery:' + $Folder_Module)
Publish-Module -Path:($Folder_Module) -NuGetApiKey:($NuGetApiKey)

## TODO Possibly validate that its been published correctly?
# # The module is now listed on the PowerShell Gallery
# Find-Module $ModuleName
# # Uninstall and remove the module if installed or imported
# If (Get-InstalledModule -Name:($ModuleName)) { Uninstall-Module -Name:($ModuleName) -Force }
# If (Get-Module -Name:($ModuleName)) { Remove-Module -Name:($ModuleName) -Force }
# # Install the module
# Install-Module -Name:($ModuleName) -Force
# Get-InstalledModule -Name:($ModuleName)
# # Import the module
# Import-Module -Name:($ModuleName) -Force
# Get-Module -Name:($ModuleName)
# # Get commands in the module
# Get-Command -Module:($ModuleName)
# Get module help
# Get-Help ($FileObject_HelpTxt.BaseName).Replace('.help', '')
#EndRegion - Publish module to PowerShell Gallery and then download and test
