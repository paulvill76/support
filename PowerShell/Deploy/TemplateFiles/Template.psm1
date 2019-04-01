#Get public and private function definition files.
$Public = @(Get-ChildItem -Path:($PSScriptRoot + '\Public\*.ps1') -Recurse)
$Private = @(Get-ChildItem -Path:($PSScriptRoot + '\Private\*.ps1') -Recurse)
#Dot source the files
Foreach ($Import In @($Public + $Private))
{
    Try
    {
        . $Import.FullName
    }
    Catch
    {
        Write-Error -Message:("Failed to import function $($Import.FullName): $_")
    }
}
Export-ModuleMember -Function:($Public.Basename)