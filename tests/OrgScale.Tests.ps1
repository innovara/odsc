BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force

    $script:SiteUrl = 'https://contoso.sharepoint.com/sites/Team'
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Invoke-odscShortcutAssignment' {
    BeforeEach {
        Mock Set-odscShortcutState -ModuleName odsc {
            if ($UserPrincipalName -eq 'bad@contoso.com') { throw 'boom' }
            [pscustomobject]@{ User = if ($UserObjectId) { $UserObjectId } else { $UserPrincipalName }; Status = 'Created' }
        }
        $Users = 'a@contoso.com', 'bad@contoso.com', 'c@contoso.com' | ForEach-Object { [pscustomobject]@{ UserPrincipalName = $_ } }
    }

    It 'continues after a failure and reports it' {
        $Results = Invoke-odscShortcutAssignment -User $Users -Uri $SiteUrl -DocumentLibrary 'Documents' -Confirm:$false
        $Results.Status | Should -Be @('Created', 'Failed', 'Created')
        $Results[1].Action | Should -Be 'Create'
        $Results[1].Message | Should -Be 'boom'
    }

    It 'honours -ResumeFrom for piped users' {
        $Results = $Users | Invoke-odscShortcutAssignment -Uri $SiteUrl -DocumentLibrary 'Documents' -ResumeFrom 2 -Confirm:$false
        $Results | Should -HaveCount 1
        $Results[0].User | Should -Be 'c@contoso.com'
        $Results[0].Index | Should -Be 2
    }

    It 'stops at the first failure with -StopOnError and still writes the report' {
        $Report = Join-Path $TestDrive 'stopped.csv'
        { Invoke-odscShortcutAssignment -User $Users -Uri $SiteUrl -DocumentLibrary 'Documents' -ReportPath $Report -StopOnError -Confirm:$false } |
            Should -Throw '*Stopped at user index 1 (bad@contoso.com): boom*-ResumeFrom 1*'
        (Import-Csv $Report).Status | Should -Be @('Created', 'Failed')
        Should -Invoke Set-odscShortcutState -ModuleName odsc -Times 2 -Exactly
    }

    It 'prefers the object id when present' {
        $Results = Invoke-odscShortcutAssignment -User ([pscustomobject]@{ UserPrincipalName = 'a@contoso.com'; UserObjectId = 'guid' }) -Uri $SiteUrl -DocumentLibrary 'Documents' -Confirm:$false
        $Results[0].User | Should -Be 'guid'
    }

    It 'writes a report' {
        $Report = Join-Path $TestDrive 'report.csv'
        Invoke-odscShortcutAssignment -User $Users -Uri $SiteUrl -DocumentLibrary 'Documents' -ReportPath $Report -Confirm:$false | Out-Null
        Import-Csv $Report | Should -HaveCount 3
    }
}

Describe 'Plans' {
    It 'resolves csvPath relative to the plan file and applies it' {
        $PlanDirectory = Join-Path $TestDrive 'plans'
        New-Item -ItemType Directory -Path $PlanDirectory | Out-Null
        'UserPrincipalName,Mail' , 'a@contoso.com,a@contoso.com' | Set-Content (Join-Path $PlanDirectory 'users.csv')
        @{
            shortcuts = @(
                @{ name = 'Team'; siteUrl = $SiteUrl; library = 'Documents'; oneDrivePath = 'Shortcuts'; conflictAction = 'Replace'; target = @{ csvPath = 'users.csv' } }
            )
        } | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $PlanDirectory 'plan.json')

        $Plan = Invoke-odscPlan -Path (Join-Path $PlanDirectory 'plan.json')
        $Plan.Target.csvPath | Should -Be (Join-Path $PlanDirectory 'users.csv')
        $Plan.ConflictAction | Should -Be 'Replace'

        Mock Set-odscShortcutState -ModuleName odsc { [pscustomobject]@{ User = $UserPrincipalName; Status = 'Created' } }
        Push-Location $TestDrive
        try {
            $Results = Invoke-odscApply -Path (Join-Path $PlanDirectory 'plan.json') -Confirm:$false
        } finally {
            Pop-Location
        }

        $Results.User | Should -Be 'a@contoso.com'
        Should -Invoke Set-odscShortcutState -ModuleName odsc -ParameterFilter { $ConflictAction -eq 'Replace' -and $RelativePath -eq 'Shortcuts' -and $ShortcutName -eq 'Team' }
    }
}

