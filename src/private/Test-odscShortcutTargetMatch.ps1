function Test-odscShortcutTargetMatch {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [object] $Shortcut,

        [Parameter(Mandatory = $true)]
        [object] $Target
    )

    if (-not $Shortcut.remoteItem) {
        return $false
    }

    $ExistingIds = $Shortcut.remoteItem.sharepointIds
    $MatchesTargetSharePointIds = $Target.ItemUniqueId -and
        $ExistingIds -and
        ($ExistingIds.listId -eq $Target.DocumentLibraryId) -and
        ($ExistingIds.listItemUniqueId -eq $Target.ItemUniqueId) -and
        ($ExistingIds.siteId -eq $Target.SiteId) -and
        ($ExistingIds.webId -eq $Target.WebId)

    $MatchesTargetDriveItem = $Target.DriveId -and
        $Target.DriveItemId -and
        ($Shortcut.remoteItem.id -eq $Target.DriveItemId) -and
        ($Shortcut.remoteItem.parentReference.driveId -eq $Target.DriveId)

    return [bool]($MatchesTargetSharePointIds -or $MatchesTargetDriveItem)
}
