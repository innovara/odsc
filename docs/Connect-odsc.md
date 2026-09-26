---
external help file: odsc-help.xml
Module Name: odsc
online version: https://github.com/innovara/odsc/blob/main/docs/Connect-odsc.md
schema: 2.0.0
---

# Connect-odsc

## SYNOPSIS
Connects and creates a session to the Microsoft Graph API.

## SYNTAX

### ClientSecret (Default)
```
Connect-odsc -TenantId <String> -ClientId <String> -ClientSecret <SecureString> [-Cloud <String>]
 [-AzureCloudInstance <Int32>] [-GraphEndpoint <String>]
 [<CommonParameters>]
```

### ClientCertificate
```
Connect-odsc -TenantId <String> -ClientId <String> -ClientCertificate <X509Certificate2> [-Cloud <String>]
 [-AzureCloudInstance <Int32>] [-GraphEndpoint <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The **Connect-odsc** function authenticates and creates a session to the Microsoft Graph API.

## EXAMPLES

### Example 1: Connect using a client secret
```powershell
PS C:\> Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientSecret (ConvertTo-SecureString -String "000000000000000000000000000" -AsPlainText -Force)
```

This command connects to the Microsoft Graph API using a client secret configured in the Azure AD application.

### Example 2: Connect using a client certificate
```powershell
PS C:\> Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate (Get-Item -Path 'Cert:\CurrentUser\My\0000000000000000000000000000000000000000')
```

This command connects to the Microsoft Graph API using a client certificate configured in the Azure AD application.

### Example 3: Connect to a US Government (GCC High) tenant
```powershell
PS C:\> Connect-odsc -TenantId "00000000-0000-0000-0000-000000000000" -ClientId "00000000-0000-0000-0000-000000000000" -ClientCertificate $Certificate -Cloud GCCHigh
```

This command connects to Microsoft Graph for US Government (https://graph.microsoft.us) using a client certificate.

## PARAMETERS

### -AzureCloudInstance
Species an integer that corresponds to an Azure Cloud Instance type (None = 0, AzurePublic = 1, AzureChina = 2, AzureGermany = 3, AzureUsGovernment = 4). When used without -Cloud, 2 selects the China Microsoft Graph endpoint and 4 the US Government (GCC High) endpoint. Prefer -Cloud.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -Cloud
Specifies the Microsoft cloud to connect to: Global (default), GCC, GCCHigh, DoD or China. It selects both the sign-in authority and the Microsoft Graph endpoint.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Global, GCC, GCCHigh, DoD, China

Required: False
Position: Named
Default value: Global
Accept pipeline input: False
Accept wildcard characters: False
```

### -GraphEndpoint
Overrides the Microsoft Graph endpoint, for example https://graph.microsoft.us. Use it only for custom or new national cloud endpoints.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES
Connection errors are always terminating: if the token request fails, the script stops unless the call is wrapped in try/catch.

## RELATED LINKS
