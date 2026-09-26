---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Set-odscShortcutState.md
schema: 2.0.0
---

# Set-odscShortcutState

## SYNOPSIS
Ensures a OneDrive shortcut to SharePoint is present or absent.

## SYNTAX

### UserPrincipalName (Default)
```
Set-odscShortcutState -Uri <String> [-DocumentLibrary <String>] [-DocumentLibraryId <String>]
 [-FolderPath <String>] [-RelativePath <String>] [-ShortcutName <String>] -UserPrincipalName <String>
 [-State <String>] [-ConflictAction <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### UserObjectId
```
Set-odscShortcutState -Uri <String> [-DocumentLibrary <String>] [-DocumentLibraryId <String>]
 [-FolderPath <String>] [-RelativePath <String>] [-ShortcutName <String>] -UserObjectId <String>
 [-State <String>] [-ConflictAction <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **Set-odscShortcutState** function makes sure that a user's OneDrive contains (or does not contain) a shortcut pointing to a SharePoint/Teams document library or subfolder. It can be run repeatedly: when a shortcut with the requested name already points to the requested target, nothing is changed and a Compliant result is returned.

It returns an odsc.ShortcutResult object with the properties User, ShortcutName, Action, Status (Created, Compliant, SkippedConflict, RenameFailed, Removed or AlreadyAbsent), TargetSite, TargetLibrary, TargetFolderPath, DriveItemId, WebUrl, Message, Response and Timestamp.

RenameFailed means the shortcut was created but could not be given the requested name or moved to -RelativePath. It is kept, so the user has access; ShortcutName holds its actual name and Message explains what to fix.

## EXAMPLES

### Example 1: Ensure a shortcut exists
```powershell
PS C:\> Set-odscShortcutState -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -UserPrincipalName "user@contoso.com"
```

This command creates the shortcut "Working Document Library" for the user "user@contoso.com" unless it already exists and points to the same library.

### Example 2: Replace a shortcut that points elsewhere
```powershell
PS C:\> Set-odscShortcutState -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -RelativePath "Shortcuts" -ConflictAction Replace -UserPrincipalName "user@contoso.com"
```

This command makes sure the shortcut in the "Shortcuts" folder points to "Working Document Library", replacing an existing shortcut with the same name that points to another target.

### Example 3: Remove a shortcut
```powershell
PS C:\> Set-odscShortcutState -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -State Absent -UserPrincipalName "user@contoso.com"
```

This command removes the shortcut "Working Document Library" if it points to that library.

## PARAMETERS

### -ConflictAction
Specifies what to do when an item with the shortcut name already exists and does not point to the requested target: Skip (default) returns a SkippedConflict result, Error stops with an error, Replace deletes the existing shortcut and creates a new one (items that are not shortcuts are never deleted), and Rename creates the shortcut with a UTC timestamp appended to its name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Skip, Replace, Rename, Error

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentLibrary
Specifies a string that contains the document library display name. An exact match is preferred; otherwise the first library whose name starts with this value is used. SharePoint lists that are not libraries are ignored, because shortcuts can only point to document libraries. Either -DocumentLibrary or -DocumentLibraryId is required.

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
Specifies a string that contains the folder path inside of the document library, relative to the library root (for example "Projects/2026").

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

### -PassThru
Returns the Microsoft Graph drive item of the created or already compliant shortcut instead of an odsc.ShortcutResult object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelativePath
Specifies a string that contains the folder path inside of the user's OneDrive where the shortcut will be placed. Missing folders are created.

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
Specifies a string that contains the name of the shortcut to be placed in the user's OneDrive. Defaults to the document library name, or the folder name when -FolderPath is used.

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

### -State
Specifies the desired state of the shortcut: Present (default) or Absent. Absent only removes a shortcut that points to the requested target.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Present, Absent

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
Specifies a string that contains the ID of a OneDrive user. Accepts pipeline input by property name, including from a property named UserId.

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
Specifies a string that contains the user principal name of a OneDrive user. Accepts pipeline input by property name.

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

### System.String
## OUTPUTS

### System.Object
## NOTES
Errors are non-terminating: the command writes an error and your script continues with the next statement. To stop on an error instead, add -ErrorAction Stop (or set $ErrorActionPreference = 'Stop' for the whole script) and handle the error with try/catch. See the "Error handling" section of USAGE.md.

## RELATED LINKS
