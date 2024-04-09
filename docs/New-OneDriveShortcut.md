---
external help file: OneDriveShortcuts-help.xml
Module Name: OneDriveShortcuts
online version: https://github.com/derpenstiltskin/onedriveshortcuts/blob/main/docs/New-OneDriveShortcut.md
schema: 2.0.0
---

# New-OneDriveShortcut

## SYNOPSIS
Create OneDrive shortcut to SharePoint.

## SYNTAX

### UserPrincipalName (Default)
```
New-OneDriveShortcut -Uri <String> -DocumentLibrary <String> [-FolderPath <String>] [-ShortcutName <String>]
 -UserPrincipalName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UserObjectId
```
New-OneDriveShortcut -Uri <String> -DocumentLibrary <String> [-FolderPath <String>] [-ShortcutName <String>]
 -UserObjectId <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **New-OneDriveShortcut** function creates a shortcut in a user's OneDrive that points to a SharePoint/Teams document library or sub-folder.

## EXAMPLES

### Example 1: Create a shortcut to the root of a document library
```powershell
PS C:\> New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/site/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working Document Library" for the user "user@contoso.com" that points to the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/site/WorkingSite".

### Example 2: Create a shortcut to the root of a document library with a custom name
```powershell
PS C:\> New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/site/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -ShortcutName "Working DL"
```

This command creates a shortcut called "Working DL" for the user "user@contoso.com" that points to the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/site/WorkingSite".

### Example 3: Create a shortcut to a sub-folder of a document library
```powershell
PS C:\> New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/site/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com"
```

This command creates a shortcut called "Working Folder" for the user "user@contoso.com" that points to the sub-folder "Working Folder" of the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/site/WorkingSite".

### Example 4: Create a shortcut to a sub-folder of a document library with a custom name
```powershell
PS C:\> New-OneDriveShortcut -Uri "https://contoso.sharepoint.com/site/WorkingSite" -DocumentLibrary "Working Document Library" -FolderPath "Working Folder" -UserPrincipalName "user@contoso.com" -ShortcutName "Working"
```

This command creates a shortcut called "Working" for the user "user@contoso.com" that points to the sub-folder "Working Folder" of the Document Library called "Working Document Library" on the SharePoint site "https://contoso.sharepoint.com/site/WorkingSite".


## PARAMETERS

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

### -DocumentLibrary
Specifies a string that contains the document library name.

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
Specifeis a string that contains the URL of the SharePoint site.

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
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
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

## RELATED LINKS
