function Stop-odscGraphError {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord] $ErrorRecord,

        [Parameter(Mandatory = $false)]
        [string] $NotFoundMessage,

        [Parameter(Mandatory = $false)]
        [string] $ForbiddenMessage,

        [Parameter(Mandatory = $true)]
        [string] $FallbackMessage
    )

    $StatusCode = Get-odscGraphStatusCode -ErrorRecord $ErrorRecord
    if (($StatusCode -eq 404) -and $NotFoundMessage) {
        Write-Error $NotFoundMessage -ErrorAction Stop
    }

    if (($StatusCode -eq 403) -and $ForbiddenMessage) {
        Write-Error $ForbiddenMessage -ErrorAction Stop
    }

    Write-Error "$FallbackMessage $($ErrorRecord.Exception.Message)" -ErrorAction Stop
}
