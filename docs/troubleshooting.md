# Troubleshooting odsc

This guide is intended for tenant administrators who operate `odsc` in scheduled jobs, broad group assignments, migration projects, or service-principal based automation.

Start with a preflight check whenever possible:

```powershell
$PermissionCheckParameters = @{
    Uri = 'https://contoso.sharepoint.com/sites/WorkingSite'
    DocumentLibrary = 'Documents'
    UserPrincipalName = 'user@contoso.com'
    GroupId = '00000000-0000-0000-0000-000000000000'
}

Test-odscPermission @PermissionCheckParameters | Format-Table -AutoSize
```

`Test-odscPermission` validates the Graph connection, optional group membership access, optional user OneDrive access, optional SharePoint site access, and optional shortcut target resolution. Run it before a large `Invoke-odscShortcutAssignment` or `Invoke-odscApply` job.

## Quick triage checklist

1. Confirm the current automation has called `Connect-odsc` and that the app registration has admin-consented Microsoft Graph application permissions.
2. Run `Test-odscPermission` with the same user, group, site, document library, and folder inputs that the failing job uses.
3. Re-run the failing command with `-Verbose` to capture the Graph resource path, retry messages, and request id when available.
4. For organization-scale changes, run the command with `-WhatIf` first and write a report with `-ReportPath`. Add `-StopOnError` to stop at the first failed user while investigating.
5. If only some users fail, separate target resolution failures from user OneDrive provisioning or per-user permission issues.

## Authentication and token issues

### Symptom: `Please run Connect-odsc first.`

The module did not find a usable Microsoft Graph token. Call `Connect-odsc` in the same PowerShell session or runspace as the failing command.

```powershell
$ClientSecretParameters = @{
    String = $env:ODSC_CLIENT_SECRET
    AsPlainText = $true
    Force = $true
}

$ConnectParameters = @{
    TenantId = $env:ODSC_TENANT_ID
    ClientId = $env:ODSC_CLIENT_ID
    ClientSecret = ConvertTo-SecureString @ClientSecretParameters
}

Connect-odsc @ConnectParameters
```

For scheduled jobs and CI systems, make sure each run authenticates before calling any other `odsc` command. Tokens are stored in module session state, not in a machine-wide cache.

### Symptom: token request fails for a cloud

Check that the selected cloud and endpoint match your tenant:

```powershell
$ConnectParameters = @{
    TenantId = $env:ODSC_TENANT_ID
    ClientId = $env:ODSC_CLIENT_ID
    ClientSecret = ConvertTo-SecureString -String $env:ODSC_CLIENT_SECRET -AsPlainText -Force
}

Connect-odsc -Cloud Global @ConnectParameters
```

Change `-Cloud` to `GCC`, `GCCHigh`, `DoD`, or `China` only when the tenant is hosted in that Microsoft cloud. Use `-GraphEndpoint` only when you intentionally need a custom Graph root. If you provide both `-Cloud` and legacy `-AzureCloudInstance`, they must describe the same cloud.

## Microsoft Graph permission failures

### Symptom: Graph returns `403` for basic calls

A `403` generally means the app registration can authenticate but lacks the application permission needed for the resource. Confirm admin consent for the permissions required by your scenario.

Common permission areas:

| Scenario | Typical permissions to validate |
| --- | --- |
| Read users | `User.Read.All` or a broader directory read permission |
| Read group transitive members | `GroupMember.Read.All`, `Group.Read.All`, or `Directory.Read.All` |
| Read hidden group membership | `Member.Read.Hidden` in addition to group membership permissions |
| Resolve SharePoint sites and lists | `Sites.Read.All` / `Sites.ReadWrite.All`, or suitable site-scoped access |
| Create, move, rename, or remove shortcuts in OneDrive | `Files.ReadWrite.All` and/or site/file permissions appropriate for your tenant model |

After updating permissions, grant admin consent and acquire a new token by running `Disconnect-odsc` and `Connect-odsc` again.

### Symptom: group targeting fails with a message about `transitiveMembers`

Group targeting calls Microsoft Graph transitive member APIs. Grant admin consent for `GroupMember.Read.All`, or use a broader equivalent such as `Group.Read.All` or `Directory.Read.All`. Hidden membership groups also require `Member.Read.Hidden`.

If permissions are intentionally restricted, export the target users to CSV from an approved source and use `Get-odscTargetUser -CsvPath` instead of direct group targeting.

## User OneDrive access and provisioning

### Symptom: only certain users fail during assignment

Validate an affected user directly:

```powershell
$CheckParameters = @{
    UserPrincipalName = 'user@contoso.com'
}

Test-odscPermission @CheckParameters
Get-odscDrive @CheckParameters
```

Common causes:

* The user's OneDrive has not been provisioned yet.
* The account is disabled or unlicensed.
* The app registration cannot access that user's drive under the tenant's current permission or conditional-access model.
* The input user is malformed, duplicated, or uses an external/guest identity that does not have a OneDrive drive.

For CSV targeting, verify that the file contains `UserPrincipalName`, `UserObjectId`, or `Id` columns and that each row resolves to the expected user.

## SharePoint site and document library resolution

### Symptom: site cannot be resolved

Use the exact SharePoint site URL, not a sharing link or a document-library URL with extra path segments:

```powershell
Test-odscPermission -Uri 'https://contoso.sharepoint.com/sites/WorkingSite'
```

If the tenant uses a national cloud, confirm the SharePoint URL and the Graph cloud selected in `Connect-odsc` belong to the same environment.

### Symptom: document library name is not found

`-DocumentLibrary` is matched against SharePoint list display names. Confirm the display name in SharePoint or use the stable list id instead:

