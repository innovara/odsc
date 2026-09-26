function Test-odscPermission {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $false)]
        [string] $UserObjectId,

        [Parameter(Mandatory = $false)]
        [string] $GroupId,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibraryId,

        [Parameter(Mandatory = $false)]
        [string] $FolderPath
    )

    $Checks = New-Object System.Collections.Generic.List[object]

    # users?$top=1 only needs User.Read.All, which the module already requires.
    try {
        Invoke-odscApiRequest -Resource 'users?$top=1&$select=id' -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop | Out-Null
        $Checks.Add([pscustomobject]@{ Check = 'GraphConnection'; Status = 'Passed'; Message = 'Token can call Microsoft Graph and read users.' }) | Out-Null
    } catch {
        $StatusCode = Get-odscGraphStatusCode -ErrorRecord $_
        $Message = if ($StatusCode -eq 403) {
            'Microsoft Graph returned 403 while reading users. Grant admin consent for User.Read.All.'
        } else {
            $_.Exception.Message
        }
        $Checks.Add([pscustomobject]@{ Check = 'GraphConnection'; Status = 'Failed'; Message = $Message }) | Out-Null
    }

    if ($GroupId) {
        try {
            Invoke-odscApiRequest -Resource "groups/${GroupId}/transitiveMembers/microsoft.graph.user?`$select=id&`$top=1&`$count=true" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -Headers @{ ConsistencyLevel = 'eventual' } -ErrorAction Stop | Out-Null
            $Checks.Add([pscustomobject]@{ Check = 'GroupMemberAccess'; Status = 'Passed'; Message = "Can read transitive user members for group '$GroupId'." }) | Out-Null
        } catch {
            $StatusCode = Get-odscGraphStatusCode -ErrorRecord $_
            $Message = if ($StatusCode -eq 403) {
                "Microsoft Graph returned 403 while reading transitive user members for group '$GroupId'. Grant admin consent for GroupMember.Read.All, or use a broader equivalent such as Group.Read.All or Directory.Read.All. Hidden membership groups also require Member.Read.Hidden."
            } else {
                $_.Exception.Message
            }
            $Checks.Add([pscustomobject]@{ Check = 'GroupMemberAccess'; Status = 'Failed'; Message = $Message }) | Out-Null
        }
    }

    if ($UserPrincipalName -or $UserObjectId) {
        $User = if ($UserObjectId) { $UserObjectId } else { $UserPrincipalName }
        try {
            Resolve-odscOneDriveRoot -User $User | Out-Null
            $Checks.Add([pscustomobject]@{ Check = 'UserDriveAccess'; Status = 'Passed'; Message = "Can read OneDrive drive for '$User'." }) | Out-Null
        } catch {
            $Checks.Add([pscustomobject]@{ Check = 'UserDriveAccess'; Status = 'Failed'; Message = $_.Exception.Message }) | Out-Null
        }
    }

    if ($Uri) {
        try {
            Resolve-odscSharePointSite -Uri $Uri | Out-Null
            $Checks.Add([pscustomobject]@{ Check = 'SiteAccess'; Status = 'Passed'; Message = "Can read SharePoint site '$Uri'." }) | Out-Null
        } catch {
            $Checks.Add([pscustomobject]@{ Check = 'SiteAccess'; Status = 'Failed'; Message = $_.Exception.Message }) | Out-Null
        }
    }

    if ($Uri -and ($DocumentLibrary -or $DocumentLibraryId)) {
        try {
            $TargetParameters = @{
                Uri = $Uri
            }
            if ($DocumentLibrary) { $TargetParameters.DocumentLibrary = $DocumentLibrary }
            if ($DocumentLibraryId) { $TargetParameters.DocumentLibraryId = $DocumentLibraryId }
            if ($FolderPath) { $TargetParameters.FolderPath = $FolderPath }
            Resolve-odscShortcutTarget @TargetParameters | Out-Null
            $TargetName = if ($DocumentLibrary) { $DocumentLibrary } else { $DocumentLibraryId }
            $Checks.Add([pscustomobject]@{ Check = 'ShortcutTargetAccess'; Status = 'Passed'; Message = "Can resolve shortcut target '$TargetName'." }) | Out-Null
        } catch {
            $Checks.Add([pscustomobject]@{ Check = 'ShortcutTargetAccess'; Status = 'Failed'; Message = $_.Exception.Message }) | Out-Null
        }
    } elseif (($DocumentLibrary -or $DocumentLibraryId -or $FolderPath) -and (-not $Uri)) {
        $Checks.Add([pscustomobject]@{ Check = 'ShortcutTargetAccess'; Status = 'Failed'; Message = 'Specify -Uri with -DocumentLibrary, -DocumentLibraryId, or -FolderPath to validate a shortcut target.' }) | Out-Null
    }

    return $Checks.ToArray()
}
