function Get-odscListItemUniqueIdFromResponse {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [object] $ListItem
    )

    if (-not $ListItem) {
        return $null
    }

    if ($ListItem.sharepointIds -and (-not [string]::IsNullOrWhiteSpace($ListItem.sharepointIds.listItemUniqueId))) {
        return $ListItem.sharepointIds.listItemUniqueId
    }

    if ($ListItem.fields -and (-not [string]::IsNullOrWhiteSpace($ListItem.fields.UniqueId))) {
        return $ListItem.fields.UniqueId
    }

    $Etag = if ($ListItem.eTag) { $ListItem.eTag } else { $ListItem.'@odata.etag' }
    if (-not [string]::IsNullOrWhiteSpace($Etag)) {
        $Match = [regex]::Match($Etag, '[\da-fA-F]{8}-(?:[\da-fA-F]{4}-){3}[\da-fA-F]{12}')
        if ($Match.Success) {
            return $Match.Value
        }
    }

    return $null
}

function Resolve-odscListItemUniqueId {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SiteIdRaw,

        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $true)]
        [string] $DocumentLibraryId,

        [Parameter(Mandatory = $true)]
        [string] $DocumentLibraryName,

        [Parameter(Mandatory = $true)]
        [string] $FolderPath,

        [Parameter(Mandatory = $false)]
        [string] $DriveId,

        [Parameter(Mandatory = $false)]
        [string] $DriveItemId,

        [Parameter(Mandatory = $false)]
        [string] $DriveItemWebUrl
    )

    if ((-not [string]::IsNullOrWhiteSpace($DriveId)) -and (-not [string]::IsNullOrWhiteSpace($DriveItemId))) {
        try {
            $ListItem = Invoke-odscApiRequest -Resource "drives/${DriveId}/items/${DriveItemId}/listItem" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -DoNotUsePrefer -ErrorAction Stop
            $UniqueId = Get-odscListItemUniqueIdFromResponse -ListItem $ListItem
            if ($UniqueId) {
                return $UniqueId
            }
        } catch {
            Write-Verbose "Unable to retrieve the SharePoint list item relationship for folder '$FolderPath'. Falling back to lookup by web URL."
        }
    }

    $CandidateUrls = [System.Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace($DriveItemWebUrl)) {
        $CandidateUrls.Add($DriveItemWebUrl) | Out-Null
    }

    $SiteUrl = $Uri.TrimEnd('/')
    $RelativeUrl = (@($DocumentLibraryName, $FolderPath) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join '/'
    if (-not [string]::IsNullOrWhiteSpace($RelativeUrl)) {
        $CandidateUrls.Add("$SiteUrl/$RelativeUrl") | Out-Null
    }

    foreach ($CandidateUrl in ($CandidateUrls.ToArray() | Select-Object -Unique)) {
        $EscapedCandidateUrl = $CandidateUrl.Replace("'", "''")
        foreach ($Filter in @("webUrl eq '${EscapedCandidateUrl}'", "contains(webUrl,'${EscapedCandidateUrl}')")) {
            try {
                $ListItems = @(Invoke-odscApiRequest -Resource "sites/${SiteIdRaw}/lists/${DocumentLibraryId}/items?`$expand=fields&`$filter=${Filter}" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -AllPages -ErrorAction Stop)
                foreach ($ListItem in $ListItems) {
                    $UniqueId = Get-odscListItemUniqueIdFromResponse -ListItem $ListItem
                    if ($UniqueId) {
                        return $UniqueId
                    }
                }
            } catch {
                Write-Verbose "Unable to retrieve the SharePoint list item for folder '$FolderPath' by web URL '$CandidateUrl'."
            }
        }
    }

    return $null
}

function Resolve-odscShortcutTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibraryId,

        [Parameter(Mandatory = $false)]
        [string] $FolderPath
    )

    $Site = Resolve-odscSharePointSite -Uri $Uri
    $DocumentLibraryResponse = Resolve-odscDocumentLibrary -SiteIdRaw $Site.SiteIdRaw -Uri $Uri -DocumentLibrary $DocumentLibrary -DocumentLibraryId $DocumentLibraryId

    $ResolvedLibraryId = $DocumentLibraryResponse.id
    $ResolvedLibraryName = if ($DocumentLibraryResponse.name) { $DocumentLibraryResponse.name } else { $DocumentLibraryResponse.displayName }
    $ResolvedShortcutName = if ($DocumentLibrary) { $DocumentLibrary } else { $DocumentLibraryResponse.displayName }
    $ItemUniqueId = 'root'
    $ItemUniqueName = $null
    $TargetDriveId = $null
    $TargetDriveItemId = $null

    if ($FolderPath) {
        $Folder = Resolve-odscDocumentLibraryFolder -SiteIdRaw $Site.SiteIdRaw -Uri $Uri -DocumentLibraryId $ResolvedLibraryId -DocumentLibraryName $ResolvedLibraryName -FolderPath $FolderPath
        $DriveItem = $Folder.Item

        if ($DriveItem.sharepointIds -and (-not [string]::IsNullOrWhiteSpace($DriveItem.sharepointIds.listItemUniqueId))) {
            $ItemUniqueId = $DriveItem.sharepointIds.listItemUniqueId
        } else {
            $ItemUniqueId = Resolve-odscListItemUniqueId `
                -SiteIdRaw $Site.SiteIdRaw `
                -Uri $Uri `
                -DocumentLibraryId $ResolvedLibraryId `
                -DocumentLibraryName $ResolvedLibraryName `
                -FolderPath $FolderPath `
                -DriveId $Folder.Drive.id `
                -DriveItemId $DriveItem.id `
                -DriveItemWebUrl $DriveItem.webUrl

            if ($ItemUniqueId) {
                Write-Verbose "Resolved SharePoint list item unique id for folder '$FolderPath' from the document library list item."
            } else {
                Write-Verbose "Microsoft Graph did not return SharePoint ids for folder '$FolderPath' and the list item unique id could not be recovered. Falling back to the drive item reference."
            }
        }

        $TargetDriveId = $Folder.Drive.id
        $TargetDriveItemId = $DriveItem.id
        $ItemUniqueName = $DriveItem.name
        $ResolvedShortcutName = $ItemUniqueName
    }

    [pscustomobject]@{
        SiteIdRaw = $Site.SiteIdRaw
        SiteId = $Site.SiteId
        WebId = $Site.WebId
        SiteUrl = $Uri
        DocumentLibraryId = $ResolvedLibraryId
        DocumentLibraryName = $ResolvedLibraryName
        DefaultShortcutName = $ResolvedShortcutName
        ItemUniqueId = $ItemUniqueId
        ItemUniqueName = $ItemUniqueName
        DriveId = $TargetDriveId
        DriveItemId = $TargetDriveItemId
    }
}
