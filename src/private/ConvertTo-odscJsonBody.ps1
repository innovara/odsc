function ConvertTo-odscJsonBody {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object] $Body,

        [Parameter(Mandatory = $false)]
        [int] $Depth = 20
    )

    if ($null -eq $Body) {
        return $null
    }

    if ($Body -is [string]) {
        return $Body
    }

    return $Body | ConvertTo-Json -Depth $Depth
}
