function New-OneDriveShortcut {
    [CmdletBinding(DefaultParameterSetName = 'UserPrincipalName', SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $Uri,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $FolderPath,

        [Parameter(Mandatory = $false, ParameterSetName = 'UserPrincipalName')]
        [Parameter(Mandatory = $false, ParameterSetName = 'UserObjectId')]
        [string] $ShortcutName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserPrincipalName')]
        [string] $UserPrincipalName,

        [Parameter(Mandatory = $true, ParameterSetName = 'UserObjectId')]
        [string] $UserObjectId
    )

    begin {

    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'UserPrincipalName' {
                $User = $UserPrincipalName
            }
            'UserObjectId' {
                $User = $UserObjectId
            }
        }
        $SiteDomain = ([uri]$Uri).Authority
        $SiteResource = ([uri]$Uri).AbsolutePath

        $SiteRequest = @{
            Resource = "sites/${SiteDomain}:${SiteResource}"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        $SiteResponse = Invoke-ODSApiRequest @SiteRequest

        if (!($SiteResponse)) {
            Write-Verbose "Request: ${SiteRequest}"
            Write-Verbose "Response: ${SiteResponse}"
            Write-Error "Error retrieving SharePoint Site." -ErrorAction Stop
        }

        $SiteIdRaw = $SiteResponse.id
        $SiteIdSplit = $SiteIdRaw.split(",")
        $SiteId = $SiteIdSplit[1]
        $WebId = $SiteIdSplit[2]

        $DocumentLibraryRequest = @{
            Resource = "sites/${SiteIdRaw}/lists?`$filter=startsWith(displayName,'${DocumentLibrary}')"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
        }

        $DocumentLibraryResponse = Invoke-ODSApiRequest @DocumentLibraryRequest

        if (!($DocumentLibraryResponse) -or ($DocumentLibraryResponse.value.Count -eq 0)) {
            Write-Verbose "Request: ${DocumentLibraryRequest}"
            Write-Verbose "Response: ${DocumentLibraryResponse}"
            Write-Error "Error retrieving SharePoint Document Library." -ErrorAction Stop
        }

        $DocumentLibraryId = $DocumentLibraryResponse.value[0].id
        $DocumentLibraryName = $DocumentLibraryResponse.value[0].name

        $ItemUniqueId = 'root'
        $ItemUniqueName = $null

        if ($FolderPath) {
            $ItemUniqueIdUri = "$($Uri)/$($DocumentLibraryName)/$($FolderPath)"
            $ItemUniqueIdUri = $ItemUniqueIdUri.replace(' ', '%20')
            $ItemUniqueIdUri = $ItemUniqueIdUri.replace('%', '%25')
            $ItemUniqueIdRequest = @{
                Resource = "sites/${SiteIdRaw}/lists/${DocumentLibraryId}/items?`$expand=fields&`$filter=contains(webUrl,'${ItemUniqueIdUri}')"
                Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
            }
            
            $ItemUniqueIdResponse = Invoke-ODSApiRequest @ItemUniqueIdRequest

            if (!($ItemUniqueIdResponse) -or ($ItemUniqueIdResponse.value.Count -eq 0)) {
                Write-Verbose "Request: ${ItemUniqueIdRequest}"
                Write-Verbose "Response: ${ItemUniqueIdResponse}"
                Write-Error "Error retrieving Document Library Item."-ErrorAction Stop
            }

            $ItemUniqueId = (Select-String "[\da-zA-Z]{8}-([\da-zA-Z]{4}-){3}[\da-zA-Z]{12}" -InputObject $ItemUniqueIdResponse.value[0].eTag).Matches[0].Value
        }

        if (!($ShortcutName)) {
            if ($FolderPath) {
                $ItemUniqueNameRequest = @{
                    Resource = "sites/${SiteIdRaw}/lists/${DocumentLibraryId}/items/${ItemUniqueId}?`$expand=fields"
                    Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
                    DoNotUsePrefer = $true
                }
    
                $ItemUniqueNameResponse = Invoke-ODSApiRequest @ItemUniqueNameRequest

                if (!($ItemUniqueNameResponse)) {
                    Write-Verbose "Request: ${ItemUniqueNameRequest}"
                    Write-Verbose "Response: ${ItemUniqueNameResponse}"
                    Write-Error "Error retrieving Document Library Item Name." -ErrorAction Stop
                }

                $ItemUniqueName = $ItemUniqueNameResponse.fields.LinkFilename
                $ShortcutName = $ItemUniqueName
            } else {
                $ShortcutName = $DocumentLibrary
            }
        }

        $ShortcutRequest = @{
            Resource = "drives/${User}/root/children"
            Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Post
            Body = @{
                name = $ShortcutName
                remoteItem = @{
                    sharepointIds = @{
                        listId = $DocumentLibraryId
                        listItemUniqueId = $ItemUniqueId
                        siteId = $SiteId
                        siteUrl = $Uri
                        webId = $WebId
                    }
                }
                '@microsoft.graph.conflictBehavior' = 'rename'
            } | ConvertTo-Json
        }

        if ($PSCmdlet.ShouldProcess("${User}'s OneDrive", "Creating shortcut '$($ShortcutName)'")) {
            $ShortcutResponse = Invoke-ODSApiRequest @ShortcutRequest

            if (!($ShortcutResponse)) {
                Write-Verbose "Request: ${ShortcutRequest}"
                Write-Verbose "Response: ${ShortcutResponse}"
                Write-Error "Error creating OneDrive Shortcut." -ErrorAction Stop
            }
            return $ShortcutResponse
        } else {
            return
        }
    }

    end {
        
    }
}