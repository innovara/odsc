function Resolve-odscDocumentLibraryFolder {
    [CmdletBinding()]
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
        [string] $FolderPath
    )

    try {
        $ListDrive = Invoke-odscApiRequest -Resource "sites/${SiteIdRaw}/lists/${DocumentLibraryId}/drive" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
    } catch {
        Stop-odscGraphError -ErrorRecord $_ `
            -NotFoundMessage "Unable to open the drive for document library '$DocumentLibraryName' in site '$Uri'. Verify the selected list is a document library." `
            -ForbiddenMessage "Unable to open the drive for document library '$DocumentLibraryName' in site '$Uri'. Microsoft Graph returned 403. Verify Files.Read.All/Files.ReadWrite.All or site permissions are granted." `
            -FallbackMessage "Unable to open the drive for document library '$DocumentLibraryName' in site '$Uri'."
    }

    $EncodedFolderPath = ConvertTo-odscGraphDrivePath -Path $FolderPath
    try {
        $DriveItem = Invoke-odscApiRequest -Resource "drives/$($ListDrive.id)/root:/${EncodedFolderPath}" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -DoNotUsePrefer -ErrorAction Stop
    } catch {
        Stop-odscGraphError -ErrorRecord $_ `
            -NotFoundMessage "Unable to find folder '$FolderPath' in document library '$DocumentLibraryName' on site '$Uri'. Verify the path is relative to the library root and does not include the library name." `
            -ForbiddenMessage "Unable to access folder '$FolderPath' in document library '$DocumentLibraryName' on site '$Uri'. Microsoft Graph returned 403. Verify permissions to the folder." `
            -FallbackMessage "Unable to resolve folder '$FolderPath' in document library '$DocumentLibraryName' on site '$Uri'."
    }

    if (!($DriveItem) -or [string]::IsNullOrWhiteSpace($DriveItem.id)) {
        Write-Error "Error retrieving document library folder '$FolderPath'. Microsoft Graph did not return a drive item id for the folder." -ErrorAction Stop
    }

    [pscustomobject]@{
        Drive = $ListDrive
        Item = $DriveItem
    }
}
