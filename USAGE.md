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
*   Add the following Microsoft Graph Application Permissions to the application: `Files.ReadWrite.All`, `Sites.ReadWrite.All`, `User.Read.All`
*   If you are using a Client Certificate you must have it stored on your workstation or loaded in your workstation's certificate store

----------

## Module Documentation
## Examples

### Connecting with a Client Secret

```powershell
Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force)
```

### Connecting with a Client Certificate

```powershell
Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate (Get-Item -Path 'Cert:\CurrentUser\My\0000000000000000000000000000000000000000)
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
