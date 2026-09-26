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
    # A shortcut to a library is created with listItemUniqueId 'root', but Graph reports the root folder's
    # real unique id and a 'root' facet, so the library root is matched by that facet instead.
    $MatchesItem = if ($Target.ItemUniqueId -eq 'root') {
        $null -ne $Shortcut.remoteItem.root
    } else {
        $ExistingIds.listItemUniqueId -eq $Target.ItemUniqueId
    }
    $MatchesTargetSharePointIds = $Target.ItemUniqueId -and
        $ExistingIds -and
        ($ExistingIds.listId -eq $Target.DocumentLibraryId) -and
        $MatchesItem -and
        ($ExistingIds.siteId -eq $Target.SiteId) -and
        ($ExistingIds.webId -eq $Target.WebId)

    $MatchesTargetDriveItem = $Target.DriveId -and
        $Target.DriveItemId -and
        ($Shortcut.remoteItem.id -eq $Target.DriveItemId) -and
        ($Shortcut.remoteItem.parentReference.driveId -eq $Target.DriveId)

    return [bool]($MatchesTargetSharePointIds -or $MatchesTargetDriveItem)
}
