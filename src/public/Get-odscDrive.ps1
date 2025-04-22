function Get-odscDrive {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
    param(
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

        $DriveRequest = @{
            Resource = "users/${User}/drive"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        $DriveResponse = Invoke-odscApiRequest @DriveRequest

        if (!($DriveResponse)) {
            Write-Verbose "Request: ${DriveRequest}"
            Write-Verbose "Response: ${DriveResponse}"
            Write-Error "Error getting OneDrive drive for ${User}."
        }

        return $DriveResponse
    }

    end {

    }
}
