function ConvertTo-odscGraphDrivePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ''
    }

    # Encode each segment separately so that '/' stays a path separator.
    $Segments = $Path -split '/+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    return (($Segments | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/')
}
