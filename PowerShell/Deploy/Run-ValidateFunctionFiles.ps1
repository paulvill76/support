. ($PSScriptRoot + '\' + 'Get-Config.ps1')
Write-Host ('[status]Loaded config:' + $PSScriptRoot + $PathDeliminator + 'Get-Config.ps1')
###########################################################################
$Folder = ($Folder_Private, $Folder_Public)
# TODO Create function "Get-FunctionReport -Folder:()"
# Get a list of all functions in the current runspace
$CurrentFunctions = Get-ChildItem -Path:('function:')
# Load all function files from the module
$Files = (Get-ChildItem -Path:($Folder) -Recurse).Where( { $_.Extension -eq '.ps1' })
# Loop through each function file
$FunctionList = ForEach ($File In $Files)
{
    $FileFullName = $File.FullName
    $FileName = $File.Name
    $FileBaseName = $File.BaseName
    # Parse the file and look for function syntax to identify functions
    [regex]$Function_Regex = '(?<=^Function)(.*?)(?=$|\{|\()'
    $FunctionRegexMatch = Get-Content -Path:($FileFullName) | Select-String -Pattern:($Function_Regex) #| Where {-not [System.String]::IsNullOrEmpty($_)}
    $FunctionRegexMatchObject = $FunctionRegexMatch | Select-Object LineNumber, Line, @{Name = 'MatchValue'; Expression = { ($_.Matches.Value).Trim() } }
    # Load the function into the current runspace
    . ($FileFullName)
    # Regather a list of all functions in the current runspace and filter out the functions that existed before loading the function script
    $ScriptFunctions = Get-ChildItem -Path:('function:') | Where-Object { $CurrentFunctions -notcontains $_ }
    # $ScriptFunctions | Select *
    # Remove the function from the current runspace
    $ScriptFunctions | ForEach-Object { Remove-Item -Path:('function:\' + $_) }
    # $ScriptFunctions.Visibility
    $FolderLocation = If ($FileFullName -like '*Private*') { 'Private' }ElseIf ($FileFullName -like '*Public*') { 'Public' } Else { 'Unknown' }

    # Build dataset to perform validations against
    [PSCustomObject]@{
        # 'FullName'   = $FileFullName;
        'FileName'       = $FileName;
        'LineNumber'     = $FunctionRegexMatchObject.LineNumber
        'FileBaseName'   = $FileBaseName;
        'Function'       = $ScriptFunctions.Name
        'MatchValue'     = $FunctionRegexMatchObject.MatchValue
        'Line'           = $FunctionRegexMatchObject.Line
        'Verb'           = $ScriptFunctions.Verb
        'Noun'           = $ScriptFunctions.Noun
        'FolderLocation' = $FolderLocation
    }
}
# With in the Private and Public folders:
$Results = @()
# Validate that there is only 1 function per file
$Results += $FunctionList.Where( { ($_.Function).Count -gt 1 -or ($_.MatchValue).Count -gt 1 }) | Select-Object @{Name = 'Status'; Expression = { 'Multiple functions exist in the file' } } , *
# The file name matches the function name
$Results += $FunctionList.Where( { $_.FileBaseName -ne $_.Function -or $_.FileBaseName -ne $_.MatchValue }) | Select-Object @{Name = 'Status'; Expression = { 'File name does not match the function name' } } , *
# That all file names names and function names are unique and that there are no duplicates
$Results += $FunctionList | Where-Object { $_.FileBaseName -contains (($FunctionList.FileBaseName | Group-Object).Where( { $_.Count -gt 1 }).Name) } | Select-Object @{Name = 'Status'; Expression = { 'Duplicate functions found' } } , *
$Results += $FunctionList | Where-Object { $_.Function -contains (($FunctionList.Function | Group-Object).Where( { $_.Count -gt 1 }).Name) } | Select-Object @{Name = 'Status'; Expression = { 'Duplicate functions found' } } , *
$Results += $FunctionList | Where-Object { $_.MatchValue -contains (($FunctionList.MatchValue | Group-Object).Where( { $_.Count -gt 1 }).Name) } | Select-Object @{Name = 'Status'; Expression = { 'Duplicate functions found' } } , *
If ($Results)
{
    $Results | Select-Object Status, FolderLocation, FileName, LineNumber, FileBaseName, Function, MatchValue | Format-Table #, Line
    Write-Error ('Go fix the ValidateFunctionFiles results!')
}
Else
{
    Write-Host ('[success]ValidateFunctionFiles returned no results')
}
