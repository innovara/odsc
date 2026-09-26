function Get-odscDrive {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName', ValueFromPipelineByPropertyName = $true)]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId', ValueFromPipelineByPropertyName = $true)]
        [Alias('UserId')]
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

        try {
            return Invoke-odscApiRequest @DriveRequest -ErrorAction Stop
        } catch {
            Write-Verbose "Request: $($DriveRequest.Resource)"
            Write-Error "Error getting OneDrive drive for ${User}. $($_.Exception.Message)"
        }
    }

    end {

    }
}
