---
external help file: OneDriveShortcuts-help.xml
Module Name: OneDriveShortcuts
online version: https://github.com/derpenstiltskin/onedriveshortcuts/blob/main/docs/Connect-ODS.md
schema: 2.0.0
---

# Connect-ODS

## SYNOPSIS
Connects and creates a session to the Microsoft Graph API.

## SYNTAX

### ClientSecret (Default)
```
Connect-ODS -TenantId <String> -ClientId <String> -ClientSecret <SecureString> -AzureCloudInstance <Integer> [<CommonParameters>]
```

### ClientCertificate
```
Connect-ODS -TenantId <String> -ClientId <String> -ClientCertificate <X509Certificate2> -AzureCloudInstance <Integer> [<CommonParameters>]
```

## DESCRIPTION
The **Connect-ODS** function authenticates and creates a session to the Microsoft Graph API.

## EXAMPLES

### Example 1: Connect using a client secret
```powershell
PS C:\> Connect-ODS -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" 000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force)
```

This command connects to the Microsoft Graph API using a client secret configured in the Azure AD application.

### Example 2: Connect using a client certificate
```powershell
PS C:\> Connect-ODS -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate (Get-Item -Path 'Cert:\CurrentUser\My\0000000000000000000000000000000000000000')
```

This command connects to the Microsoft Graph API using a client certificate configured in the Azure AD application.

## PARAMETERS

### -ClientCertificate
Specifies a certificate that has been configured in the Azure AD application for authentication.

```yaml
Type: X509Certificate2
Parameter Sets: ClientCertificate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Specifies a string that contains the client ID of the Azure AD application.

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

### -ClientSecret
Specifies a secure string that contains the client secret that has been configured in the Azure AD application for authentication.

```yaml
Type: SecureString
Parameter Sets: ClientSecret
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
Species a string that contains the tenant ID of the Azure/365 environment of the Azure AD application.

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

### -AzureCloudInstance
Species an integer that corresponds to an Azure Cloud Instance type (None = 0, AzurePublic = 1, AzureChina = 2, AzureGermany = 3, AzureUsGovernment = 4)

```yaml
Type: Integer
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
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
