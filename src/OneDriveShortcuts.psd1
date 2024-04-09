@{
    RootModule = 'OneDriveShortcuts.psm1'
    ModuleVersion = '0.1.1'
    CompatiblePSEditions = @('Core', 'Desktop')
    PowerShellVersion = '5.1'
    RequiredModules = @('MSAL.PS')
    GUID = '625bbde6-59fe-4373-b3d3-8b0f07f075d2'
    Author = 'Dustin Riley <dustin@derpenstiltskin.com>'
    Copyright = '(c) 2022 Dustin Riley. All rights reserved.'
    Description = 'PowerShell module to manage SharePoint shortcuts in OneDrive.'
    PrivateData = @{
        PSData = @{
            Tags = @('onedrive', 'sharepoint', 'shortcuts')
            LicenseUri = 'https://github.com/derpenstiltskin/onedriveshortcuts/blob/main/LICENSE.md'
            ProjectUri = 'https://github.com/derpenstiltskin/onedriveshortcuts'
            ExternalModuleDependencies = @('MSAL.PS')
        }
    }
}
