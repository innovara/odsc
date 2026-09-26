---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Get-odscTargetUser.md
schema: 2.0.0
---

# Get-odscTargetUser

## SYNOPSIS
Gets the users to target with a shortcut assignment.

## SYNTAX

### AllUsers (Default)
```
Get-odscTargetUser [-AllUsers] [<CommonParameters>]
```

### Csv
```
Get-odscTargetUser -CsvPath <String> [<CommonParameters>]
```

### Group
```
Get-odscTargetUser -GroupId <String> [<CommonParameters>]
```

### Filter
```
Get-odscTargetUser -Filter <String> [<CommonParameters>]
```

## DESCRIPTION
The **Get-odscTargetUser** function returns user objects with the properties UserPrincipalName, UserObjectId, Mail, AccountEnabled and Source, read from a CSV file, from the transitive members of a group, from an OData filter, or from all users in the tenant. The output can be piped to Invoke-odscShortcutAssignment.

Group and filter queries require the GroupMember.Read.All (or broader) and User.Read.All application permissions.

## EXAMPLES

### Example 1: Get the members of a group
```powershell
PS C:\> Get-odscTargetUser -GroupId "00000000-0000-0000-0000-000000000000"
```

This command returns all users that are direct or nested members of the group.

### Example 2: Get users from a CSV file
```powershell
PS C:\> Get-odscTargetUser -CsvPath ".\users.csv"
```

This command returns the users listed in users.csv.

### Example 3: Get enabled users in a department
```powershell
PS C:\> Get-odscTargetUser -Filter "department eq 'Sales' and accountEnabled eq true"
```

This command returns the enabled users of the Sales department.

## PARAMETERS

### -AllUsers
Returns all users in the tenant.

```yaml
Type: SwitchParameter
Parameter Sets: AllUsers
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CsvPath
Specifies a CSV file with a UserPrincipalName and/or UserObjectId (or Id) column. A Mail column is also read. Rows without an identifier are skipped with a warning.

```yaml
Type: String
Parameter Sets: Csv
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Specifies an OData filter for users, for example "department eq 'Sales'". Advanced queries are supported.

```yaml
Type: String
Parameter Sets: Filter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupId
Specifies the ID of a group. All users that are direct or nested members of the group are returned.

```yaml
Type: String
Parameter Sets: Group
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
Errors are non-terminating: the command writes an error and your script continues with the next statement. To stop on an error instead, add -ErrorAction Stop (or set $ErrorActionPreference = 'Stop' for the whole script) and handle the error with try/catch. See the "Error handling" section of USAGE.md.

## RELATED LINKS
