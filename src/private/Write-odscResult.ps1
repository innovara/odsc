function Write-odscResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $User,

        [Parameter(Mandatory = $true)]
        [string] $ShortcutName,

        [Parameter(Mandatory = $true)]
        [string] $Action,

        [Parameter(Mandatory = $true)]
        [string] $Status,

        [Parameter(Mandatory = $false)]
        [object] $Response,

        [Parameter(Mandatory = $false)]
        [string] $Message,

        [Parameter(Mandatory = $false)]
        [string] $TargetSite,

        [Parameter(Mandatory = $false)]
        [string] $TargetLibrary,

        [Parameter(Mandatory = $false)]
        [string] $TargetFolderPath
    )

    [pscustomobject]@{
        PSTypeName = 'odsc.ShortcutResult'
        User = $User
        ShortcutName = $ShortcutName
        Action = $Action
        Status = $Status
        TargetSite = $TargetSite
        TargetLibrary = $TargetLibrary
        TargetFolderPath = $TargetFolderPath
        DriveItemId = $Response.id
        WebUrl = $Response.webUrl
        Message = $Message
        Response = $Response
        Timestamp = (Get-Date).ToUniversalTime()
    }
}
