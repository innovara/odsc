function Resolve-odscDriveFolderPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $User,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyString()]
        [string] $RelativePath,

        [Parameter(Mandatory = $false)]
        [switch] $Create
    )

    $CurrentItem = Invoke-odscApiRequest -Resource "users/${User}/drive/root" -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop

    $Segments = @($RelativePath -split '/+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    foreach ($Segment in $Segments) {
        $EncodedSegment = [uri]::EscapeDataString($Segment)
        $ChildResource = "users/${User}/drive/items/$($CurrentItem.id):/${EncodedSegment}:"
        $Child = $null

        try {
            $Child = Invoke-odscApiRequest -Resource $ChildResource -Method ([Microsoft.PowerShell.Commands.WebRequestMethod]::Get) -ErrorAction Stop
        } catch {
            # Only a missing folder may be created; any other failure is reported as is.
            if ((Get-odscGraphStatusCode -ErrorRecord $_) -ne 404) {
                Write-Error $_ -ErrorAction Stop
            }

            if (-not $Create) {
                Write-Error "OneDrive folder path '$RelativePath' was not found for '$User'." -ErrorAction Stop
            }
        }

        if (-not $Child) {
            $CreateRequest = @{
                Resource = Join-odscDriveItemResource -User $User -ItemId $CurrentItem.id -Children
                Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Post
                Body = @{
                    name = $Segment
                    folder = @{}
                    '@microsoft.graph.conflictBehavior' = 'fail'
                }
            }

            Write-Verbose "Creating folder '$Segment' in '$RelativePath' for '$User'."
            $Child = Invoke-odscApiRequest @CreateRequest -ErrorAction Stop
        }

        $CurrentItem = $Child
    }

    return $CurrentItem
}