```powershell
New-odsc `
    -Uri 'https://contoso.sharepoint.com/sites/WorkingSite' `
    -DocumentLibraryId '00000000-0000-0000-0000-000000000000' `
    -UserPrincipalName 'user@contoso.com'
```

Use `-DocumentLibraryId` when display names are localized, duplicated, renamed, or ambiguous.

### Symptom: selected target is a SharePoint list, not a document library

OneDrive shortcuts can only point to document libraries and their folders. Lists that are not libraries are ignored when matching `-DocumentLibrary` by name, and a `-DocumentLibraryId` that belongs to one is rejected. Choose a document library, or check the id.

### Symptom: warning that a document library name matched multiple libraries

An exact display name match is always preferred. When there is none, the first library whose name starts with `-DocumentLibrary` is used and a warning lists all the matches. Specify the exact name, or `-DocumentLibraryId`, for deterministic behavior in automation.

## Folder and path issues

### Symptom: `-FolderPath` cannot be found

`-FolderPath` is relative to the root of the selected document library. Do not include the library name in the path.

```powershell
# Correct when the library is Documents and the target is Documents/Projects/2026
-FolderPath 'Projects/2026'

# Incorrect
-FolderPath 'Documents/Projects/2026'
```

Confirm the folder exists and that the app registration can read it.

### Symptom: `-RelativePath` cannot be found or shortcut creation fails in a OneDrive subfolder

`-RelativePath` is relative to the user's OneDrive root and controls where the shortcut appears in the user's OneDrive. Missing folders are created, but admins should still validate the target path on a small pilot group before a broad rollout.

Avoid leading slashes and prefer forward slashes:

```powershell
-RelativePath 'Shortcuts/Department Sites'
```

Shortcuts are created at the root of the user's OneDrive, moved into `-RelativePath` and then renamed. If the move fails, the error says so and the shortcut is left at the root of the user's OneDrive.

## Existing shortcut conflicts

### Symptom: error saying the user already has a shortcut to this target

OneDrive allows one shortcut per library or folder, and none to a folder inside a library that already has one. The existing shortcut may have another name or be in another folder. Find it in the user's OneDrive, or use `Set-odscShortcutState`, which reports an existing matching shortcut as `Compliant`.

### Symptom: shortcut created with another name, or status `RenameFailed`

The requested name was already used by another item in the destination, so OneDrive created the shortcut as `<site> - <name>` and the rename failed. The shortcut is kept so the user has access. Rename or move the item that uses the name, then rename the shortcut. The error message and the result's `ShortcutName` give the actual name.

### Symptom: shortcut already exists or has the wrong target

Use `Set-odscShortcutState` for idempotent convergence instead of only `New-odsc`. Pick a conflict action that matches your change policy:

| Conflict action | Use when |
| --- | --- |
| `Skip` | Existing shortcuts should be left untouched. |
| `Replace` | A wrong shortcut should be removed and recreated. Items that are not shortcuts are never deleted. |
| `Rename` | A new shortcut should be created with a unique name when a conflict exists. |
| `Error` | Any unexpected existing shortcut should fail the run. |

`-State Absent` only removes a shortcut that points to the requested target; a shortcut with the same name pointing elsewhere is reported as `SkippedConflict`.

Start with `-WhatIf` when changing conflict behavior across many users.

## Throttling, transient failures, and request ids

### Symptom: Graph returns `429`, `500`, `502`, `503`, or `504`

The module retries transient Microsoft Graph failures with exponential backoff and honors `Retry-After` when Graph provides it. For large assignments:

* Use smaller target batches.
* Schedule jobs outside peak business hours.
* Keep `-Verbose` output from failed runs so you can inspect status codes and request ids.
* Re-run failed users from the report instead of reprocessing every user, or continue an interrupted run with `-ResumeFrom` using the `Index` of the last result.

If failures persist with the same request id or resource path, open a Microsoft support case with the request id, timestamp, tenant id, and failing Graph resource.

## Reporting and audit output

For broad changes, always write a report:

```powershell
Invoke-odscShortcutAssignment @AssignmentParameters -ReportPath '.\odsc-results.csv' -OutputFormat Csv
```

Recommended workflow:

1. Run with `-WhatIf` for a small pilot group.
2. Run without `-WhatIf` for the pilot and review the report.
3. Expand to a larger group.
4. Re-run only failed rows after correcting permissions, paths, or provisioning issues.

Use CSV for operational triage, JSON for automation pipelines, and CLIXML when you need PowerShell-native object fidelity.

## National cloud endpoint checks

Use the `-Cloud` parameter instead of manually setting endpoints unless you have a specific advanced scenario.

| Cloud | Graph endpoint |
| --- | --- |
| `Global` | `https://graph.microsoft.com` |
| `GCC` | `https://graph.microsoft.com` |
| `GCCHigh` | `https://graph.microsoft.us` |
| `DoD` | `https://dod-graph.microsoft.us` |
| `China` | `https://microsoftgraph.chinacloudapi.cn` |

If authentication succeeds but all resource calls fail, verify:

* The tenant belongs to the selected cloud.
* The SharePoint site URL belongs to that same cloud.
* The app registration exists and has consent in that tenant/cloud.
* Any custom `-GraphEndpoint` starts with `https://` and points to the intended Graph root.

## Escalation checklist

When escalating to a platform owner or Microsoft support, capture:

* The exact command and sanitized parameters.
* `-Verbose` output.
* The failing user, group id, site URL, document library name/id, and folder path.
* The HTTP status code and Graph request id if present.
* The output of `Test-odscPermission` for the same inputs.
* Whether the issue affects all users or only a subset.
