function Resolve-odscCloudEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet('Global', 'GCC', 'GCCHigh', 'DoD', 'China')]
        [string] $Cloud = 'Global',

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [int] $AzureCloudInstance,

        [Parameter(Mandatory = $false)]
        [string] $GraphEndpoint
    )

    $CloudTable = @{
        Global = @{
            AzureCloudInstance = 1
            GraphEndpoint = 'https://graph.microsoft.com'
            Description = 'Microsoft Graph global service'
        }
        GCC = @{
            AzureCloudInstance = 1
            GraphEndpoint = 'https://graph.microsoft.com'
            Description = 'Microsoft 365 GCC using worldwide Microsoft Graph endpoints'
        }
        GCCHigh = @{
            AzureCloudInstance = 4
            GraphEndpoint = 'https://graph.microsoft.us'
            Description = 'Microsoft Graph for US Government L4 (GCC High)'
        }
        DoD = @{
            AzureCloudInstance = 4
            GraphEndpoint = 'https://dod-graph.microsoft.us'
            Description = 'Microsoft Graph for US Government L5 (DoD)'
        }
        China = @{
            AzureCloudInstance = 2
            GraphEndpoint = 'https://microsoftgraph.chinacloudapi.cn'
            Description = 'Microsoft Graph China operated by 21Vianet'
        }
    }

    $Resolved = $CloudTable[$Cloud]

    if ($PSBoundParameters.ContainsKey('AzureCloudInstance')) {
        $Resolved.AzureCloudInstance = $AzureCloudInstance

        if (-not $PSBoundParameters.ContainsKey('GraphEndpoint')) {
            switch ($AzureCloudInstance) {
                1 { $Resolved.GraphEndpoint = 'https://graph.microsoft.com' }
                2 { $Resolved.GraphEndpoint = 'https://microsoftgraph.chinacloudapi.cn' }
                4 { $Resolved.GraphEndpoint = 'https://graph.microsoft.us' }
            }
        }
    }

    if ($GraphEndpoint) {
        $Resolved.GraphEndpoint = $GraphEndpoint.TrimEnd('/')
    }

    [pscustomobject]@{
        Cloud = $Cloud
        AzureCloudInstance = $Resolved.AzureCloudInstance
        GraphEndpoint = $Resolved.GraphEndpoint.TrimEnd('/')
        Description = $Resolved.Description
    }
}
