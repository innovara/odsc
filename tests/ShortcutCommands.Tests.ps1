BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force

    $script:SiteUrl = 'https://contoso.sharepoint.com/sites/Team'
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Get-odsc, Get-odscDrive and Remove-odsc keep non-terminating errors' {
    BeforeEach {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'Microsoft Graph request failed. StatusCode: 404.' }
    }

    It 'Get-odsc writes an error and returns nothing' {
        # -ErrorAction Continue: a non-terminating error means the command carries on under Continue.
        # CI shells run with $ErrorActionPreference = 'Stop', which would turn it into a terminating one.
        # Only the error stream counts: -ErrorVariable would also collect errors caught internally.
        $Output = @(Get-odsc -ShortcutName 'Missing' -UserPrincipalName 'u@contoso.com' -ErrorAction Continue 2>&1)
        $Errors = @($Output | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
        $Output | Should -HaveCount 1
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike "Error getting OneDrive Shortcut 'Missing'*"
    }

    It 'Get-odscDrive writes an error and returns nothing' {
        Get-odscDrive -UserObjectId 'id' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It 'Remove-odsc writes an error when the shortcut does not exist' {
        $Errors = @(Remove-odsc -ShortcutName 'Missing' -UserPrincipalName 'u@contoso.com' -ErrorAction Continue 2>&1)
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike '*Resource type is not remoteItem*'
    }

    It 'honours -ErrorAction Stop from the caller' {
        { Get-odsc -ShortcutName 'Missing' -UserPrincipalName 'u@contoso.com' -ErrorAction Stop } | Should -Throw
    }

    It 'continues a script after an error' {
        $Continued = $false
        Get-odsc -ShortcutName 'Missing' -UserPrincipalName 'u@contoso.com' -ErrorAction SilentlyContinue
        $Continued = $true
        $Continued | Should -BeTrue
    }
}

Describe 'Remove-odsc' {
    It 'removes a shortcut in a RelativePath folder and returns a result with -PassThru' {
        Mock Invoke-odscApiRequest -ModuleName odsc { [pscustomobject]@{ id = 'sc'; remoteItem = @{} } } -ParameterFilter { $Method -eq 'Get' }
        Mock Invoke-odscApiRequest -ModuleName odsc { $null } -ParameterFilter { $Method -eq 'Delete' }

        $Result = Remove-odsc -ShortcutName 'Lib' -RelativePath 'A/B' -UserPrincipalName 'u@contoso.com' -PassThru -Confirm:$false

        $Result.Status | Should -Be 'Removed'
        $Result.DriveItemId | Should -Be 'sc'
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -ParameterFilter { $Method -eq 'Delete' -and $Resource -eq 'users/u@contoso.com/drive/root:/A/B/Lib' }
    }

    It 'does not remove an item that is not a shortcut' {
        Mock Invoke-odscApiRequest -ModuleName odsc { [pscustomobject]@{ id = 'folder'; folder = @{} } } -ParameterFilter { $Method -eq 'Get' }
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'must not delete' } -ParameterFilter { $Method -eq 'Delete' }

        Remove-odsc -ShortcutName 'Lib' -UserPrincipalName 'u@contoso.com' -Confirm:$false -ErrorAction SilentlyContinue
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 0 -ParameterFilter { $Method -eq 'Delete' }
    }
}

Describe 'New-odsc' {
    BeforeEach {
        Mock Resolve-odscShortcutTarget -ModuleName odsc {
            [pscustomobject]@{
                SiteIdRaw = 'h,s,w'; SiteId = 's'; WebId = 'w'; SiteUrl = $Uri
                DocumentLibraryId = 'list'; DocumentLibraryName = 'Shared Documents'; DefaultShortcutName = 'Documents'
                ItemUniqueId = 'root'; ItemUniqueName = $null; DriveId = $null; DriveItemId = $null
            }
        }
        $script:Calls = [System.Collections.Generic.List[object]]::new()
        Mock Invoke-odscApiRequest -ModuleName odsc {
            $script:Calls.Add([pscustomobject]@{ Method = "$Method"; Resource = $Resource; Body = $Body }) | Out-Null
            switch -Wildcard ("$Method $Resource") {
                'Get users/u@contoso.com/drive/root' { return [pscustomobject]@{ id = 'root' } }
                'Get users/u@contoso.com/drive/items/root:/Shortcuts:' { return [pscustomobject]@{ id = 'folder' } }
                'Post users/u@contoso.com/drive/root/children' { return [pscustomobject]@{ id = 'sc'; name = 'Documents 1' } }
                'Patch users/u@contoso.com/drive/items/sc' { return [pscustomobject]@{ id = 'sc'; name = $Body.name; remoteItem = @{} } }
                default { throw "Unexpected $Method $Resource" }
            }
        }
    }

    It 'creates the shortcut at the root, moves it, renames it and returns the Graph item' {
        $Result = New-odsc -Uri $SiteUrl -DocumentLibrary 'Documents' -RelativePath 'Shortcuts' -UserPrincipalName 'u@contoso.com' -Confirm:$false

        $Result.id | Should -Be 'sc'
        $Result.name | Should -Be 'Documents'
        $script:Calls.Method | Should -Be @('Get', 'Get', 'Post', 'Patch', 'Patch')
        $script:Calls[2].Body.'@microsoft.graph.conflictBehavior' | Should -Be 'rename'
        $script:Calls[2].Body.remoteItem.sharepointIds.listItemUniqueId | Should -Be 'root'
        $script:Calls[3].Body.parentReference.id | Should -Be 'folder'
    }

    It 'accepts -DocumentLibraryId without -DocumentLibrary' {
        New-odsc -Uri $SiteUrl -DocumentLibraryId 'list' -UserObjectId 'u@contoso.com' -Confirm:$false | Out-Null
        Should -Invoke Resolve-odscShortcutTarget -ModuleName odsc -ParameterFilter { $DocumentLibraryId -eq 'list' -and -not $DocumentLibrary }
    }

    It 'requires -DocumentLibrary or -DocumentLibraryId' {
        { New-odsc -Uri $SiteUrl -UserPrincipalName 'u@contoso.com' -ErrorAction Stop } | Should -Throw 'Specify -DocumentLibrary or -DocumentLibraryId.'
    }

    It 'writes a non-terminating error when the target cannot be resolved' {
        Mock Resolve-odscShortcutTarget -ModuleName odsc { throw 'Unable to find SharePoint site' }
        $Errors = @(New-odsc -Uri $SiteUrl -DocumentLibrary 'Documents' -UserPrincipalName 'u@contoso.com' -ErrorAction Continue 2>&1)
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike '*Unable to find SharePoint site*'
    }

    It 'makes no changes with -WhatIf' {
        New-odsc -Uri $SiteUrl -DocumentLibrary 'Documents' -UserPrincipalName 'u@contoso.com' -WhatIf
        $script:Calls | Should -HaveCount 0
    }
}

