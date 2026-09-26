BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Invoke-odscApiRequest' {
    BeforeEach {
        InModuleScope odsc {
            $script:ODSToken = [pscustomobject]@{ AccessToken = 'token'; ExpiresOn = (Get-Date).AddHours(1) }
            $script:ODSGraphEndpoint = 'https://graph.microsoft.com'
        }
    }

    It 'requires a connection' {
        InModuleScope odsc {
            $script:ODSToken = $null
            { Invoke-odscApiRequest -Resource 'me' -Method Get } | Should -Throw 'Please run Connect-odsc first.'
        }
    }

    It 'uses the connected cloud Graph endpoint and serialises object bodies' {
        InModuleScope odsc {
            $script:ODSGraphEndpoint = 'https://graph.microsoft.us'
            Mock Invoke-WebRequest { [pscustomobject]@{ Content = '{"id":"1"}' } }

            (Invoke-odscApiRequest -Resource 'users/u/drive' -Method Post -Body @{ remoteItem = @{ sharepointIds = @{ listId = 'l' } } }).id | Should -Be '1'

            Should -Invoke Invoke-WebRequest -ParameterFilter {
                $Uri -eq 'https://graph.microsoft.us/v1.0/users/u/drive' -and
                ($Body | ConvertFrom-Json).remoteItem.sharepointIds.listId -eq 'l' -and
                $Headers.Prefer -eq 'apiversion=2.1'
            }
        }
    }

    It 'returns $null for an empty response body' {
        InModuleScope odsc {
            Mock Invoke-WebRequest { [pscustomobject]@{ Content = '' } }
            Invoke-odscApiRequest -Resource 'x' -Method Delete | Should -BeNullOrEmpty
        }
    }

    It 'follows nextLink when -AllPages is used' {
        InModuleScope odsc {
            Mock Invoke-WebRequest { [pscustomobject]@{ Content = '{"value":[{"id":"1"}],"@odata.nextLink":"https://graph.microsoft.com/v1.0/next"}' } } -ParameterFilter { $Uri -like '*/users' }
            Mock Invoke-WebRequest { [pscustomobject]@{ Content = '{"value":[{"id":"2"}]}' } } -ParameterFilter { $Uri -like '*/next' }

            (Invoke-odscApiRequest -Resource 'users' -Method Get -AllPages).id | Should -Be @('1', '2')
        }
    }

    It 'retries throttled requests and reports the final failure with its status code' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope odsc {
            Mock Start-Sleep {}
            Mock Invoke-WebRequest {
                $Response = [System.Net.Http.HttpResponseMessage]::new(429)
                $Response.Headers.Add('Retry-After', '1')
                throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Too many requests', $Response)
            }

            { Invoke-odscApiRequest -Resource 'x' -Method Get -MaxRetryCount 2 } | Should -Throw '*StatusCode: 429*'
            Should -Invoke Invoke-WebRequest -Times 3 -Exactly
            Should -Invoke Start-Sleep -Times 2 -Exactly -ParameterFilter { $Seconds -eq 1 }
        }
    }

    It 'does not retry client errors' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope odsc {
            Mock Start-Sleep {}
            Mock Invoke-WebRequest {
                throw [Microsoft.PowerShell.Commands.HttpResponseException]::new('Not found', [System.Net.Http.HttpResponseMessage]::new(404))
            }

            { Invoke-odscApiRequest -Resource 'x' -Method Get } | Should -Throw '*StatusCode: 404*'
            Should -Invoke Invoke-WebRequest -Times 1 -Exactly
        }
    }
}
