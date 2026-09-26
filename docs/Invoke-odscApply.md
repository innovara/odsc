---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Invoke-odscApply.md
schema: 2.0.0
---

# Invoke-odscApply

## SYNOPSIS
Applies a shortcut plan file.

## SYNTAX

```
Invoke-odscApply [-Path] <String> [[-ReportPath] <String>] [[-OutputFormat] <String>] [-StopOnError]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The **Invoke-odscApply** function reads a plan file with Invoke-odscPlan, resolves the target users of each shortcut with Get-odscTargetUser and runs Invoke-odscShortcutAssignment. See Invoke-odscPlan for the plan format.

## EXAMPLES

### Example 1: Apply a plan and write a report
```powershell
PS C:\> Invoke-odscApply -Path ".\shortcuts.json" -ReportPath ".\report.json" -OutputFormat Json
```

This command applies every shortcut in shortcuts.json and writes the results to report.json.

### Example 2: Preview a plan
```powershell
PS C:\> Invoke-odscApply -Path ".\shortcuts.json" -WhatIf
```

This command shows which shortcuts would be applied to which targets without making changes.

### Example 3: Stop at the first problem
```powershell
PS C:\> Invoke-odscApply -Path ".\shortcuts.json" -ReportPath ".\report.csv" -StopOnError
```

This command stops the run at the first target that cannot be resolved or user that fails, and still writes report.csv.

## PARAMETERS

### -OutputFormat
Specifies the report format: Csv (default), Json or Clixml.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Csv, Json, Clixml

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -ReportPath
Specifies a file path where a report of all results is written.

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

### -StopOnError
Stops the run at the first problem: a target whose users cannot be resolved, or a user that fails. Without it, the problem is reported and the run continues.

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
A shortcut whose target users cannot be resolved is reported as an error and the next shortcut in the plan is processed; failures for individual users are returned as results with Status Failed. To stop at the first problem instead, use -StopOnError. A plan file that cannot be read always ends the command with an error. The report is written even when the run stops. See the "Error handling" section of USAGE.md.

## RELATED LINKS
