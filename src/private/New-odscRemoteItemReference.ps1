function New-odscRemoteItemReference {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [object] $Target,

        [Parameter(Mandatory = $false)]
        [string] $ShortcutName
    )

    if ($Target.ItemUniqueId) {
        return @{
            sharepointIds = @{
                listId = $Target.DocumentLibraryId
                listItemUniqueId = $Target.ItemUniqueId
                siteId = $Target.SiteId
                siteUrl = $Target.SiteUrl
                webId = $Target.WebId
            }
        }
    }

    if ($Target.DriveId -and $Target.DriveItemId) {
        return @{
            id = $Target.DriveItemId
            parentReference = @{
                driveId = $Target.DriveId
            }
        }
    }

    $TargetName = if ([string]::IsNullOrWhiteSpace($ShortcutName)) { 'shortcut' } else { $ShortcutName }
    Write-Error "Unable to build shortcut target reference for '$TargetName'. Microsoft Graph did not return SharePoint ids or a drive item reference for the target." -ErrorAction Stop
}
