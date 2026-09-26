function Join-odscDriveItemResource {
    [CmdletBinding(DefaultParameterSetName = 'ByUser')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'ByUser')]
        [string] $User,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByDrive')]
        [string] $DriveId,

        [Parameter(Mandatory = $true)]
        [string] $ItemId,

        [Parameter(Mandatory = $false)]
        [switch] $Children
    )

    $Resource = if ($PSCmdlet.ParameterSetName -eq 'ByDrive') {
        "drives/${DriveId}/items/${ItemId}"
    } else {
        "users/${User}/drive/items/${ItemId}"
    }

    if ($Children) {
        return "$Resource/children"
    }

    return $Resource
}
