function Get-odscTargetUser {
    [CmdletBinding(DefaultParameterSetName = 'AllUsers')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Csv')]
        [string] $CsvPath,

        [Parameter(Mandatory = $true, ParameterSetName = 'Group')]
        [string] $GroupId,

        [Parameter(Mandatory = $true, ParameterSetName = 'Filter')]
        [string] $Filter,

        [Parameter(Mandatory = $true, ParameterSetName = 'AllUsers')]
        [switch] $AllUsers,

        [Parameter(Mandatory = $false, ParameterSetName = 'Group')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Filter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'AllUsers')]
        [switch] $IncludeDisabled
    )

    process {
        try {
            # Advanced queries (OData casts, $count, most filters) require ConsistencyLevel: eventual.
            $AdvancedQuery = @{
                Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
                Headers = @{ ConsistencyLevel = 'eventual' }
                AllPages = $true
                ErrorAction = 'Stop'
            }
            $Select = '$select=id,userPrincipalName,mail,accountEnabled&$count=true'

            switch ($PsCmdlet.ParameterSetName) {
                'Csv' {
                    Import-Csv -Path $CsvPath | ForEach-Object {
                        $UserObjectId = if ($_.UserObjectId) { $_.UserObjectId } else { $_.Id }
                        if (-not $_.UserPrincipalName -and -not $UserObjectId) {
                            Write-Warning "Skipping a row in '$CsvPath' without UserPrincipalName, UserObjectId or Id."
                            return
                        }

                        [pscustomobject]@{
                            UserPrincipalName = $_.UserPrincipalName
                            UserObjectId = $UserObjectId
                            Mail = $_.Mail
                            AccountEnabled = $null
                            Source = $CsvPath
                        }
                    }
                }
                'Group' {
                    try {
                        $Users = Invoke-odscApiRequest @AdvancedQuery -Resource "groups/${GroupId}/transitiveMembers/microsoft.graph.user?$Select"
                    } catch {
                        Stop-odscGraphError -ErrorRecord $_ `
                            -ForbiddenMessage "Unable to read transitive user members for group '$GroupId'. Microsoft Graph returned 403. Grant admin consent for GroupMember.Read.All, or use a broader equivalent such as Group.Read.All or Directory.Read.All. Hidden membership groups also require Member.Read.Hidden." `
                            -FallbackMessage "Unable to resolve users from group '$GroupId'."
                    }
                    $Source = $GroupId
                }
                'Filter' {
                    $EncodedFilter = [uri]::EscapeDataString($Filter)
                    try {
                        $Users = Invoke-odscApiRequest @AdvancedQuery -Resource "users?`$filter=${EncodedFilter}&$Select"
                    } catch {
                        Stop-odscGraphError -ErrorRecord $_ -FallbackMessage "Unable to resolve users with filter '$Filter'."
                    }
                    $Source = $Filter
                }
                'AllUsers' {
                    $null = $AllUsers
                    try {
                        $Users = Invoke-odscApiRequest @AdvancedQuery -Resource "users?$Select"
                    } catch {
                        Stop-odscGraphError -ErrorRecord $_ -FallbackMessage 'Unable to list users.'
                    }
                    $Source = 'AllUsers'
                }
            }

            if ($PsCmdlet.ParameterSetName -eq 'Csv') {
                return
            }

            # Disabled accounts are skipped unless requested. Users without the property are kept.
            $Disabled = @($Users | Where-Object { $_.accountEnabled -eq $false })
            if ($Disabled.Count -gt 0 -and -not $IncludeDisabled) {
                Write-Verbose "Skipping $($Disabled.Count) disabled account(s) from '$Source'. Use -IncludeDisabled to include them."
                $Users = @($Users | Where-Object { $_.accountEnabled -ne $false })
            }

            $Users | ForEach-Object {
                [pscustomobject]@{
                    UserPrincipalName = $_.userPrincipalName
                    UserObjectId = $_.id
                    Mail = $_.mail
                    AccountEnabled = $_.accountEnabled
                    Source = $Source
                }
            }
        } catch {
            Write-Error $_.Exception.Message
        }
    }
}
