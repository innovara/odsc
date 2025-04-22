---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Get-odscDrive.md
schema: 2.0.0
---

# Get-odscDrive

## SYNOPSIS
Retrieve the properties and relationships of a Drive resource.

## SYNTAX

### UserPrincipalName (Default)
```
Get-odscDrive -UserPrincipalName <String> [<CommonParameters>]
```

### UserObjectId
```
Get-odscDrive -UserObjectId <String> [<CommonParameters>]
```

## DESCRIPTION
The **Get-odscDrive** function gets the metadata for a a user's OneDrive drive.

## EXAMPLES

### Example 1: Get a OneDrive drive
```powershell
PS C:\> Get-odscDrive -UserPrincipalName "user@contoso.com"
```

This command gets the OneDrive drive for the user "user@contoso.com".

## PARAMETERS

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
