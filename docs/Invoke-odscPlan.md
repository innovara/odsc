---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Invoke-odscPlan.md
schema: 2.0.0
---

# Invoke-odscPlan

## SYNOPSIS
Reads a shortcut plan file.

## SYNTAX

```
Invoke-odscPlan [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
The **Invoke-odscPlan** function reads a .json or .psd1 plan file and returns one object per shortcut, without making any changes. Use it to validate a plan before running Invoke-odscApply.

A plan contains a "shortcuts" list. Each entry supports name, siteUrl, library or libraryId, folderPath, oneDrivePath, state (Present or Absent), conflictAction (Skip, Replace, Rename or Error) and a target with one of groupId, csvPath, filter or allUsers. A relative csvPath is resolved from the folder of the plan file.

## EXAMPLES

### Example 1: Read a plan
```powershell
PS C:\> Invoke-odscPlan -Path ".\shortcuts.json"
```

This command returns the shortcuts defined in shortcuts.json.

## PARAMETERS

### -Path
Specifies the path to a .json or .psd1 plan file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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
