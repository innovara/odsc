---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Invoke-odscShortcutAssignment.md
schema: 2.0.0
---

# Invoke-odscShortcutAssignment

## SYNOPSIS
Sets a shortcut state for many users.

## SYNTAX

```
Invoke-odscShortcutAssignment [-User] <Object[]> [-Uri] <String> [[-DocumentLibrary] <String>]
 [[-DocumentLibraryId] <String>] [[-FolderPath] <String>] [[-RelativePath] <String>] [[-ShortcutName] <String>]
 [[-State] <String>] [[-ConflictAction] <String>] [[-ResumeFrom] <Int32>] [[-ReportPath] <String>]
 [[-OutputFormat] <String>] [-StopOnError] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The **Invoke-odscShortcutAssignment** function runs Set-odscShortcutState for each user. A failure for one user does not stop the run: it is returned as a result with Status Failed and the error in Message. Each result has an Index property that can be used with -ResumeFrom.

Users are processed sequentially. Microsoft Graph throttling is handled by retrying with the delay requested by Graph.

## EXAMPLES

### Example 1: Assign a shortcut to the members of a group
```powershell
PS C:\> Get-odscTargetUser -GroupId "00000000-0000-0000-0000-000000000000" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ReportPath ".\report.csv"
```

This command creates the shortcut for every member of the group and writes the results to report.csv.

### Example 2: Resume an interrupted run
```powershell
PS C:\> $Users = Get-odscTargetUser -CsvPath ".\users.csv"
Invoke-odscShortcutAssignment -User $Users -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ResumeFrom 250
```

This command processes the users from index 250 onwards.

### Example 3: Preview changes
```powershell
PS C:\> Get-odscTargetUser -CsvPath ".\users.csv" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -WhatIf
```

This command shows which users would be processed without making changes.

### Example 4: Stop at the first failure
```powershell
PS C:\> try {
    Get-odscTargetUser -CsvPath ".\users.csv" | Invoke-odscShortcutAssignment -Uri "https://contoso.sharepoint.com/sites/WorkingSite" -DocumentLibrary "Working Document Library" -ReportPath ".\report.csv" -StopOnError
} catch {
    Write-Warning $_.Exception.Message
}
```

This command stops at the first user that fails. The warning shows the index to pass to -ResumeFrom after fixing the cause, and report.csv contains the results up to that user.

## PARAMETERS

### -ConflictAction
Specifies what to do when an item with the shortcut name already exists and does not point to the requested target: Skip (default) returns a SkippedConflict result, Error stops with an error, Replace deletes the existing shortcut and creates a new one (items that are not shortcuts are never deleted), and Rename creates the shortcut with a UTC timestamp appended to its name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Skip, Replace, Rename, Error

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DocumentLibrary
Specifies a string that contains the document library display name. An exact match is preferred; otherwise the first library whose name starts with this value is used. Either -DocumentLibrary or -DocumentLibraryId is required.

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

### -DocumentLibraryId
Specifies the list ID (GUID) of the document library. Use it instead of -DocumentLibrary to avoid ambiguous name matches.

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

### -FolderPath
Specifies a string that contains the folder path inside of the document library, relative to the library root (for example "Projects/2026").

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

### -OutputFormat
Specifies the report format: Csv (default), Json or Clixml.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Csv, Json, Clixml

Required: False
Position: 11
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
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Specifies a file path where a report of all results is written.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResumeFrom
Specifies the zero-based index of the first user to process. Every result includes an Index property, so a run that was interrupted can be resumed from the index after the last result.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
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
Position: 6
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
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopOnError
Stops the run at the first user that fails, with a terminating error that includes the index to use with -ResumeFrom. Without it, failures are returned as results with Status Failed and the run continues.

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

### -Uri
Specifies a string that contains the URL of the SharePoint site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -User
Specifies the users to process, as objects with a UserPrincipalName and/or UserObjectId (or Id) property, such as the output of Get-odscTargetUser, or as user principal name strings. Accepts pipeline input.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

### System.Object[]
## OUTPUTS

### System.Object
## NOTES
A failure for one user does not stop the run: it is returned as a result with Status Failed and the next user is processed. To stop at the first failed user instead, use -StopOnError. The error message includes the index to use with -ResumeFrom once the cause has been fixed, and the report is still written. -ErrorAction does not change this behaviour, because per-user failures are returned as results rather than written as errors. See the "Error handling" section of USAGE.md.

## RELATED LINKS
