# USAGE

#### Table of Contents
*   [Module Documentation](#module-documentation)
*   [Prerequisites](#prerequisites)
*   [Examples](#examples)
*   [Organization-scale examples](#organization-scale-examples)
*   [Plan files](#plan-files)
*   [Error handling](#error-handling)

----------

## Module Documentation

Documentation for all public commands for the module can be viewed:

```powershell
Get-Help -Full <commandName>
```

----------

## Prerequisites

To use this module you need to create an Azure AD application. Once you have created the application you will need to perform the following tasks:

*   Get the Client ID (Application ID) of the application
*   Get the Tenant ID of the Azure AD environment
*   Create a Client Secret or Client Certificate for the application
*   Add the following Microsoft Graph Application Permissions to the application: `Files.ReadWrite.All`, `Sites.ReadWrite.All`, `User.Read.All`
*   To target users by group membership, also add `GroupMember.Read.All` (or a broader equivalent such as `Group.Read.All`)
*   If you are using a Client Certificate you must have it stored on your workstation or loaded in your workstation's certificate store

----------

## Examples

### Connecting with a Client Secret

```powershell
Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force)
```

### Connecting with a Client Certificate

```powershell
Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate (Get-Item -Path 'Cert:\CurrentUser\My\0000000000000000000000000000000000000000)
```

### Connecting to a national cloud

Use `-Cloud` with `Global` (default), `GCC`, `GCCHigh`, `DoD` or `China`.

```powershell
Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force) -Cloud GCCHigh
```

### Disconnecting

```powershell
Disconnect-odsc
```

### Retrieving the properties of a Drive resource

```powershell
Get-odscDrive -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut to a Document Library

```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut to a Document Library with a custom Name

```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -ShortcutName "Working DL"
```

### Creating a new Shortcut to a Subfolder in a Document Library

```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut to a Subfolder in a Document Library with a custom Name

```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com" -ShortcutName "Working"
```

### Creating a new Shortcut to the root of a document library in a subfolder of the user's OneDrive
```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -RelativePath "subfolder1/subfolder2" -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut using the Document Library ID

```powershell
New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibraryId "00000000-0000-0000-0000-000000000000" -UserPrincipalName "user@contoso.com"
```

### Ensuring a Shortcut exists without creating duplicates

`Set-odscShortcutState` can be run repeatedly. If the shortcut already exists and points to the same target, nothing is changed.

```powershell
Set-odscShortcutState -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

Use `-ConflictAction` (`Skip`, `Replace`, `Rename` or `Error`) to choose what happens when an item with the same name points somewhere else, and `-State Absent` to remove the shortcut.

### Getting an existing Shortcut by Name

```powershell
Get-odsc -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

### Getting an existing Shortcut in a subfolder by Name

```powershell
Get-odsc -ShortcutName "Working Folder" -RelativePath "subfolder1/subfolder2" -UserPrincipalName "user@contoso.com"
```

### Removing an existing Shortcut by Name

```powershell
Remove-odsc -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

### Removing an existing Shortcut placed in a subfolder by Name

```powershell
Remove-odsc -ShortcutName "Working Folder" -RelativePath "subfolder1/subfolder2" -UserPrincipalName "user@contoso.com"
```

### Removing an existing Shortcut and getting a result object

```powershell
Remove-odsc -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com" -PassThru
```

----------

## Organization-scale examples

### Checking permissions before a rollout

```powershell
Test-odscPermission -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -GroupId "00000000-0000-0000-0000-000000000000"
```

### Assigning a Shortcut to all members of a group

```powershell
Get-odscTargetUser -GroupId "00000000-0000-0000-0000-000000000000" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ReportPath ".\report.csv"
```

Disabled accounts are skipped when targeting a group, a filter or all users. Add `-IncludeDisabled` to `Get-odscTargetUser` to include them.

### Assigning a Shortcut to users from a CSV file

The CSV file needs a `UserPrincipalName` and/or `UserObjectId` (or `Id`) column.

```powershell
Get-odscTargetUser -CsvPath ".\users.csv" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -RelativePath "Shortcuts"
```

### Assigning a Shortcut to users matching a filter

```powershell
Get-odscTargetUser -Filter "department eq 'Sales'" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library"
```

### Previewing and resuming a run

Use `-WhatIf` to preview. Every result has an `Index`; if a run is interrupted, continue with `-ResumeFrom`.

```powershell
$Users = Get-odscTargetUser -GroupId "00000000-0000-0000-0000-000000000000"
$Users | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -WhatIf
$Users | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ResumeFrom 250
```

Failures for individual users do not stop the run; they are returned with `Status` set to `Failed`.

----------

## Plan files

A plan file (`.json` or `.psd1`) describes several shortcuts and who should get them. A relative `csvPath` is resolved from the folder of the plan file.

```json
{
  "shortcuts": [
    {
      "name": "Sales Documents",
      "siteUrl": "https://contoso.sharepoint.com/sites/Sales",
      "library": "Documents",
      "oneDrivePath": "Shortcuts",
      "state": "Present",
      "conflictAction": "Skip",
      "target": { "groupId": "00000000-0000-0000-0000-000000000000" }
    },
    {
      "name": "Projects 2026",
      "siteUrl": "https://contoso.sharepoint.com/sites/Projects",
      "libraryId": "00000000-0000-0000-0000-000000000000",
      "folderPath": "2026",
      "target": { "csvPath": "project-users.csv" }
    }
  ]
}
```

A target is one of `groupId`, `csvPath`, `filter` or `allUsers` (`true`). Disabled accounts are skipped unless the target has `"includeDisabled": true` (not available for `csvPath`).

```powershell
Invoke-odscPlan -Path ".\shortcuts.json"
Invoke-odscApply -Path ".\shortcuts.json" -WhatIf
Invoke-odscApply -Path ".\shortcuts.json" -ReportPath ".\report.json" -OutputFormat Json
```

----------

## Error handling

By default, odsc commands do not stop your script when something fails. They write an error, return nothing, and your script continues with the next statement. This is useful when processing many users in a loop.

### Stopping on an error

Add `-ErrorAction Stop` to turn the error into one that stops the script, and handle it with `try`/`catch`:

```powershell
try {
    New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -ErrorAction Stop
} catch {
    Write-Warning "Shortcut not created: $($_.Exception.Message)"
    exit 1
}
```

To make every command in a script stop on errors, set this at the top of the script:

```powershell
$ErrorActionPreference = 'Stop'
```

### Checking without stopping

To check whether a shortcut exists without writing an error, use `-ErrorAction SilentlyContinue`:

```powershell
if (-not (Get-odsc -ShortcutName "Working Document Library" -UserPrincipalName "user@contoso.com" -ErrorAction SilentlyContinue)) {
    New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
}
```

### Stopping a run for many users

`Invoke-odscShortcutAssignment` and `Invoke-odscApply` return a failure for one user as a result with `Status` set to `Failed` and carry on with the next user. Because these failures are results rather than errors, `-ErrorAction` does not change this. Use `-StopOnError` to stop at the first failure instead:

```powershell
$Users = Get-odscTargetUser -CsvPath ".\users.csv"
$Users | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ReportPath ".\report.csv" -StopOnError
```

The error message gives the index of the user that failed. The report contains the results up to that user. Once the cause is fixed, continue from that index:

```powershell
$Users | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ReportPath ".\report-resumed.csv" -ResumeFrom 42
```

### Summary

| Command | Default | To stop on error |
| --- | --- | --- |
| `Connect-odsc` | Stops | (always stops) |
| `Get-odsc`, `Get-odscDrive`, `New-odsc`, `Remove-odsc`, `Set-odscShortcutState`, `Get-odscTargetUser`, `Invoke-odscPlan` | Writes an error and continues | `-ErrorAction Stop` |
| `Invoke-odscShortcutAssignment`, `Invoke-odscApply` | Reports failures as results and continues | `-StopOnError` |
| `Test-odscPermission` | Reports every check as Passed or Failed | (never errors) |
