---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Get-odsc.md
schema: 2.0.0
---

# Get-odsc

## SYNOPSIS
Get metadata for a OneDrive shortcut to SharePoint.

## SYNTAX

### UserPrincipalName (Default)
```
Get-odsc -ShortcutName <String> -UserPrincipalName <String> [<CommonParameters>]
```

### UserObjectId
```
Get-odsc -ShortcutName <String> -UserObjectId <String> [<CommonParameters>]
```

## DESCRIPTION
The **Get-odsc** function gets the metadata for a shortcut in a user's OneDrive that points to a SharePoint/Teams document library or sub-folder.

## EXAMPLES

### Example 1: Get a OneDrive shortcut
```powershell
PS C:\> Get-odsc -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

This command gets the shortcut called "Working Folder" for the user "user@contoso.com".

## PARAMETERS

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