Describe 'Invoke-odscApply error handling' {
    BeforeEach {
        $script:PlanPath = Join-Path $TestDrive 'apply.json'
        @{
            shortcuts = @(
                @{ name = 'First'; siteUrl = $SiteUrl; library = 'Documents'; target = @{ groupId = 'broken' } },
                @{ name = 'Second'; siteUrl = $SiteUrl; library = 'Documents'; target = @{ groupId = 'ok' } }
            )
        } | ConvertTo-Json -Depth 5 | Set-Content $script:PlanPath

        Mock Get-odscTargetUser -ModuleName odsc {
            if ($GroupId -eq 'broken') { Write-Error 'forbidden' -ErrorAction Stop }
            [pscustomobject]@{ UserPrincipalName = 'a@contoso.com' }
        }
        Mock Set-odscShortcutState -ModuleName odsc { [pscustomobject]@{ User = $UserPrincipalName; Status = 'Created' } }
    }

    It 'reports a plan whose users cannot be resolved and continues with the next one' {
        $Output = @(Invoke-odscApply -Path $script:PlanPath -Confirm:$false -ErrorAction Continue 2>&1)
        ($Output | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }).Exception.Message | Should -BeLike "Plan 'First'*forbidden*"
        ($Output | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }).Status | Should -Be 'Created'
    }

    It 'stops with -StopOnError' {
        { Invoke-odscApply -Path $script:PlanPath -StopOnError -Confirm:$false } | Should -Throw "Plan 'First'*"
        Should -Invoke Set-odscShortcutState -ModuleName odsc -Times 0
    }

    It 'writes a non-terminating error for an unreadable plan' {
        $Errors = @(Invoke-odscApply -Path (Join-Path $TestDrive 'missing.json') -ErrorAction Continue 2>&1)
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike 'Unable to read plan*'
    }
}

Describe 'Get-odscTargetUser' {
    It 'writes a non-terminating error when the group cannot be read' {
        Mock Invoke-odscApiRequest -ModuleName odsc { throw 'Microsoft Graph request failed. StatusCode: 403.' }
        $Errors = @(Get-odscTargetUser -GroupId 'g' -ErrorAction Continue 2>&1)
        $Errors | Should -HaveCount 1
        $Errors[0].Exception.Message | Should -BeLike '*GroupMember.Read.All*'
    }

    It 'reads users from a CSV file' {
        $Csv = Join-Path $TestDrive 'users.csv'
        'UserPrincipalName,Id,Mail', 'a@contoso.com,guid-a,a@contoso.com', ',,' | Set-Content $Csv
        $Users = Get-odscTargetUser -CsvPath $Csv -WarningAction SilentlyContinue
        $Users | Should -HaveCount 1
        $Users[0].UserObjectId | Should -Be 'guid-a'
        $Users[0].Mail | Should -Be 'a@contoso.com'
    }

    It 'sends ConsistencyLevel for group and filter queries' {
        Mock Invoke-odscApiRequest -ModuleName odsc { @([pscustomobject]@{ id = '1'; userPrincipalName = 'a@contoso.com' }) }
        (Get-odscTargetUser -GroupId 'g').UserObjectId | Should -Be '1'
        Get-odscTargetUser -Filter "startsWith(displayName,'A')" | Out-Null
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -Times 2 -ParameterFilter { $Headers.ConsistencyLevel -eq 'eventual' -and $AllPages }
    }
}

Describe 'Test-odscPermission' {
    It 'checks Graph access with a call covered by User.Read.All' {
        Mock Invoke-odscApiRequest -ModuleName odsc { @() }
        (Test-odscPermission)[0].Status | Should -Be 'Passed'
        Should -Invoke Invoke-odscApiRequest -ModuleName odsc -ParameterFilter { $Resource -like 'users?*' }
    }
}
