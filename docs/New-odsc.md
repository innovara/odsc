---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/New-odsc.md
schema: 2.0.0
---

# New-odsc

## SYNOPSIS
Create OneDrive shortcut to SharePoint.

## SYNTAX

### UserPrincipalName (Default)
```
New-odsc -Uri <String> [-DocumentLibrary <String>] [-DocumentLibraryId <String>] [-FolderPath <String>]
 [-RelativePath <String>] [-ShortcutName <String>] -UserPrincipalName <String>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UserObjectId
```
New-odsc -Uri <String> [-DocumentLibrary <String>] [-DocumentLibraryId <String>] [-FolderPath <String>]
 [-RelativePath <String>] [-ShortcutName <String>] -UserObjectId <String>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **New-odsc** function creates a shortcut in a user's OneDrive that points to a SharePoint/Teams document library or subfolder.

OneDrive allows one shortcut per target, so the command fails if the user already has a shortcut to the same library or folder. If the shortcut name is already used by another item in the destination, OneDrive creates the shortcut under another name (usually "<site> - <name>") and the command writes an error giving that name, so it can be renamed by hand. The shortcut is kept so the user does not lose access.

## EXAMPLES

### Example 1: Create a shortcut to the root of a document library
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working Document Library" for the user "user@contoso.com" that points to the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/sites/WorkingSite".

### Example 2: Create a shortcut to the root of a document library with a custom name
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library"  -ShortcutName "Working DL" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working DL" for the user "user@contoso.com" that points to the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/sites/WorkingSite".

### Example 3: Create a shortcut to a subfolder of a document library
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working Folder" for the user "user@contoso.com" that points to the subfolder "Working Folder" of the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/sites/WorkingSite".

### Example 4: Create a shortcut to a subfolder of a document library with a custom name
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder"  -ShortcutName "Working" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working" for the user "user@contoso.com" that points to the subfolder "Working Folder" of the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/sites/WorkingSite".

### Example 5: Create a shortcut to the root of a document library in a subfolder of the user's OneDrive
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -RelativePath "subfolder1/subfolder2" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut in the subfolder "subfolder1/subfolder2" for the user "user@contoso.com" that points to the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/sites/WorkingSite".

### Example 6: Create a shortcut using the document library ID
```powershell
PS C:\> New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibraryId "00000000-0000-0000-0000-000000000000" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut for the user "user@contoso.com" that points to the Document Library with the given ID. The shortcut is named after the library's display name.

### Example 7: Stop the script if the shortcut cannot be created
```powershell
PS C:\> try {
    New-odsc -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -ErrorAction Stop
} catch {
    Write-Warning "Shortcut not created: $($_.Exception.Message)"
    exit 1
}
```

By default an error is written and the script continues. With -ErrorAction Stop the error can be handled with try/catch, here by ending the script.

## PARAMETERS

### -DocumentLibrary
Specifies a string that contains the document library name. An exact match is preferred; otherwise the first library whose name starts with this value is used. SharePoint lists that are not libraries are ignored, because shortcuts can only point to document libraries. Either -DocumentLibrary or -DocumentLibraryId is required.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentLibraryId
Specifies the list ID (GUID) of the document library. Use it instead of -DocumentLibrary to avoid ambiguous name matches. An ID that belongs to a SharePoint list that is not a library is rejected.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderPath
Specifies a string that contains the folder path inside of the document library.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelativePath
Specifies a string that contains the folder path inside of the user's OneDrive where the shortcut will be placed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShortcutName
Specifies a string that contains the name of the shortcut to be placed in the user's OneDrive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Specifies a string that contains the URL of the SharePoint site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserObjectId
Specifies a string that contains the ID of a OneDrive user.

```yaml
Type: String
Parameter Sets: UserObjectId
Aliases: UserId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UserPrincipalName
Specifies a string that contains the user principal name of a OneDrive user.

```yaml
Type: String
Parameter Sets: UserPrincipalName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES
Errors are non-terminating: the command writes an error and your script continues with the next statement. To stop on an error instead, add -ErrorAction Stop (or set $ErrorActionPreference = 'Stop' for the whole script) and handle the error with try/catch. See the "Error handling" section of USAGE.md.

## RELATED LINKS
