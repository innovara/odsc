function Remove-odsc {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $RelativePath,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $ShortcutName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName', ValueFromPipelineByPropertyName = $true)]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId', ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
        [string] $UserObjectId,

        [Parameter(Mandatory = $false)]
        [switch] $PassThru
    )

    begin {

    }

    process {
        $User = $null

        switch ($PsCmdlet.ParameterSetName) {
            "UserPrincipalName" {
                $User = $UserPrincipalName
            }
            "UserObjectId" {
                $User = $UserObjectId
            }
        }

        $ShortcutResource = Join-odscDrivePathResource -User $User -RelativePath $RelativePath -Name $ShortcutName

        $ShortcutResponse = $null
        try {
            $ShortcutResponse = Invoke-odscApiRequest -Resource $ShortcutResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
        } catch {
            Write-Verbose $_.Exception.Message
        }

        if (!($ShortcutResponse.remoteItem)) {
            Write-Verbose "Request: ${ShortcutResource}"
            Write-Error "Error removing OneDrive Shortcut '$($ShortcutName)' for ${User}. Resource type is not remoteItem."
            return
        }

        if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Removing shortcut '$($ShortcutName)'")) {
            try {
                $RemoveResponse = Invoke-odscApiRequest -Resource $ShortcutResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Delete) -ErrorAction Stop
            } catch {
                Write-Error "Error removing OneDrive Shortcut '$($ShortcutName)' for ${User}. $($_.Exception.Message)"
                return
            }

            if ($PassThru) {
                return Write-odscResult -User $User -ShortcutName $ShortcutName -Action 'Remove' -Status 'Removed' -Response $ShortcutResponse
            }

            return $RemoveResponse
        }
    }

    end {

    }
}
