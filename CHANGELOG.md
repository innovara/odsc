# CHANGELOG

## 0.3.0

* Change endpoint `/drives/{idOrUserPrincipalName}` to `/users/{idOrUserPrincipalName}/drive`
* New command: `Get-odscDrive`
* Ease use in scripts by removing Stop on some errors
* Ensure that `Remove-odsc` removes a remoteItem-type resource
* Move token to global script variable for better interaction in scripts
* Other minor fixes and updates

## 0.2.1

* Add rename request to name shortcut exactly as passed to the script
* Change leading blank spaces to tabs
* Refactor from OneDriveShortcut to odsc. Commands now are: `Connect-odsc`, `Disconnect-odsc`, `Get-odsc`, `New-odsc`, `Remove-odsc`. API is `Invoke-odscApiRequest`

## 0.1.1

*   Fixed issue [#1](https://github.com/derpenstiltskin/onedriveshortcuts/issues/1#issue-1504890237) by adding option to specify AzureCloudInstance when connecting

## 0.1.0

*   Initial release
*   Commands: `Connect-ODS`, `Disconnect-ODS`, `Get-OneDriveShortcut`, `New-OneDriveShortcut`, `Remove-OneDriveShortcut`
