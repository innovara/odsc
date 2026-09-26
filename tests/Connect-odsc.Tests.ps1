BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Connect-odsc' {
    BeforeEach {
        Mock Get-MsalToken -ModuleName odsc { [pscustomobject]@{ AccessToken = 'token'; ExpiresOn = (Get-Date).AddHours(1) } }
        Mock Write-Host -ModuleName odsc {}
        $Secret = ConvertTo-SecureString 'secret' -AsPlainText -Force
    }

    It 'defaults to the global cloud as before' {
        Connect-odsc -TenantId 't' -ClientId 'c' -ClientSecret $Secret
        Should -Invoke Get-MsalToken -ModuleName odsc -ParameterFilter { $AzureCloudInstance -eq 1 -and $Scopes -eq 'https://graph.microsoft.com/.default' }
        Should -Invoke Write-Host -ModuleName odsc -ParameterFilter { $Object -eq 'Connected!' }
        InModuleScope odsc { $script:ODSGraphEndpoint | Should -Be 'https://graph.microsoft.com' }
    }

    It 'uses the national cloud Graph endpoint for -Cloud' {
        Connect-odsc -TenantId 't' -ClientId 'c' -ClientSecret $Secret -Cloud DoD
        Should -Invoke Get-MsalToken -ModuleName odsc -ParameterFilter { $AzureCloudInstance -eq 4 -and $Scopes -eq 'https://dod-graph.microsoft.us/.default' }
        InModuleScope odsc { $script:ODSGraphEndpoint | Should -Be 'https://dod-graph.microsoft.us' }
    }

    It 'maps -AzureCloudInstance to the matching Graph endpoint' {
        Connect-odsc -TenantId 't' -ClientId 'c' -ClientSecret $Secret -AzureCloudInstance 2
        InModuleScope odsc { $script:ODSGraphEndpoint | Should -Be 'https://microsoftgraph.chinacloudapi.cn' }
    }

    It 'rejects a mismatched -Cloud and -AzureCloudInstance' {
        { Connect-odsc -TenantId 't' -ClientId 'c' -ClientSecret $Secret -Cloud China -AzureCloudInstance 1 } | Should -Throw '*does not match*'
    }

    It 'Disconnect-odsc resets the endpoint' {
        Connect-odsc -TenantId 't' -ClientId 'c' -ClientSecret $Secret -Cloud China
        Disconnect-odsc
        InModuleScope odsc {
            $script:ODSToken | Should -BeNullOrEmpty
            $script:ODSGraphEndpoint | Should -Be 'https://graph.microsoft.com'
        }
    }
}
