#Requires -Version 5.1
<#
.SYNOPSIS
Smoke test of odsc (this working copy) against a real tenant.

.DESCRIPTION
Run it before a release. The user's OneDrive must not have a shortcut yet
to the library or folder used here (OneDrive allows one shortcut per target, and
none to a folder inside a library that already has one); a precheck stops the
run if it does.

-FolderPath is a folder INSIDE the SharePoint document library, relative to
the library root (for example "Projects/2026"), not a folder in OneDrive.

The script only touches that user's OneDrive:
  * it creates the folders "odsc-smoke-<stamp>-taken" and "odsc-smoke-<stamp>/..."
    at the root, and deletes them at the end if they are still plain folders
  * the shortcuts it creates are removed at the end (unless -KeepShortcuts)

-GroupId is only resolved (count of members), never assigned to.

Authenticate with -ClientSecret, -ClientCertificate, -CertificateThumbprint
(a certificate in Cert:\CurrentUser\My, Windows only) or -CertificatePath
(a .pfx file without password).

Each step prints PASS or FAIL. Send the summary back.
#>
[CmdletBinding(DefaultParameterSetName = 'Secret')]
param(
    [Parameter(Mandatory = $true)] [string] $TenantId,
    [Parameter(Mandatory = $true)] [string] $ClientId,
    [Parameter(Mandatory = $true, ParameterSetName = 'Secret')] [securestring] $ClientSecret,
    [Parameter(Mandatory = $true, ParameterSetName = 'Certificate')] [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate,
    [Parameter(Mandatory = $true, ParameterSetName = 'Thumbprint')] [string] $CertificateThumbprint,
    [Parameter(Mandatory = $true, ParameterSetName = 'CertificateFile')] [string] $CertificatePath,
    [ValidateSet('Global', 'GCC', 'GCCHigh', 'DoD', 'China')] [string] $Cloud = 'Global',
    [Parameter(Mandatory = $true)] [string] $SiteUrl,
    [Parameter(Mandatory = $true)] [string] $DocumentLibrary,
    [Parameter(Mandatory = $true)] [string] $FolderPath,
    [Parameter(Mandatory = $true)] [string] $UserPrincipalName,
    [string] $GroupId,
    [switch] $KeepShortcuts
)

$ErrorActionPreference = 'Continue'
if ($CertificateThumbprint) {
    $ClientCertificate = Get-Item -Path "Cert:\CurrentUser\My\$CertificateThumbprint" -ErrorAction Stop
}
if ($CertificatePath) {
    $ClientCertificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new((Resolve-Path -Path $CertificatePath -ErrorAction Stop).ProviderPath, '')
}

$Module = Import-Module (Join-Path $PSScriptRoot '../../src/odsc.psd1') -Force -PassThru
$Stamp = Get-Date -Format 'yyyyMMddHHmmss'
$Base = "odsc-smoke-$Stamp"
$Nested = "$Base/nested"
$AssignPath = "$Base/assign"
$Target1 = @{ Uri = $SiteUrl; DocumentLibrary = $DocumentLibrary }
$Target2 = @{ Uri = $SiteUrl; DocumentLibrary = $DocumentLibrary; FolderPath = $FolderPath }
$UserParameters = @{ UserPrincipalName = $UserPrincipalName }
$script:Results = [System.Collections.Generic.List[object]]::new()
# Shortcuts to remove at the end, as @{ Path; Name } ('' = root).
$script:Created = [System.Collections.Generic.List[object]]::new()

function Invoke-SmokeStep {
    param(
        [string] $Name,
        [ValidateSet('Success', 'Error')] [string] $Expect,
        [scriptblock] $Action,
        [scriptblock] $Check
    )

    $Output = $null
    $ErrorMessage = $null
    try {
        $Output = & $Action
    } catch {
        $ErrorMessage = $_.Exception.Message
    }

    $Detail = if ($ErrorMessage) { "ERROR: $ErrorMessage" } else { ($Output | Out-String).Trim() }
    $Passed = if ($Expect -eq 'Error') {
        [bool]$ErrorMessage -and (-not $Check -or (& $Check $ErrorMessage))
    } else {
        -not $ErrorMessage -and (-not $Check -or (& $Check $Output))
    }
    $Outcome = if ($Passed) { 'PASS' } else { 'FAIL' }

    $script:Results.Add([pscustomobject]@{ Step = $Name; Outcome = $Outcome; Detail = $Detail }) | Out-Null
    Write-Host ("[{0}] {1}" -f $Outcome, $Name) -ForegroundColor $(if ($Passed) { 'Green' } else { 'Red' })
    if ($Detail) { Write-Host ($Detail -replace '(?m)^', '       ') }
    return $Output
}

# Creates and removes a shortcut to a target: works only if the user has no shortcut to it (or to its library).
function Test-SmokeTargetFree {
    param([hashtable] $Target)
    $Shortcut = New-odsc @Target -ShortcutName "$Base-probe" @UserParameters -ErrorAction Stop
    Remove-odsc -ShortcutName $Shortcut.name @UserParameters -Confirm:$false -ErrorAction Stop | Out-Null
    'no existing shortcut to the target'
}

function Add-SmokeCreated {
    param([string] $Path, [string] $Name)
    $script:Created.Add([pscustomobject]@{ Path = $Path; Name = $Name }) | Out-Null
}

Write-Host "odsc smoke test, prefix '$Base'" -ForegroundColor Yellow

# --- Connection and permissions ---------------------------------------------------------
Invoke-SmokeStep 'Connect-odsc' Success {
    $Connect = @{ TenantId = $TenantId; ClientId = $ClientId; Cloud = $Cloud }
    if ($ClientCertificate) { $Connect.ClientCertificate = $ClientCertificate } else { $Connect.ClientSecret = $ClientSecret }
    Connect-odsc @Connect
} | Out-Null

$PermissionParameters = @{ Uri = $SiteUrl; DocumentLibrary = $DocumentLibrary; FolderPath = $FolderPath; UserPrincipalName = $UserPrincipalName }
if ($GroupId) { $PermissionParameters.GroupId = $GroupId }
Invoke-SmokeStep 'Test-odscPermission: all checks pass' Success { Test-odscPermission @PermissionParameters | Format-Table -AutoSize | Out-String -Width 200 } {
    param($Out) $Out -notmatch 'Failed'
} | Out-Null

Invoke-SmokeStep 'Get-odscDrive returns the drive' Success { Get-odscDrive @UserParameters -ErrorAction Stop | Select-Object id, driveType } { param($Out) $Out.id } | Out-Null

# --- Precheck -----------------------------------------------------------------------------
foreach ($Item in @(@{ Label = 'library'; Target = $Target1 }, @{ Label = "folder '$FolderPath'"; Target = $Target2 })) {
    $Parameters = $Item.Target
    $Free = Invoke-SmokeStep "Precheck: no existing shortcut to the $($Item.Label)" Success { Test-SmokeTargetFree -Target $Parameters }
    if (-not $Free) {
        Write-Host ''
        Write-Host "Stopping: pick a user without a shortcut to the $($Item.Label), or another target. If the folder was not found, -FolderPath must be a folder inside the library." -ForegroundColor Red
        Disconnect-odsc
        exit 1
    }
}

# --- Name already used by a real folder ---------------------------------------------------
Invoke-SmokeStep "Setup: plain folder '$Base-taken'" Success {
    & $Module { param($User, $Path) Resolve-odscDriveFolderPath -User $User -RelativePath $Path -Create | Select-Object id, name } $UserPrincipalName "$Base-taken"
} | Out-Null

$script:KeptName = $null
Invoke-SmokeStep 'New-odsc with a name used by a folder: error naming the kept shortcut' Error {
    New-odsc @Target1 -ShortcutName "$Base-taken" @UserParameters -ErrorAction Stop
} {
    param($Message)
    if ($Message -match "created as '(.+?)' in the root") { $script:KeptName = $Matches[1] }
    [bool]$script:KeptName
} | Out-Null

if ($script:KeptName) {
    Add-SmokeCreated -Path '' -Name $script:KeptName
    Invoke-SmokeStep "The kept shortcut '$($script:KeptName)' exists" Success {
        Get-odsc -ShortcutName $script:KeptName @UserParameters -ErrorAction Stop | Select-Object name, id
    } { param($Out) $Out.id } | Out-Null
    Invoke-SmokeStep 'Remove the kept shortcut' Success {
        Remove-odsc -ShortcutName $script:KeptName @UserParameters -PassThru -Confirm:$false -ErrorAction Stop | Select-Object ShortcutName, Status
    } { param($Out) $Out.Status -eq 'Removed' } | Out-Null
}
Invoke-SmokeStep 'Library has no shortcut left afterwards' Success { Test-SmokeTargetFree -Target $Target1 } | Out-Null

# --- New-odsc and Get-odsc at the root, and duplicates ---------------------------------------
Invoke-SmokeStep 'New-odsc library shortcut at the root' Success {
    New-odsc @Target1 -ShortcutName "$Base-lib" @UserParameters -ErrorAction Stop | Select-Object name, id
} { param($Out) $Out.name -eq "$Base-lib" } | Out-Null
Add-SmokeCreated -Path '' -Name "$Base-lib"

Invoke-SmokeStep 'Get-odsc finds it' Success { Get-odsc -ShortcutName "$Base-lib" @UserParameters -ErrorAction Stop | Select-Object name, id } { param($Out) $Out.id } | Out-Null

Invoke-SmokeStep 'New-odsc same target, same name: already-has-a-shortcut error' Error {
    New-odsc @Target1 -ShortcutName "$Base-lib" @UserParameters -ErrorAction Stop
} { param($Message) $Message -like '*already has a shortcut to this target*' } | Out-Null

Invoke-SmokeStep 'New-odsc same target, other name: already-has-a-shortcut error' Error {
    New-odsc @Target1 -ShortcutName "$Base-lib-second" @UserParameters -ErrorAction Stop
} { param($Message) $Message -like '*already has a shortcut to this target*' } | Out-Null

Invoke-SmokeStep 'No second shortcut was created' Error {
    Get-odsc -ShortcutName "$Base-lib-second" @UserParameters -ErrorAction Stop
} | Out-Null

# --- FolderPath + nested RelativePath -------------------------------------------------------
Invoke-SmokeStep "New-odsc folder shortcut: blocked while the library has a shortcut" Error {
    New-odsc @Target2 -RelativePath $Nested -ShortcutName "$Base-folder" @UserParameters -ErrorAction Stop
} { param($Message) $Message -like '*already has a shortcut to this target*' } | Out-Null

Invoke-SmokeStep 'Remove-odsc the library shortcut' Success {
    Remove-odsc -ShortcutName "$Base-lib" @UserParameters -PassThru -Confirm:$false -ErrorAction Stop | Select-Object ShortcutName, Status
} { param($Out) $Out.Status -eq 'Removed' } | Out-Null

Invoke-SmokeStep "New-odsc folder shortcut in '$Nested' (creates the folders)" Success {
    New-odsc @Target2 -RelativePath $Nested -ShortcutName "$Base-folder" @UserParameters -ErrorAction Stop | Select-Object name, id
} { param($Out) $Out.name -eq "$Base-folder" } | Out-Null
Add-SmokeCreated -Path $Nested -Name "$Base-folder"

Invoke-SmokeStep 'Get-odsc with -RelativePath finds it' Success {
    Get-odsc -RelativePath $Nested -ShortcutName "$Base-folder" @UserParameters -ErrorAction Stop | Select-Object name, id
} { param($Out) $Out.id } | Out-Null

Invoke-SmokeStep 'Remove-odsc -PassThru removes it' Success {
    Remove-odsc -RelativePath $Nested -ShortcutName "$Base-folder" @UserParameters -PassThru -Confirm:$false -ErrorAction Stop | Select-Object Status, DriveItemId
} { param($Out) $Out.Status -eq 'Removed' } | Out-Null

Invoke-SmokeStep 'Remove-odsc of a missing shortcut writes an error' Error {
    Remove-odsc -RelativePath $Nested -ShortcutName "$Base-folder" @UserParameters -Confirm:$false -ErrorAction Stop
} | Out-Null

# --- Set-odscShortcutState ------------------------------------------------------------------
$SetCommon = @{ Confirm = $false; ErrorAction = 'Stop' } + $UserParameters

Invoke-SmokeStep 'Set-odscShortcutState creates the library shortcut' Success {
    Set-odscShortcutState @Target1 -ShortcutName "$Base-lib" @SetCommon | Select-Object Status, ShortcutName
} { param($Out) $Out.Status -eq 'Created' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState again: Compliant' Success {
    Set-odscShortcutState @Target1 -ShortcutName "$Base-lib" @SetCommon | Select-Object Status, Message
} { param($Out) $Out.Status -eq 'Compliant' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState other target, same name: SkippedConflict' Success {
    Set-odscShortcutState @Target2 -ShortcutName "$Base-lib" @SetCommon | Select-Object Status, Message
} { param($Out) $Out.Status -eq 'SkippedConflict' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState -ConflictAction Error: error' Error {
    Set-odscShortcutState @Target2 -ShortcutName "$Base-lib" -ConflictAction Error @SetCommon
} { param($Message) $Message -like '*already exists*' } | Out-Null

Invoke-SmokeStep "Set-odscShortcutState -ConflictAction Replace on the real folder '$Base-taken': refused" Error {
    Set-odscShortcutState @Target2 -ShortcutName "$Base-taken" -ConflictAction Replace @SetCommon
} { param($Message) $Message -like '*is not a OneDrive shortcut*' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState -ConflictAction Replace: library shortcut replaced by folder shortcut' Success {
    Set-odscShortcutState @Target2 -ShortcutName "$Base-lib" -ConflictAction Replace @SetCommon | Select-Object Status, ShortcutName
} { param($Out) $Out.Status -eq 'Created' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState -State Absent for the library: not removed (points to the folder now)' Success {
    Set-odscShortcutState @Target1 -ShortcutName "$Base-lib" -State Absent @SetCommon | Select-Object Status, Message
} { param($Out) $Out.Status -eq 'SkippedConflict' } | Out-Null

Invoke-SmokeStep 'Set-odscShortcutState -State Absent for the folder: removed' Success {
    Set-odscShortcutState @Target2 -ShortcutName "$Base-lib" -State Absent @SetCommon | Select-Object Status
} { param($Out) $Out.Status -eq 'Removed' } | Out-Null

$script:RenamedName = $null
Invoke-SmokeStep "Set-odscShortcutState -ConflictAction Rename with the name of the real folder: timestamped name" Success {
    $Result = Set-odscShortcutState @Target1 -ShortcutName "$Base-taken" -ConflictAction Rename @SetCommon
    $script:RenamedName = $Result.ShortcutName
    if ($Result.ShortcutName) { Add-SmokeCreated -Path '' -Name $Result.ShortcutName }
    $Result | Select-Object Status, ShortcutName
} { param($Out) $Out.Status -eq 'Created' -and $Out.ShortcutName -like "$Base-taken-*" } | Out-Null

# --- Assignment (the given user only) ---------------------------------------------------------
if ($script:RenamedName) {
    Invoke-SmokeStep 'Remove the renamed library shortcut (frees the folder for the assignment)' Success {
        Remove-odsc -ShortcutName $script:RenamedName @UserParameters -PassThru -Confirm:$false -ErrorAction Stop | Select-Object ShortcutName, Status
    } { param($Out) $Out.Status -eq 'Removed' } | Out-Null
}

$Report = Join-Path ([System.IO.Path]::GetTempPath()) "$Base-report.csv"
$AssignUser = [pscustomobject]@{ UserPrincipalName = $UserPrincipalName }
Invoke-SmokeStep "Invoke-odscShortcutAssignment into '$AssignPath'" Success {
    Invoke-odscShortcutAssignment -User $AssignUser @Target2 -RelativePath $AssignPath -ShortcutName "$Base-assign" -ReportPath $Report -Confirm:$false |
        Select-Object User, Status, Message
} { param($Out) $Out.Status -eq 'Created' } | Out-Null
Add-SmokeCreated -Path $AssignPath -Name "$Base-assign"

Invoke-SmokeStep 'Invoke-odscShortcutAssignment again: Compliant, report written' Success {
    Invoke-odscShortcutAssignment -User $AssignUser @Target2 -RelativePath $AssignPath -ShortcutName "$Base-assign" -ReportPath $Report -Confirm:$false |
        Select-Object User, Status
} { param($Out) $Out.Status -eq 'Compliant' -and @(Import-Csv $Report).Count -eq 1 } | Out-Null

if ($GroupId) {
    Invoke-SmokeStep 'Get-odscTargetUser -GroupId (count only, nothing assigned)' Success {
        $Enabled = @(Get-odscTargetUser -GroupId $GroupId -ErrorAction Stop)
        $All = @(Get-odscTargetUser -GroupId $GroupId -IncludeDisabled -ErrorAction Stop)
        "enabled members: $($Enabled.Count), including disabled: $($All.Count)"
    } | Out-Null
}

# --- Cleanup ------------------------------------------------------------------------------------
if (-not $KeepShortcuts) {
    Invoke-SmokeStep 'Cleanup: shortcuts removed' Success {
        foreach ($Item in $script:Created) {
            $Shortcut = Get-odsc -RelativePath $Item.Path -ShortcutName $Item.Name @UserParameters -ErrorAction SilentlyContinue
            if ($Shortcut.remoteItem) {
                Remove-odsc -RelativePath $Item.Path -ShortcutName $Item.Name @UserParameters -Confirm:$false -ErrorAction Stop | Out-Null
                "removed '$($Item.Name)' from '/$($Item.Path)'"
            }
        }
        'done'
    } | Out-Null

    Invoke-SmokeStep 'Cleanup: test folders deleted' Success {
        foreach ($Folder in "$Base-taken", $Base) {
            $Item = & $Module { param($User, $Path) Invoke-odscApiRequest -Resource (Join-odscDrivePathResource -User $User -RelativePath $Path) -Method Get -ErrorAction SilentlyContinue } $UserPrincipalName $Folder
            if ($Item.folder -and -not $Item.remoteItem) {
                & $Module { param($User, $Id) Invoke-odscApiRequest -Resource "users/$User/drive/items/$Id" -Method Delete -ErrorAction Stop } $UserPrincipalName $Item.id | Out-Null
                "deleted '/$Folder'"
            }
        }
        'done'
    } | Out-Null
}

Disconnect-odsc

Write-Host ''
$script:Results | Select-Object Step, Outcome | Format-Table -AutoSize
$Failed = @($script:Results | Where-Object Outcome -eq 'FAIL').Count
Write-Host "$($script:Results.Count - $Failed) passed, $Failed failed" -ForegroundColor $(if ($Failed) { 'Red' } else { 'Green' })
$Summary = Join-Path ([System.IO.Path]::GetTempPath()) "$Base-summary.txt"
$script:Results | Format-List | Out-String -Width 200 | Set-Content -Path $Summary
Write-Host "Full details: $Summary"
