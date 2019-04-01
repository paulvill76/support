Try
{
    # Load config
    . ($PSScriptRoot + '\' + 'Get-Config.ps1')
    # Get next module version number

    $PSGalleryInfo = Get-PSGalleryModuleVersion -Name:($ModuleName) -ReleaseType:('Major') #('Major', 'Minor', 'Patch')
    $ModuleVersion = $PSGalleryInfo.NextVersion
    Write-Host ('Name:' + $PSGalleryInfo.Name + ';CurrentVersion:' + $PSGalleryInfo.Version + '; NextVersion:' + $ModuleVersion )
    ###########################################################################
    # # Get predefined folder structure for module and create the structure
    # $ModuleFolders = (Get-ChildItem -Path:($Folder_ModuleTemplate) -Recurse -Directory).Where( { $_.FullName -match $ModuleFolderName })
    # ForEach ($ModuleFolder In $ModuleFolders)
    # {
    #     New-FolderRecursive -Path:(($ModuleFolder.FullName).Replace($Folder_ModuleTemplate, $Folder_ModuleRootPath))
    # }
    # If the module path already exists then rename it
    If (Test-Path -Path:($Folder_Module)) { Rename-Item -Path:($Folder_Module) -NewName:($ModuleFolderNameOld) }
    # Create required directories
    New-Item -ItemType:('Directory') -Path:($Folder_Module) | Out-Null
    New-Item -ItemType:('Directory') -Path:($Folder_Private) | Out-Null
    New-Item -ItemType:('Directory') -Path:($Folder_Public) | Out-Null
    New-Item -ItemType:('Directory') -Path:($Folder_HelpFiles) | Out-Null
    New-Item -ItemType:('Directory') -Path:($Folder_Tests) | Out-Null
    New-Item -ItemType:('Directory') -Path:($Folder_Docs) | Out-Null
    # Copy the public/exported functions into the public folder, private functions into private folder
    Copy-Item -Path:($File_License.Replace($Folder_Module, $Folder_Module_Old)) -Destination:($File_License) -Force
    Copy-Item -Path:($Folder_Docs.Replace($Folder_Module, $Folder_Module_Old) + $PathDeliminator + '*') -Destination:($Folder_Docs) -Recurse -Force
    Copy-Item -Path:($Folder_Tests.Replace($Folder_Module, $Folder_Module_Old) + $PathDeliminator + '*') -Destination:($Folder_Tests) -Recurse -Force
    Copy-Item -Path:($Folder_Private.Replace($Folder_Module, $Folder_Module_Old) + $PathDeliminator + '*') -Destination:($Folder_Private) -Recurse -Force
    Copy-Item -Path:($Folder_Public.Replace($Folder_Module, $Folder_Module_Old) + $PathDeliminator + '*') -Destination:($Folder_Public) -Recurse -Force
    # Create required files
    $File_TestsPs1 = ($File_TestsPs1_Template -f $Folder_Tests, $ModuleName, $ModuleVersion)
    $FileObject_TestsPs1 = If (!(Test-Path -Path:($File_TestsPs1))) { New-Item -ItemType:('File') -Path:($File_TestsPs1) }
    ###########################################################################
    # Copy over module template files
    $TemplateFiles = Get-ChildItem -Path:($Folder_TemplateFiles) -Recurse -File -Exclude:('Temp.txt')
    ForEach ($TemplateFile In $TemplateFiles)
    {
        $TemplateFileFullName = $TemplateFile.FullName
        $DestinationFileFullName = ($TemplateFile.FullName).Replace('Template.', $ModuleName + '.').Replace($Folder_TemplateFiles, $Folder_Module)
        Copy-Item -Path:($TemplateFileFullName) -Destination:($DestinationFileFullName)
    }
    ###########################################################################
    # Create ModuleManifest
    Write-Host('Building New-JCModuleManifest')
    New-JCModuleManifest -SourcePath:($File_Psd1.Replace($Folder_Module, $Folder_Module_Old)) `
        -Path:($File_Psd1) `
        -FunctionsToExport:($Functions_Public.BaseName | Sort-Object) `
        -RootModule:((Get-Item -Path:($File_Psm1)).Name) `
        -FormatsToProcess:((Get-Item -Path:($File_Ps1Xml)).Name)
}
Catch
{
    $Exception = $_.Exception
    $Message = $Exception.Message
    While ($Exception.InnerException)
    {
        $Exception = $Exception.InnerException
        $Message += "|" + $Exception.Message
    }
    $FullErrorMessage = ($Message + "|" + $_.FullyQualifiedErrorId.ToString() + "|" + $_.InvocationInfo.PositionMessage).Replace("`r", ' ').Replace("`n", ' ')
    Write-Error ($FullErrorMessage)
}
Finally
{
    # If the renamed module path exists then remove it
    If (Test-Path -Path:($Folder_Module_Old)) { Remove-Item -Path:($Folder_Module_Old) -Recurse -Force }
}