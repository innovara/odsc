function Resolve-odscDocumentLibrary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SiteIdRaw,

        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibraryId
    )

    # Only libraries can be shortcut targets. The template is missing when Graph does not return it,
    # in which case the list is accepted as before.
    $IsLibrary = {
        param($List)
        $Template = $List.list.template
        [string]::IsNullOrWhiteSpace($Template) -or ($Template -match 'Library$')
    }
    $Select = '$select=id,name,displayName,webUrl,list'

    if ($DocumentLibraryId) {
        try {
            $DocumentLibraryResponse = Invoke-odscApiRequest -Resource "sites/${SiteIdRaw}/lists/${DocumentLibraryId}?$Select" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
        } catch {
            Stop-odscGraphError -ErrorRecord $_ `
                -NotFoundMessage "Unable to find document library id '$DocumentLibraryId' in site '$Uri'. Verify the library id belongs to that site." `
                -ForbiddenMessage "Unable to access document library id '$DocumentLibraryId' in site '$Uri'. Verify Graph has permission to read lists in the site." `
                -FallbackMessage "Unable to resolve document library id '$DocumentLibraryId' in site '$Uri'."
        }

        if ($DocumentLibraryResponse -and -not (& $IsLibrary $DocumentLibraryResponse)) {
            Write-Error "SharePoint list '$($DocumentLibraryResponse.displayName)' ($DocumentLibraryId) is a '$($DocumentLibraryResponse.list.template)' list, not a document library. OneDrive shortcuts can only point to document libraries." -ErrorAction Stop
        }
    } else {
        $EscapedLibrary = $DocumentLibrary.Replace("'", "''")
        try {
            # Prefer an exact display name match, then fall back to the prefix match used by earlier versions.
            $ListMatches = @(Invoke-odscApiRequest -Resource "sites/${SiteIdRaw}/lists?`$filter=displayName eq '${EscapedLibrary}'&$Select" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -AllPages -ErrorAction Stop)
            $LibraryMatches = @($ListMatches | Where-Object { & $IsLibrary $_ })

            if ($LibraryMatches.Count -eq 0) {
                $ListMatches += @(Invoke-odscApiRequest -Resource "sites/${SiteIdRaw}/lists?`$filter=startsWith(displayName,'${EscapedLibrary}')&$Select" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -AllPages -ErrorAction Stop)
                $LibraryMatches = @($ListMatches | Where-Object { & $IsLibrary $_ })

                if ($LibraryMatches.Count -gt 1) {
                    $Names = ($LibraryMatches | ForEach-Object { $_.displayName }) -join ', '
                    Write-Warning "Document library name '$DocumentLibrary' matched multiple libraries: $Names. Using '$($LibraryMatches[0].displayName)'. Specify the exact name or -DocumentLibraryId to avoid ambiguity."
                }
            }
        } catch {
            Stop-odscGraphError -ErrorRecord $_ `
                -ForbiddenMessage "Unable to search document libraries in site '$Uri'. Microsoft Graph returned 403. Verify Graph has permission to read lists in the site." `
                -FallbackMessage "Unable to search document libraries in site '$Uri'."
        }

        if ($LibraryMatches.Count -eq 0) {
            if ($ListMatches.Count -gt 0) {
                $Names = ($ListMatches | Sort-Object -Property id -Unique | ForEach-Object { "'$($_.displayName)' ($($_.list.template))" }) -join ', '
                Write-Error "Document library name '$DocumentLibrary' in '$Uri' only matched SharePoint lists that are not document libraries: $Names. OneDrive shortcuts can only point to document libraries." -ErrorAction Stop
            }

            Write-Error "Error retrieving SharePoint document library '$DocumentLibrary' from '$Uri'. Verify the library display name, or specify -DocumentLibraryId." -ErrorAction Stop
        }

        $DocumentLibraryResponse = $LibraryMatches[0]
    }

    if (!($DocumentLibraryResponse) -or [string]::IsNullOrWhiteSpace($DocumentLibraryResponse.id)) {
        Write-Error 'Error retrieving SharePoint document library. Microsoft Graph did not return a list id.' -ErrorAction Stop
    }

    return $DocumentLibraryResponse
}
