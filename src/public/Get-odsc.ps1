function Get-odsc {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
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

        if (!($ShortcutResponse)) {
            Write-Verbose "Request: ${ShortcutRequest}"
            Write-Verbose "Response: ${ShortcutResponse}"
            Write-Error "Error getting OneDrive Shortcut '$($ShortcutName)' for ${User}."
        }

        return $ShortcutResponse
    }

    end {

    }
}
