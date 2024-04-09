function Connect-ODS {
    [CmdletBinding(DefaultParameterSetName = 'ClientSecret')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ClientCertificate')]
        [string] $TenantId,
    
        [Parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [Parameter(Mandatory = $true, ParameterSetName = 'ClientCertificate')]
        [string] $ClientId,
    
        [Parameter(Mandatory = $true, ParameterSetName = 'ClientSecret')]
        [securestring] $ClientSecret,

        [Parameter(Mandatory = $true, ParameterSetName = 'ClientCertificate')]
        [System.Security.Cryptography.X509Certificates.X509Certificate2] $ClientCertificate,

        [Parameter(Mandatory = $false, ParameterSetName = 'ClientSecret')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ClientCertificate')]
        [ValidateRange(0,4)]
        [int] $AzureCloudInstance = 1
    )

    begin {
        $Token = $null
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'ClientSecret' {
                try {
                    $Token = Get-MsalToken -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret -AzureCloudInstance $AzureCloudInstance
                    $PsCmdlet.SessionState.PSVariable.Set('_ODSToken', $Token)
                } catch {
                    Write-Verbose $_
                    Write-Error "Token request using ClientSecret failed." -ErrorAction Stop
                }
            }
            'ClientCertificate' {
                try {
                    $Token = Get-MsalToken -ClientId $ClientId -TenantId $TenantId -ClientCertificate $ClientCertificate -AzureCloudInstance $AzureCloudInstance
                    $PsCmdlet.SessionState.PSVariable.Set('_ODSToken', $Token)
                } catch {
                    Write-Verbose $_
                    Write-Error "Token request using ClientCertificate failed." -ErrorAction Stop
                }
            }
        }
    }

    end {
        if ($Token) {
            Write-Host "Connected!"
        }
    }
}