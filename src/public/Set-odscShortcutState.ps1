function Set-odscShortcutState {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $Uri,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $DocumentLibraryId,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $FolderPath,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $RelativePath,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $ShortcutName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName', ValueFromPipelineByPropertyName = $true)]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId', ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
        [string] $UserObjectId,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [string] $State = 'Present',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Skip', 'Replace', 'Rename', 'Error')]
        [string] $ConflictAction = 'Skip',

        [Parameter(Mandatory = $false)]
        [switch] $PassThru
    )

    process {
        try {
            if (-not $DocumentLibrary -and -not $DocumentLibraryId) {
                Write-Error 'Specify -DocumentLibrary or -DocumentLibraryId.' -ErrorAction Stop
            }

            $User = switch ($PsCmdlet.ParameterSetName) {
                'UserPrincipalName' { $UserPrincipalName }
                'UserObjectId' { $UserObjectId }
            }

            $Target = Resolve-odscShortcutTarget -Uri $Uri -DocumentLibrary $DocumentLibrary -DocumentLibraryId $DocumentLibraryId -FolderPath $FolderPath
            if (-not $ShortcutName) {
                $ShortcutName = $Target.DefaultShortcutName
            }

            $ResultParameters = @{
                User = $User
                TargetSite = $Uri
                TargetLibrary = if ($DocumentLibrary) { $DocumentLibrary } else { $Target.DocumentLibraryName }
                TargetFolderPath = $FolderPath
            }

            $ShortcutResource = Join-odscDrivePathResource -User $User -RelativePath $RelativePath -Name $ShortcutName
            $ExistingShortcut = $null
            try {
                $ExistingShortcut = Invoke-odscApiRequest -Resource $ShortcutResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
            } catch {
                $StatusCode = Get-odscGraphStatusCode -ErrorRecord $_
                if ($StatusCode -eq 404) {
                    $ExistingShortcut = $null
                } elseif ($StatusCode -eq 403) {
                    Write-Error "Unable to check for existing shortcut '$ShortcutName' for '$User'. Microsoft Graph returned 403 for $ShortcutResource. Verify permission to read the user's OneDrive." -ErrorAction Stop
                } else {
                    Write-Error "Unable to check for existing shortcut '$ShortcutName' for '$User'. $($_.Exception.Message)" -ErrorAction Stop
                }
            }

            $MatchesTarget = $ExistingShortcut -and (Test-odscShortcutTargetMatch -Shortcut $ExistingShortcut -Target $Target)

            if ($State -eq 'Absent') {
                if (-not $ExistingShortcut) {
                    return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'Remove' -Status 'AlreadyAbsent' -Message 'Shortcut was already absent.'
                }

                if (-not $ExistingShortcut.remoteItem) {
                    Write-Error "Existing item '$ShortcutName' for '$User' is not a OneDrive shortcut." -ErrorAction Stop
                }

                # Only remove the shortcut when it points to the requested target.
                if (-not $MatchesTarget) {
                    return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'None' -Status 'SkippedConflict' -Response $ExistingShortcut -Message 'A shortcut with the requested name exists but points to a different target. It was not removed.'
                }

                if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Removing shortcut '$ShortcutName'")) {
                    Invoke-odscApiRequest -Resource $ShortcutResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) -ErrorAction Stop | Out-Null
                    return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'Remove' -Status 'Removed' -Response $ExistingShortcut
                }

                return
            }

            if ($ExistingShortcut) {
                if ($MatchesTarget) {
                    if ($PassThru) {
                        return $ExistingShortcut
                    }

                    return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'None' -Status 'Compliant' -Response $ExistingShortcut -Message 'Shortcut already points to the requested target.'
                }

                switch ($ConflictAction) {
                    'Skip' {
                        return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'None' -Status 'SkippedConflict' -Response $ExistingShortcut -Message 'An item with the requested shortcut name already exists.'
                    }
                    'Error' {
                        Write-Error "An item named '$ShortcutName' already exists for '$User' and does not match the requested target." -ErrorAction Stop
                    }
                    'Replace' {
                        # Never delete a real file or folder, only a shortcut pointing somewhere else.
                        if (-not $ExistingShortcut.remoteItem) {
                            Write-Error "An item named '$ShortcutName' already exists for '$User' and is not a OneDrive shortcut. It will not be replaced." -ErrorAction Stop
                        }

                        if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Replacing shortcut '$ShortcutName'")) {
                            Invoke-odscApiRequest -Resource $ShortcutResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) -ErrorAction Stop | Out-Null
                        } else {
                            return
                        }
                    }
                    'Rename' {
                        $ShortcutName = "$ShortcutName-$([DateTime]::UtcNow.ToString('yyyyMMddHHmmss'))"
                    }
                }
            }

            if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Creating shortcut '$ShortcutName'")) {
                Resolve-odscOneDriveRoot -User $User | Out-Null

                $RemoteItem = New-odscRemoteItemReference -Target $Target -ShortcutName $ShortcutName
                try {
                    $ShortcutResponse = New-odscShortcutItem -User $User -RemoteItem $RemoteItem -ShortcutName $ShortcutName -RelativePath $RelativePath
                } catch {
                    # The shortcut exists under another name or at the root: report it rather than fail.
                    if ($_.FullyQualifiedErrorId -notlike 'odscShortcutNotRenamed*') {
                        throw
                    }

                    if ($PassThru) {
                        Write-Warning $_.Exception.Message
                        return $_.TargetObject
                    }

                    return Write-odscResult @ResultParameters -ShortcutName $_.TargetObject.name -Action 'Create' -Status 'RenameFailed' -Response $_.TargetObject -Message $_.Exception.Message
                }

                if ($PassThru) {
                    return $ShortcutResponse
                }

                return Write-odscResult @ResultParameters -ShortcutName $ShortcutName -Action 'Create' -Status 'Created' -Response $ShortcutResponse
            }
        } catch {
            # Non-terminating by default, like the other commands; use -ErrorAction Stop to stop instead.
            Write-Error $_.Exception.Message
        }
    }
}
