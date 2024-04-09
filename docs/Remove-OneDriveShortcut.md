---
external help file: OneDriveShortcuts-help.xml
Module Name: OneDriveShortcuts
online version: https://github.com/derpenstiltskin/onedriveshortcuts/blob/main/docs/Remove-OneDriveShortcut.md
schema: 2.0.0
---

# Remove-OneDriveShortcut

## SYNOPSIS
Removes OneDrive shortcut to SharePoint.

## SYNTAX

### UserPrincipalName (Default)
```
Remove-OneDriveShortcut -ShortcutName <String> -UserPrincipalName <String> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### UserObjectId
```
Remove-OneDriveShortcut -ShortcutName <String> -UserObjectId <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **Remove-OneDriveShortcut** function removes a shortcut in a user's OneDrive that points to a SharePoint/Teams document library or sub-folder.

## EXAMPLES

### Example 1: Remove shortcut with ShortcutName and UserPrincipalName
```powershell
PS C:\> Remove-Shortcut -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

This command removes the shortcut called "Working Folder" for the user "user@contoso.com".

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

### -ShortcutName
Specifies a string that contains the shortcut name of the shortcut.

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
