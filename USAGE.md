# USAGE

#### Table of Contents
*   [Module Documentation](#module-documentation)
*   [Prerequisites](#prerequisites)
*   [Examples](#examples)

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
*   Add the following Microsoft Graph Application Permissions to the application: Files.ReadWrite.All, Sites.ReadWrite.All, Users.Read.All
*   If you are using a Client Certificate you must have it stored on your workstation or loaded in your workstation's certificate store

----------

## Module Documentation
## Examples

### Connecting with a Client Secret

```powershell
Connect-ODS -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force)
```

### Connecting with a Client Certificate

```powershell
Connect-ODS -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate (Get-Item -Path 'Cert:\CurrentUser\My\0000000000000000000000000000000000000000)
```

### Disconnecting

```powershell
Disconnect-ODS
```

### Creating a new Shortcut to a Document Library

```powershell
New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut to a Document Library with a custom Name

```powershell
New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -ShortcutName "Working DL"
```

### Creating a new Shortcut to a Sub-Folder in a Document Library

```powershell
New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com"
```

### Creating a new Shortcut to a Sub-Folder in a Document Library with a custom Name

```powershell
New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com" -ShortcutName "Working"
```

### Getting an existing Shortcut by Name

```powershell
Get-OneDriveShortcut -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

### Removing an existing Shortcut by Name

```powershell
Remove-OneDriveShortcut -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```
