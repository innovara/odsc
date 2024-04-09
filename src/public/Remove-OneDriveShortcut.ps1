function Remove-OneDriveShortcut {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName', SupportsShouldProcess)]
    param(
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
            Resource = "drives/$($User)/root:/$([uri]::EscapeDataString($ShortcutName))"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete
        }

        if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Removing shortcut '$($ShortcutName)'")) {
            $ShortcutResponse = Invoke-ODSApiRequest @ShortcutRequest

#            if (!($ShortcutResponse)) {
#                Write-Verbose "Request: ${ShortcutRequest}"
#                Write-Verbose "Response: ${ShortcutResponse}"
#                Write-Error "Error creating OneDrive Shortcut." -ErrorAction Stop
#            }
            return $ShortcutResponse
        } else {
            return
        }
    }

    end {
        
    }
}