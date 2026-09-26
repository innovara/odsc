function Resolve-odscSharePointSite {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Uri
    )

    try {
        $SiteUri = [uri]$Uri
    } catch {
        Write-Error "SharePoint site URI '$Uri' is not a valid URI. Specify the full https:// tenant SharePoint site URL." -ErrorAction Stop
    }

    if ((-not $SiteUri.IsAbsoluteUri) -or ($SiteUri.Scheme -ne 'https') -or [string]::IsNullOrWhiteSpace($SiteUri.Authority)) {
        Write-Error "SharePoint site URI '$Uri' is not valid. Specify the full https:// tenant SharePoint site URL." -ErrorAction Stop
    }

    # The tenant root site is addressed as sites/{hostname}; any other site as sites/{hostname}:/{path}.
    $SitePath = $SiteUri.AbsolutePath.TrimEnd('/')
    $SiteLookupResource = if ($SitePath) { "sites/$($SiteUri.Authority):${SitePath}" } else { "sites/$($SiteUri.Authority)" }

    try {
        $SiteResponse = Invoke-odscApiRequest -Resource $SiteLookupResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
    } catch {
        Stop-odscGraphError -ErrorRecord $_ `
            -NotFoundMessage "Unable to find SharePoint site '$Uri'. Microsoft Graph returned 404 for $SiteLookupResource. Verify the tenant host and site path are correct, and use the site URL rather than a document library or folder URL." `
            -ForbiddenMessage "Unable to access SharePoint site '$Uri'. Microsoft Graph returned 403 for $SiteLookupResource. Verify the application has Sites.Read.All/Sites.ReadWrite.All or equivalent permissions and access to the site." `
            -FallbackMessage "Unable to resolve SharePoint site '$Uri'."
    }

    if (!($SiteResponse) -or [string]::IsNullOrWhiteSpace($SiteResponse.id)) {
        Write-Error "Error retrieving SharePoint site '$Uri'. Microsoft Graph did not return a site id." -ErrorAction Stop
    }

    $SiteIdSplit = $SiteResponse.id.Split(',')
    if ($SiteIdSplit.Count -lt 3) {
        Write-Error "Error retrieving SharePoint site '$Uri'. Microsoft Graph returned an unexpected site id '$($SiteResponse.id)'." -ErrorAction Stop
    }

    [pscustomobject]@{
        Raw = $SiteResponse
        SiteIdRaw = $SiteResponse.id
        SiteId = $SiteIdSplit[1]
        WebId = $SiteIdSplit[2]
    }
}
