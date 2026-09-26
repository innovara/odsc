@{
    RootModule = 'odsc.psm1'
    ModuleVersion = '0.5.1'
    CompatiblePSEditions = @('Core', 'Desktop')
    PowerShellVersion = '5.1'
    RequiredModules = @('MSAL.PS')
    GUID = '2e9994d4-02bc-48b0-bd8b-83825fdd340c'
    Author = 'Manuel Fombuena <mfombuena@innovara.tech>'
    Copyright = '(c) 2024 Innovara Ltd. All rights reserved.'
    Description = 'PowerShell module to manage SharePoint shortcuts in OneDrive, for individual users or at organization scale.'
    FunctionsToExport = @(
        'Connect-odsc'
        'Disconnect-odsc'
        'Get-odsc'
        'Get-odscDrive'
        'Get-odscTargetUser'
        'Invoke-odscApply'
        'Invoke-odscPlan'
        'Invoke-odscShortcutAssignment'
        'New-odsc'
        'Remove-odsc'
        'Set-odscShortcutState'
        'Test-odscPermission'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('onedrive', 'sharepoint', 'shortcuts')
            LicenseUri = 'https://github.com/innovara/odsc/blob/main/LICENSE.md'
            ProjectUri = 'https://github.com/innovara/odsc'
            ExternalModuleDependencies = @('MSAL.PS')
        }
    }
}
