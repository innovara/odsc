function Remove-odsc {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $RelativePath,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $ShortcutName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $UserObjectId
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

        $ShortcutRequest = @{
            Resource = "users/${User}/drive/root:/$([uri]::EscapeDataString($RelativePath))/$([uri]::EscapeDataString($ShortcutName))"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        $ShortcutResponse = Invoke-odscApiRequest @ShortcutRequest

        if ($ShortcutResponse.remoteItem) {
            $ShortcutRequest = @{
                Resource = "users/${User}/drive/root:/$([uri]::EscapeDataString($RelativePath))/$([uri]::EscapeDataString($ShortcutName))"
                Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
            }

            if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Removing shortcut '$($ShortcutName)'")) {
                $ShortcutResponse = Invoke-odscApiRequest @ShortcutRequest

                return $ShortcutResponse

            } else {
                return
            }

        } else {
            Write-Verbose "Request: ${ShortcutRequest}"
            Write-Verbose "Response: ${ShortcutResponse}"
            Write-Error "Error removing OneDrive Shortcut '$($ShortcutName)' for ${User}. Resource type is not remoteItem."
        return
        }
    }

    end {

    }
}
