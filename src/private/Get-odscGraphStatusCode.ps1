function Get-odscGraphStatusCode {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord] $ErrorRecord
    )

    if ($ErrorRecord.Exception.Response) {
        try {
            return [int]$ErrorRecord.Exception.Response.StatusCode
        } catch {
            # Fall through to message parsing for errors re-thrown by Invoke-odscApiRequest.
        }
    }

    $Message = $ErrorRecord.Exception.Message
    if ($Message -match 'StatusCode:\s*(\d+)') {
        return [int]$Matches[1]
    }

    return $null
}
