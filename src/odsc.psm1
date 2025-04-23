#Requires -Version 5.1
#Requires -Modules MSAL.PS
$Public = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\public\*.ps1") -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "\private\*.ps1") -ErrorAction SilentlyContinue)

$script:ODSToken = $null

foreach ($Import in @($Public + $Private)) {
    try {
        Write-Verbose "Importing file: $($Import.FullName)"
        . $Import.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_" -ErrorAction Stop
    }
}

foreach ($File in $Public) {
    Export-ModuleMember -Function $File.BaseName
}

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Write-Verbose "Clearing odsc authentication token"
    $script:ODSToken = $null
}
