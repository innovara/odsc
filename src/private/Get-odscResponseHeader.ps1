function Get-odscResponseHeader {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [object] $Response,

        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    # PowerShell 7 exposes an HttpResponseMessage, Windows PowerShell 5.1 an HttpWebResponse.
    try {
        if ($Response.PSObject.Methods['GetResponseHeader']) {
            return $Response.GetResponseHeader($Name)
        }

        $Values = $null
        if ($Response.Headers.TryGetValues($Name, [ref] $Values)) {
            return @($Values)[0]
        }

        return $null
    } catch {
        return $null
    }
}

function Get-odscRetryAfterDelay {
    [CmdletBinding()]
    [OutputType([int])]
    param(
        [Parameter(Mandatory = $true)]
        [object] $Response
    )

    $Value = Get-odscResponseHeader -Response $Response -Name 'Retry-After'
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    $Seconds = 0
    if ([int]::TryParse($Value, [ref] $Seconds)) {
        return [Math]::Max(0, [Math]::Min(300, $Seconds))
    }

    $Date = [DateTimeOffset]::MinValue
    if ([DateTimeOffset]::TryParse($Value, [ref] $Date)) {
        $Delta = [int][Math]::Ceiling(($Date - [DateTimeOffset]::UtcNow).TotalSeconds)
        return [Math]::Max(0, [Math]::Min(300, $Delta))
    }

    return $null
}
