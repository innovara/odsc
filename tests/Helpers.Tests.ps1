BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'OneDrive path helpers' {
    It 'encodes each path segment and keeps / as separator' {
        InModuleScope odsc {
            ConvertTo-odscGraphDrivePath -Path 'Team Shortcuts/2026 #1' | Should -Be 'Team%20Shortcuts/2026%20%231'
            ConvertTo-odscGraphDrivePath -Path '/a//b/' | Should -Be 'a/b'
            ConvertTo-odscGraphDrivePath -Path '' | Should -Be ''
        }
    }

    It 'builds shortcut path resources with and without a RelativePath' {
        InModuleScope odsc {
            Join-odscDrivePathResource -User 'user@contoso.com' -Name 'My Library' | Should -Be 'users/user@contoso.com/drive/root:/My%20Library'
            Join-odscDrivePathResource -User 'user@contoso.com' -RelativePath 'A/B' -Name 'Lib' | Should -Be 'users/user@contoso.com/drive/root:/A/B/Lib'
            Join-odscDrivePathResource -User 'user@contoso.com' | Should -Be 'users/user@contoso.com/drive/root'
        }
    }
}

Describe 'Resolve-odscDriveFolderPath' {
    It 'creates only the missing folders, nested under their parent' {
        InModuleScope odsc {
            $script:Posts = [System.Collections.Generic.List[object]]::new()
            Mock Invoke-odscApiRequest {
                if ($Method -eq 'Get' -and $Resource -eq 'users/u/drive/root') { return [pscustomobject]@{ id = 'root' } }
                if ($Method -eq 'Get' -and $Resource -eq 'users/u/drive/items/root:/A:') { return [pscustomobject]@{ id = 'a' } }
                if ($Method -eq 'Get') { throw "Microsoft Graph request failed. StatusCode: 404. Resource: $Resource" }
                $script:Posts.Add([pscustomobject]@{ Resource = $Resource; Name = $Body.name }) | Out-Null
                return [pscustomobject]@{ id = "new-$($Body.name)" }
            }

            $Folder = Resolve-odscDriveFolderPath -User 'u' -RelativePath 'A/B' -Create

            $Folder.id | Should -Be 'new-B'
            $script:Posts | Should -HaveCount 1
            $script:Posts[0].Resource | Should -Be 'users/u/drive/items/a/children'
        }
    }

    It 'does not try to create a folder when the lookup fails for a reason other than 404' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest {
                if ($Resource -eq 'users/u/drive/root') { return [pscustomobject]@{ id = 'root' } }
                if ($Method -eq 'Get') { throw 'Microsoft Graph request failed. StatusCode: 403.' }
                throw 'POST must not be called'
            }

            { Resolve-odscDriveFolderPath -User 'u' -RelativePath 'A' -Create } | Should -Throw '*StatusCode: 403*'
        }
    }
}

Describe 'Resolve-odscSharePointSite' {
    It 'addresses a site by host and path, and the tenant root site by host only' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest { [pscustomobject]@{ id = 'host,site,web'; Resource = $Resource } }

            (Resolve-odscSharePointSite -Uri 'https://contoso.sharepoint.com/sites/Team/').Raw.Resource | Should -Be 'sites/contoso.sharepoint.com:/sites/Team'
            (Resolve-odscSharePointSite -Uri 'https://contoso.sharepoint.com').Raw.Resource | Should -Be 'sites/contoso.sharepoint.com'
        }
    }

    It 'rejects a non-https URI' {
        InModuleScope odsc {
            { Resolve-odscSharePointSite -Uri 'http://contoso.sharepoint.com/sites/Team' } | Should -Throw '*not valid*'
        }
    }
}

Describe 'Resolve-odscDocumentLibrary' {
    It 'prefers an exact display name match' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest {
                if ($Resource -like "*displayName eq 'Documents'*") { return @([pscustomobject]@{ id = 'exact'; displayName = 'Documents' }) }
                throw 'prefix lookup must not run'
            }

            (Resolve-odscDocumentLibrary -SiteIdRaw 's' -Uri 'https://x' -DocumentLibrary 'Documents').id | Should -Be 'exact'
        }
    }

    It 'falls back to the first prefix match and warns when it is ambiguous' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest {
                if ($Resource -like '*displayName eq*') { return @() }
                return @([pscustomobject]@{ id = 'one'; displayName = 'Doc A' }, [pscustomobject]@{ id = 'two'; displayName = 'Doc B' })
            }

            $Result = Resolve-odscDocumentLibrary -SiteIdRaw 's' -Uri 'https://x' -DocumentLibrary 'Doc' -WarningVariable Warnings -WarningAction SilentlyContinue
            $Result.id | Should -Be 'one'
            $Warnings | Should -HaveCount 1
        }
    }

    It "escapes single quotes in the library name" {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest { @([pscustomobject]@{ id = 'x'; displayName = "Bob's" }) }
            Resolve-odscDocumentLibrary -SiteIdRaw 's' -Uri 'https://x' -DocumentLibrary "Bob's" | Out-Null
            Should -Invoke Invoke-odscApiRequest -ParameterFilter { $Resource -like "*'Bob''s'*" }
        }
    }
}

Describe 'Shortcut target helpers' {
    It 'recovers the list item unique id when Graph omits sharepointIds on the folder' {
        InModuleScope odsc {
            Mock Resolve-odscSharePointSite { [pscustomobject]@{ SiteIdRaw = 'h,s,w'; SiteId = 's'; WebId = 'w' } }
            Mock Resolve-odscDocumentLibrary { [pscustomobject]@{ id = 'list'; name = 'Shared Documents'; displayName = 'Documents' } }
            Mock Resolve-odscDocumentLibraryFolder { [pscustomobject]@{ Drive = [pscustomobject]@{ id = 'drive' }; Item = [pscustomobject]@{ id = 'item'; name = 'Projects' } } }
            Mock Invoke-odscApiRequest { [pscustomobject]@{ sharepointIds = [pscustomobject]@{ listItemUniqueId = 'recovered' } } } -ParameterFilter { $Resource -eq 'drives/drive/items/item/listItem' }

            $Target = Resolve-odscShortcutTarget -Uri 'https://contoso.sharepoint.com/sites/Team' -DocumentLibrary 'Documents' -FolderPath 'Projects'

            $Target.ItemUniqueId | Should -Be 'recovered'
            $Target.DefaultShortcutName | Should -Be 'Projects'
        }
    }
}

Describe 'Retry-After parsing' {
    It 'reads delta seconds and HTTP dates' -Skip:($PSVersionTable.PSEdition -eq 'Desktop') {
        InModuleScope odsc {
            $Response = [System.Net.Http.HttpResponseMessage]::new(429)
            $Response.Headers.Add('Retry-After', '7')
            Get-odscRetryAfterDelay -Response $Response | Should -Be 7

            $Response = [System.Net.Http.HttpResponseMessage]::new(429)
            $Response.Headers.Add('Retry-After', [DateTimeOffset]::UtcNow.AddSeconds(30).ToString('r'))
            Get-odscRetryAfterDelay -Response $Response | Should -BeGreaterThan 20

            Get-odscRetryAfterDelay -Response ([System.Net.Http.HttpResponseMessage]::new(429)) | Should -BeNullOrEmpty
        }
    }
}
