function New-odscShortcutItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $User,

        [Parameter(Mandatory = $true)]
        [hashtable] $RemoteItem,

        [Parameter(Mandatory = $true)]
        [string] $ShortcutName,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $RelativePath
    )

    # Resolve (and create) the destination folder first so a failure there does not leave a shortcut behind.
    $DestinationFolder = $null
    if (-not [string]::IsNullOrWhiteSpace($RelativePath)) {
        $DestinationFolder = Resolve-odscDriveFolderPath -User $User -RelativePath $RelativePath -Create
    }

    # Shortcuts are created at the OneDrive root, moved to the destination folder and then renamed,
    # because the root may already hold an item with the same name as the one in the destination.
    $CreateRequest = @{
        Resource = "users/${User}/drive/root/children"
        Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Post
        Body = @{
            name = $ShortcutName
            remoteItem = $RemoteItem
            '@microsoft.graph.conflictBehavior' = 'rename'
        }
    }

    try {
        $ShortcutResponse = Invoke-odscApiRequest @CreateRequest -ErrorAction Stop
    } catch {
        # Name clashes are renamed by Graph, so a conflict here means OneDrive already has a shortcut to this target.
        if ((Get-odscGraphStatusCode -ErrorRecord $_) -eq 409) {
            Write-Error "${User}'s OneDrive already has a shortcut to this target, possibly with another name or in another folder. OneDrive allows only one shortcut per target. $($_.Exception.Message)" -ErrorAction Stop
        }

        throw
    }

    if (!($ShortcutResponse) -or [string]::IsNullOrWhiteSpace($ShortcutResponse.id)) {
        Write-Error "Error creating OneDrive shortcut '$ShortcutName' for ${User}. Microsoft Graph did not return an item id." -ErrorAction Stop
    }

    $ItemResource = Join-odscDriveItemResource -User $User -ItemId $ShortcutResponse.id

    # From here on the shortcut exists. Graph may have given it another name (on a clash, '<site> - <name>').
    # If it cannot be moved or renamed it is kept, so the user keeps access, and the error names it so an
    # administrator can sort it out. Callers can recognise this error by its id and read the shortcut from TargetObject.
    if ($DestinationFolder) {
        $MoveRequest = @{
            Resource = $ItemResource
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Patch
            DoNotUsePrefer = $true
            Body = @{
                parentReference = @{
                    id = $DestinationFolder.id
                }
            }
        }

        try {
            Invoke-odscApiRequest @MoveRequest -ErrorAction Stop | Out-Null
        } catch {
            Write-Error -ErrorId 'odscShortcutNotRenamed' -TargetObject $ShortcutResponse -ErrorAction Stop -Message (
                "The shortcut was created as '$($ShortcutResponse.name)' at the root of ${User}'s OneDrive but could not be moved to '$RelativePath'. " +
                "Move and rename it to '$ShortcutName' by hand. $($_.Exception.Message)")
        }
    }

    $RenameRequest = @{
        Resource = $ItemResource
        Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Patch
        Body = @{
            name = $ShortcutName
        }
    }

    try {
        return Invoke-odscApiRequest @RenameRequest -ErrorAction Stop
    } catch {
        $Location = if ($DestinationFolder) { "'$RelativePath'" } else { 'the root' }
        $Reason = if ((Get-odscGraphStatusCode -ErrorRecord $_) -eq 409) {
            "because the name '$ShortcutName' is already used by another item there. Rename that item, then rename the shortcut to '$ShortcutName'."
        } else {
            "because it could not be renamed to '$ShortcutName'."
        }

        Write-Error -ErrorId 'odscShortcutNotRenamed' -TargetObject $ShortcutResponse -ErrorAction Stop -Message (
            "The shortcut was created as '$($ShortcutResponse.name)' in $Location of ${User}'s OneDrive $Reason $($_.Exception.Message)")
    }
}
