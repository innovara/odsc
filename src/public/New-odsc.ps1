function New-odsc {
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
        [string] $UserObjectId
    )

    begin {

    }

    process {
        if (-not $DocumentLibrary -and -not $DocumentLibraryId) {
            Write-Error 'Specify -DocumentLibrary or -DocumentLibraryId.'
            return
        }

        switch ($PSCmdlet.ParameterSetName) {
            'UserPrincipalName' {
                $User = $UserPrincipalName
            }
            'UserObjectId' {
                $User = $UserObjectId
            }
        }

        try {
            $Target = Resolve-odscShortcutTarget -Uri $Uri -DocumentLibrary $DocumentLibrary -DocumentLibraryId $DocumentLibraryId -FolderPath $FolderPath
            $RemoteItem = New-odscRemoteItemReference -Target $Target -ShortcutName $ShortcutName
        } catch {
            Write-Error $_.Exception.Message
            return
        }

        $Name = if ($ShortcutName) { $ShortcutName } else { $Target.DefaultShortcutName }

        if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Creating shortcut '$($Name)'")) {
            try {
                return New-odscShortcutItem -User $User -RemoteItem $RemoteItem -ShortcutName $Name -RelativePath $RelativePath
            } catch {
                Write-Error "Error creating OneDrive Shortcut '$($Name)' for ${User}. $($_.Exception.Message)"
                return
            }
        } else {
            return
        }
    }

    end {

    }
}
