function Resolve-odscOneDriveRoot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $User
    )

    try {
        return Invoke-odscApiRequest -Resource "users/${User}/drive/root" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
    } catch {
        Stop-odscGraphError -ErrorRecord $_ `
            -NotFoundMessage "Unable to access OneDrive for '$User'. Microsoft Graph returned 404 for users/${User}/drive/root. Verify the user identifier is correct, the user's OneDrive is provisioned, and the account has a SharePoint/OneDrive license. If the UPN recently changed, try -UserObjectId instead of -UserPrincipalName." `
            -ForbiddenMessage "Unable to access OneDrive for '$User'. Microsoft Graph returned 403 for users/${User}/drive/root. Verify the application has Files.ReadWrite.All and User.Read.All application permissions, and that admin consent has been granted." `
            -FallbackMessage "Unable to access OneDrive for '$User'."
    }
}
