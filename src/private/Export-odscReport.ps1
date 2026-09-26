function Export-odscReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]] $InputObject,

        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Csv', 'Json', 'Clixml')]
        [string] $Format = 'Csv'
    )

    switch ($Format) {
        'Csv' { $InputObject | Export-Csv -Path $Path -NoTypeInformation }
        'Json' { $InputObject | ConvertTo-Json -Depth 20 | Set-Content -Path $Path -Encoding UTF8 }
        'Clixml' { $InputObject | Export-Clixml -Path $Path }
    }
}