Describe 'Pipeline input' {
    It 'binds UserPrincipalName from piped objects' {
        Mock Invoke-odscApiRequest -ModuleName odsc { [pscustomobject]@{ id = 'drive' } }
        [pscustomobject]@{ UserPrincipalName = 'a@contoso.com' } | Get-odscDrive | Out-Null
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -ParameterFilter { $Resource -eq 'users/a@contoso.com/drive' }
    }

    It 'binds UserId from piped objects' {
        Mock Invoke-odscApiRequest -ModuleName odsc { [pscustomobject]@{ id = 'drive' } }
        [pscustomobject]@{ UserId = 'guid' } | Get-odscDrive | Out-Null
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -ParameterFilter { $Resource -eq 'users/guid/drive' }
    }

    It 'uses UserPrincipalName when a piped object has both identifiers' {
        Mock Invoke-odscApiRequest -ModuleName odsc { [pscustomobject]@{ id = 'drive' } }
        [pscustomobject]@{ UserPrincipalName = 'a@contoso.com'; UserObjectId = 'guid' } | Get-odscDrive | Out-Null
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 1 -Exactly -ParameterFilter { $Resource -eq 'users/a@contoso.com/drive' }
    }
}

Describe 'New-odscShortcutItem' {
    It 'explains a 409 on create as an existing shortcut to the same target' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest { throw 'Microsoft Graph request failed. Method: Post. StatusCode: 409. Error: Conflict' } -ParameterFilter { $Method -eq 'Post' }
            { New-odscShortcutItem -User 'u@contoso.com' -RemoteItem @{} -ShortcutName 'Lib' } | Should -Throw "*already has a shortcut to this target*StatusCode: 409*"
        }
    }

    It 'keeps the shortcut and names it when the rename clashes' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest { [pscustomobject]@{ id = 'sc'; name = 'Site - Lib' } } -ParameterFilter { $Method -eq 'Post' }
            Mock Invoke-odscApiRequest { throw 'Microsoft Graph request failed. Method: Patch. StatusCode: 409.' } -ParameterFilter { $Method -eq 'Patch' }
            Mock Invoke-odscApiRequest { throw 'must not delete' } -ParameterFilter { $Method -eq 'Delete' }

            $Caught = $null
            try { New-odscShortcutItem -User 'u@contoso.com' -RemoteItem @{} -ShortcutName 'Lib' } catch { $Caught = $_ }

            $Caught.Exception.Message | Should -BeLike "The shortcut was created as 'Site - Lib' in the root of u@contoso.com's OneDrive because the name 'Lib' is already used by another item there.*"
            $Caught.FullyQualifiedErrorId | Should -BeLike 'odscShortcutNotRenamed*'
            $Caught.TargetObject.id | Should -Be 'sc'
            Should -Invoke Invoke-odscApiRequest -Times 0 -ParameterFilter { $Method -eq 'Delete' }
        }
    }

    It 'keeps the shortcut at the root and names it when the move fails' {
        InModuleScope odsc {
            Mock Resolve-odscDriveFolderPath { [pscustomobject]@{ id = 'folder' } }
            Mock Invoke-odscApiRequest { [pscustomobject]@{ id = 'sc'; name = 'Lib' } } -ParameterFilter { $Method -eq 'Post' }
            Mock Invoke-odscApiRequest { throw 'Microsoft Graph request failed. Method: Patch. StatusCode: 400.' } -ParameterFilter { $Method -eq 'Patch' }

            { New-odscShortcutItem -User 'u@contoso.com' -RemoteItem @{} -ShortcutName 'Lib' -RelativePath 'A/B' } |
                Should -Throw "The shortcut was created as 'Lib' at the root of u@contoso.com's OneDrive but could not be moved to 'A/B'.*"
            Should -Invoke Invoke-odscApiRequest -Times 1 -Exactly -ParameterFilter { $Method -eq 'Patch' }
        }
    }

    It 'passes other errors through unchanged' {
        InModuleScope odsc {
            Mock Invoke-odscApiRequest { throw 'Microsoft Graph request failed. Method: Post. StatusCode: 403.' } -ParameterFilter { $Method -eq 'Post' }
            { New-odscShortcutItem -User 'u@contoso.com' -RemoteItem @{} -ShortcutName 'Lib' } | Should -Throw 'Microsoft Graph request failed. Method: Post. StatusCode: 403.'
        }
    }
}
