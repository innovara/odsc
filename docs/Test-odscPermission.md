---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Test-odscPermission.md
schema: 2.0.0
---

# Test-odscPermission

## SYNOPSIS
Checks that the connected application can perform shortcut operations.

## SYNTAX

```
Test-odscPermission [[-Uri] <String>] [[-UserPrincipalName] <String>] [[-UserObjectId] <String>]
 [[-GroupId] <String>] [[-DocumentLibrary] <String>] [[-DocumentLibraryId] <String>] [[-FolderPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The **Test-odscPermission** function runs read-only checks and returns one object per check with the properties Check, Status (Passed or Failed) and Message. It always checks that Microsoft Graph can be called, and optionally checks access to a group's members, a user's OneDrive, a SharePoint site and a document library or folder.

## EXAMPLES

### Example 1: Check access before a rollout
```powershell
PS C:\> Test-odscPermission -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com" -GroupId "00000000-0000-0000-0000-000000000000"
```

This command checks access to Microsoft Graph, the group members, the user's OneDrive, the site and the document library.

## PARAMETERS

### -DocumentLibrary
Specifies a document library display name to resolve. Requires -Uri.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentLibraryId
Specifies a document library ID to resolve. Requires -Uri.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FolderPath
Specifies a folder path inside the document library to resolve. Requires -Uri.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
Specifies a group ID whose members must be readable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Specifies the URL of a SharePoint site that must be readable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserObjectId
Specifies the ID of a user whose OneDrive must be readable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserPrincipalName
Specifies the user principal name of a user whose OneDrive must be readable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
