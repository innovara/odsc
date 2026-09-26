# CHANGELOG

## 0.5.1

* The module manifest now lists the exported commands, so the PowerShell Gallery shows them and PowerShell can find them without loading the module
* GitHub Actions workflows use `actions/checkout@v7` (Node.js 24)

## 0.5.0

Existing scripts keep working: output types, error behavior and parameters of existing commands are unchanged, except for the additions listed below.

* New commands: `Set-odscShortcutState` (idempotent create/remove with `-ConflictAction`), `Get-odscTargetUser` (users from a group, CSV file, filter or all users), `Invoke-odscShortcutAssignment` (assign a shortcut to many users with reporting and `-ResumeFrom`), `Invoke-odscPlan` and `Invoke-odscApply` (plan files), and `Test-odscPermission` (pre-flight checks)
* `Connect-odsc`: new `-Cloud` (Global, GCC, GCCHigh, DoD, China) and `-GraphEndpoint` parameters. Microsoft Graph calls now go to the endpoint of the connected cloud; `-AzureCloudInstance` 2 and 4 now also select the China and US Government Graph endpoints
* `New-odsc`: new `-DocumentLibraryId` parameter; `-DocumentLibrary` is no longer mandatory when `-DocumentLibraryId` is used
* `New-odsc`: an exact document library name match is now preferred over a prefix match, and a warning is written when a prefix matches several libraries
* `New-odsc`: SharePoint lists that are not libraries are ignored when matching `-DocumentLibrary`, and rejected with a clear error when given as `-DocumentLibraryId`; shortcuts can only point to libraries
* `New-odsc`: `-FolderPath` is resolved through the document library drive, which is more reliable than the previous web URL search
* `Remove-odsc`: new `-PassThru` switch returning a result object
* `Invoke-odscShortcutAssignment` and `Invoke-odscApply`: new `-StopOnError` switch to stop at the first failure; the report is still written and the error gives the `-ResumeFrom` index
* All commands except `Connect-odsc` write non-terminating errors by default; use `-ErrorAction Stop` to stop on errors (see [Error handling](USAGE.md#error-handling))
* `Get-odscTargetUser` skips disabled accounts for groups, filters and all users unless `-IncludeDisabled` is used
* `-UserPrincipalName` and `-UserObjectId` (alias `UserId`) accept pipeline input by property name
* Fixed `-RelativePath` with nested folders: path segments are now encoded individually, and missing folders are created once and correctly nested
* Fixed site lookup for the tenant root site and for site URLs with a trailing slash
* `New-odsc` and `Set-odscShortcutState` explain when a shortcut cannot be created because the user already has a shortcut to the same target
* When a shortcut name is already taken, OneDrive creates the shortcut under another name and the rename fails: `New-odsc` now names the shortcut in its error, and `Set-odscShortcutState` returns the status `RenameFailed`
* Microsoft Graph requests are retried on throttling (429) and transient server errors, honoring `Retry-After`, and error messages include the HTTP status code and Graph request id
* Added `tests/integration/smoke-test.ps1` to check a release against a real tenant
* Added Pester tests, GitHub Actions CI (PowerShell 7 on Linux and Windows, Windows PowerShell 5.1) and a PowerShell Gallery publishing workflow
* Added [troubleshooting guide](docs/troubleshooting.md) and expanded [USAGE.md](USAGE.md)

## 0.4.1

* Fixed a security warning in WindowsPowerShell triggered by `Invoke-WebRequest` calls missing the `-UseBasicParsing` parameter.

## 0.4.0

* Add feature to create / get / remove shortcuts in OneDrive's subfolder

## 0.3.0

* Change endpoint `/drives/{idOrUserPrincipalName}` to `/users/{idOrUserPrincipalName}/drive`
* New command: `Get-odscDrive`
* Ease use in scripts by removing Stop on some errors
* Ensure that `Remove-odsc` removes a remoteItem-type resource
* Move token to global script variable for better interaction in scripts
* Other minor fixes and updates

## 0.2.1

* Add rename request to name shortcut exactly as passed to the script
* Change leading blank spaces to tabs
* Refactor from OneDriveShortcut to odsc. Commands now are: `Connect-odsc`, `Disconnect-odsc`, `Get-odsc`, `New-odsc`, `Remove-odsc`. API is `Invoke-odscApiRequest`

## 0.1.1

*   Fixed issue [#1](https://github.com/derpenstiltskin/onedriveshortcuts/issues/1#issue-1504890237) by adding option to specify AzureCloudInstance when connecting

## 0.1.0

*   Initial release
*   Commands: `Connect-ODS`, `Disconnect-ODS`, `Get-OneDriveShortcut`, `New-OneDriveShortcut`, `Remove-OneDriveShortcut`
