BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force

    $script:SiteUrl = 'https://contoso.sharepoint.com/sites/Team'
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Test-odscShortcutTargetMatch' {
    It 'matches shortcuts by SharePoint ids or by drive item reference' {
        InModuleScope odsc {
            $Target = [pscustomobject]@{ ItemUniqueId = 'u'; DocumentLibraryId = 'l'; SiteId = 's'; WebId = 'w' }
            $Shortcut = [pscustomobject]@{ remoteItem = [pscustomobject]@{ sharepointIds = [pscustomobject]@{ listId = 'l'; listItemUniqueId = 'u'; siteId = 's'; webId = 'w' } } }
            Test-odscShortcutTargetMatch -Shortcut $Shortcut -Target $Target | Should -BeTrue

            $Target.WebId = 'other'
            Test-odscShortcutTargetMatch -Shortcut $Shortcut -Target $Target | Should -BeFalse

            $DriveTarget = [pscustomobject]@{ DriveId = 'd'; DriveItemId = 'i' }
            $DriveShortcut = [pscustomobject]@{ remoteItem = [pscustomobject]@{ id = 'i'; parentReference = [pscustomobject]@{ driveId = 'd' } } }
            Test-odscShortcutTargetMatch -Shortcut $DriveShortcut -Target $DriveTarget | Should -BeTrue
        }
    }
}

Describe 'Set-odscShortcutState' {
    BeforeEach {
        Mock Resolve-odscShortcutTarget -ModuleName odsc {
            [pscustomobject]@{
                SiteIdRaw = 'h,s,w'; SiteId = 's'; WebId = 'w'; SiteUrl = $Uri
                DocumentLibraryId = 'list'; DocumentLibraryName = 'Shared Documents'; DefaultShortcutName = 'Documents'
                ItemUniqueId = 'root'; ItemUniqueName = $null; DriveId = $null; DriveItemId = $null
            }
        }
        Mock Resolve-odscOneDriveRoot -ModuleName odsc { [pscustomobject]@{ id = 'root' } }
        Mock New-odscShortcutItem -ModuleName odsc { [pscustomobject]@{ id = 'new'; name = $ShortcutName; webUrl = 'https://x' } }
        Mock Invoke-odscApiRequest -ModuleName odsc { $null } -ParameterFilter { $Method -eq 'Delete' }

        $script:Matching = [pscustomobject]@{ id = 'sc'; remoteItem = [pscustomobject]@{ sharepointIds = [pscustomobject]@{ listId = 'list'; listItemUniqueId = 'root'; siteId = 's'; webId = 'w' } } }
        $script:Different = [pscustomobject]@{ id = 'sc'; remoteItem = [pscustomobject]@{ sharepointIds = [pscustomobject]@{ listId = 'other'; listItemUniqueId = 'root'; siteId = 's'; webId = 'w' } } }
        $script:RealFolder = [pscustomobject]@{ id = 'folder'; folder = @{ childCount = 3 } }
        $Common = @{ Uri = $SiteUrl; DocumentLibrary = 'Documents'; UserPrincipalName = 'u@contoso.com'; Confirm = $false }
    }

    It 'creates a missing shortcut' {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'StatusCode: 404' } -ParameterFilter { $Method -eq 'Get' }
        $Result = Set-odscShortcutState @Common -RelativePath 'A'
        $Result.Status | Should -Be 'Created'
        $Result.DriveItemId | Should -Be 'new'
        Should -Invoke New-odscShortcutItem -ModuleName odsc -ParameterFilter { $RelativePath -eq 'A' -and $ShortcutName -eq 'Documents' }
    }

    It 'reports an existing matching shortcut as compliant' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Matching } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common).Status | Should -Be 'Compliant'
        Should -Invoke New-odscShortcutItem -ModuleName odsc -Times 0
    }

    It 'skips a conflicting item by default' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common).Status | Should -Be 'SkippedConflict'
    }

    It 'errors on conflict with ConflictAction Error' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        { Set-odscShortcutState @Common -ConflictAction Error -ErrorAction Stop } | Should -Throw '*already exists*'
    }

    It 'writes a non-terminating error by default' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        $Errors = @(Set-odscShortcutState @Common -ConflictAction Error -ErrorAction Continue 2>&1)
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike '*already exists*'
    }

    It 'replaces a conflicting shortcut' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -ConflictAction Replace).Status | Should -Be 'Created'
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 1 -ParameterFilter { $Method -eq 'Delete' }
    }

    It 'never replaces an item that is not a shortcut' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:RealFolder } -ParameterFilter { $Method -eq 'Get' }
        { Set-odscShortcutState @Common -ConflictAction Replace -ErrorAction Stop } | Should -Throw '*is not a OneDrive shortcut*'
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 0 -ParameterFilter { $Method -eq 'Delete' }
    }

    It 'creates a timestamped name with ConflictAction Rename' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -ConflictAction Rename).ShortcutName | Should -Match '^Documents-\d{14}$'
    }

    It 'removes a matching shortcut when Absent' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Matching } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -State Absent).Status | Should -Be 'Removed'
    }

    It 'does not remove a shortcut pointing elsewhere when Absent' {
        Mock Invoke-odscApiRequest -ModuleName odsc { $script:Different } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -State Absent).Status | Should -Be 'SkippedConflict'
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 0 -ParameterFilter { $Method -eq 'Delete' }
    }

    It 'reports AlreadyAbsent when nothing exists' {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'StatusCode: 404' } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -State Absent).Status | Should -Be 'AlreadyAbsent'
    }

    It 'reports RenameFailed with the actual name when the shortcut cannot be renamed' {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'StatusCode: 404' } -ParameterFilter { $Method -eq 'Get' }
        Mock New-odscShortcutItem -ModuleName odsc {
            Write-Error -ErrorId 'odscShortcutNotRenamed' -TargetObject ([pscustomobject]@{ id = 'sc'; name = 'Site - Documents' }) -Message 'The shortcut was created as ...' -ErrorAction Stop
        }

        $Result = Set-odscShortcutState @Common
        $Result.Status | Should -Be 'RenameFailed'
        $Result.ShortcutName | Should -Be 'Site - Documents'
        $Result.DriveItemId | Should -Be 'sc'
        $Result.Message | Should -Be 'The shortcut was created as ...'
    }

    It 'returns the Graph item with -PassThru' {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'StatusCode: 404' } -ParameterFilter { $Method -eq 'Get' }
        (Set-odscShortcutState @Common -PassThru).id | Should -Be 'new'
    }
}
