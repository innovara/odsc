function Invoke-odscPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    try {
        $ResolvedPath = (Resolve-Path -Path $Path -ErrorAction Stop).ProviderPath
        $PlanDirectory = Split-Path -Path $ResolvedPath -Parent

        $Extension = [System.IO.Path]::GetExtension($ResolvedPath).ToLowerInvariant()
        $Config = switch ($Extension) {
            '.json' { Get-Content -Path $ResolvedPath -Raw | ConvertFrom-Json }
            '.psd1' { Import-PowerShellDataFile -Path $ResolvedPath }
            default { Write-Error 'Supported plan formats are .json and .psd1.' -ErrorAction Stop }
        }
    } catch {
        Write-Error "Unable to read plan '$Path'. $($_.Exception.Message)"
        return
    }

    $Shortcuts = if ($Config.shortcuts) { $Config.shortcuts } else { $Config.Shortcuts }
    foreach ($Shortcut in $Shortcuts) {
        $Target = $Shortcut.target

        # A relative csvPath is relative to the plan file, not to the current directory.
        if ($Target -and $Target.csvPath -and -not [System.IO.Path]::IsPathRooted($Target.csvPath)) {
            $CsvPath = Join-Path -Path $PlanDirectory -ChildPath $Target.csvPath
            if ($Target -is [hashtable]) {
                $Target = $Target.Clone()
                $Target.csvPath = $CsvPath
            } else {
                $Target = $Target | Select-Object -Property *
                $Target.csvPath = $CsvPath
            }
        }

        [pscustomobject]@{
            Name = $Shortcut.name
            Uri = $Shortcut.siteUrl
            DocumentLibrary = $Shortcut.library
            DocumentLibraryId = $Shortcut.libraryId
            FolderPath = $Shortcut.folderPath
            RelativePath = $Shortcut.oneDrivePath
            State = if ($Shortcut.state) { $Shortcut.state } else { 'Present' }
            ConflictAction = if ($Shortcut.conflictAction) { $Shortcut.conflictAction } else { 'Skip' }
            Target = $Target
        }
    }
}
