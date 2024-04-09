@{
	RootModule = 'odsc.psm1'
	ModuleVersion = '0.2.0'
	CompatiblePSEditions = @('Core', 'Desktop')
	PowerShellVersion = '5.1'
	RequiredModules = @('MSAL.PS')
	GUID = '2e9994d4-02bc-48b0-bd8b-83825fdd340c'
	Author = 'Manuel Fombuena <fombuena@outlook.com>'
	Copyright = '(c) 2024 Manuel Fombuena. All rights reserved.'
	Description = 'PowerShell module to manage SharePoint shortcuts in OneDrive.'
	PrivateData = @{
		PSData = @{
			Tags = @('onedrive', 'sharepoint', 'shortcuts')
			LicenseUri = 'https://github.com/innovara/odsc/blob/main/LICENSE.md'
			ProjectUri = 'https://github.com/innovara/odsc'
			ExternalModuleDependencies = @('MSAL.PS')
		}
	}
}
