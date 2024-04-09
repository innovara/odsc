function Get-OneDriveShortcut {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
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
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        $ShortcutResponse = Invoke-ODSApiRequest @ShortcutRequest

        if (!($ShortcutResponse)) {
            Write-Verbose "Request: ${ShortcutRequest}"
            Write-Verbose "Response: ${ShortcutResponse}"
            Write-Error "Error getting OneDrive Shortcut." -ErrorAction Stop
        }

        return $ShortcutResponse
    }

    end {
        
    }
}