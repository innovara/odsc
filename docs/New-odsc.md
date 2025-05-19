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
New-odsc -Uri <String> -DocumentLibrary <String> [-FolderPath <String>] [-RelativePath <String>] [-ShortcutName <String>]
 -UserPrincipalName <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### UserObjectId
```
New-odsc -Uri <String> -DocumentLibrary <String> [-FolderPath <String>] [-RelativePath <String>] [-ShortcutName <String>]
 -UserObjectId <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **New-odsc** function creates a shortcut in a user's OneDrive that points to a SharePoint/Teams document library or subfolder.

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
