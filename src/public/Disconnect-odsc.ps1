function Disconnect-odsc {
    [CmdletBinding()]
    param()

    begin {

    }

    process {
        $script:ODSToken = $null
    }

    end {
        Write-Host "Disconnected."
    }
}
