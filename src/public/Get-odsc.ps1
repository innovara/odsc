function Get-odsc {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName')]
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
            Resource = Join-odscDrivePathResource -User $User -RelativePath $RelativePath -Name $ShortcutName
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        try {
            return Invoke-odscApiRequest @ShortcutRequest -ErrorAction Stop
        } catch {
            Write-Verbose "Request: $($ShortcutRequest.Resource)"
            Write-Error "Error getting OneDrive Shortcut '$($ShortcutName)' for ${User}. $($_.Exception.Message)"
        }
    }

    end {

    }
}
