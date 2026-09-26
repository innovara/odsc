function Disconnect-odsc {
    [CmdletBinding()]
    param()

    begin {

    }

    process {
        $script:ODSToken = $null
        $script:ODSCloudEnvironment = 'Global'
        $script:ODSGraphEndpoint = 'https://graph.microsoft.com'
    }

    end {
        Write-Host "Disconnected."
    }
}
