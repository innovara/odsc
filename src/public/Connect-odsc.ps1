function Connect-odsc {
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
        [ValidateSet('Global', 'GCC', 'GCCHigh', 'DoD', 'China')]
        [string] $Cloud = 'Global',

        [Parameter(Mandatory = $false, ParameterSetName = 'ClientSecret')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ClientCertificate')]
        [ValidateRange(0,4)]
        [int] $AzureCloudInstance = 1,

        [Parameter(Mandatory = $false, ParameterSetName = 'ClientSecret')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ClientCertificate')]
        [ValidatePattern('^https://')]
        [string] $GraphEndpoint
    )

    begin {

    }

    process {
        $CloudParameters = @{ Cloud = $Cloud }

        if ($PSBoundParameters.ContainsKey('AzureCloudInstance')) {
            if ($PSBoundParameters.ContainsKey('Cloud')) {
                $ExpectedAzureCloudInstance = switch ($Cloud) {
                    'China' { 2 }
                    'GCCHigh' { 4 }
                    'DoD' { 4 }
                    default { 1 }
                }

                if ($AzureCloudInstance -ne $ExpectedAzureCloudInstance) {
                    Write-Error "AzureCloudInstance '$AzureCloudInstance' does not match cloud '$Cloud'. Use -Cloud for endpoint selection or omit -AzureCloudInstance." -ErrorAction Stop
                }
            } else {
                $CloudParameters.Cloud = switch ($AzureCloudInstance) {
                    2 { 'China' }
                    4 { 'GCCHigh' }
                    default { 'Global' }
                }
            }

            $CloudParameters.AzureCloudInstance = $AzureCloudInstance
        }

        if ($GraphEndpoint) {
            $CloudParameters.GraphEndpoint = $GraphEndpoint
        }

        $CloudEnvironment = Resolve-odscCloudEnvironment @CloudParameters

        $TokenParameters = @{
            ClientId = $ClientId
            TenantId = $TenantId
            AzureCloudInstance = $CloudEnvironment.AzureCloudInstance
            Scopes = "$($CloudEnvironment.GraphEndpoint)/.default"
        }

        switch ($PsCmdlet.ParameterSetName) {
            'ClientSecret' {
                $TokenParameters.ClientSecret = $ClientSecret
            }
            'ClientCertificate' {
                $TokenParameters.ClientCertificate = $ClientCertificate
            }
        }

        try {
            $Token = Get-MsalToken @TokenParameters
            $script:ODSToken = $Token
            $script:ODSCloudEnvironment = $CloudEnvironment.Cloud
            $script:ODSGraphEndpoint = $CloudEnvironment.GraphEndpoint
        } catch {
            Write-Verbose $_
            Write-Error "Token request using $($PsCmdlet.ParameterSetName) failed for cloud '$($CloudEnvironment.Cloud)'." -ErrorAction Stop
        }
    }

    end {
        if ($Token) {
            Write-Verbose "Connected to $($script:ODSCloudEnvironment) using $($script:ODSGraphEndpoint)."
            Write-Host "Connected!"
        }
    }
}
