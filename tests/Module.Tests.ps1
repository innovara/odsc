BeforeAll {
    Import-Module "$PSScriptRoot/../src/odsc.psd1" -Force
}

AfterAll {
    Remove-Module odsc -ErrorAction SilentlyContinue
}

Describe 'Module' {
    It 'exports the public commands' {
        $Expected = 'Connect-odsc', 'Disconnect-odsc', 'Get-odsc', 'Get-odscDrive', 'Get-odscTargetUser', 'Invoke-odscApply',
            'Invoke-odscPlan', 'Invoke-odscShortcutAssignment', 'New-odsc', 'Remove-odsc', 'Set-odscShortcutState', 'Test-odscPermission'
        (Get-Command -Module odsc).Name | Sort-Object | Should -Be ($Expected | Sort-Object)
    }
}
