# CHANGELOG


## 0.2

* Add rename request to name shortcut exactly as passed to the script
* Change leading blank spaces to tabs
* Refactor from OneDriveShortcut to odcs. Commands now are: `Connect-odsc`, `Disconnect-odsc`, `Get-odsc`, `New-odsc`, `Remove-odsc`. API is `Invoke-odscApiRequest`

## 0.1.1

*   Fixed issue [#1](https://github.com/derpenstiltskin/onedriveshortcuts/issues/1#issue-1504890237) by adding option to specify AzureCloudInstance when connecting

## 0.1.0

*   Initial release
*   Commands: `Connect-ODS`, `Disconnect-ODS`, `Get-OneDriveShortcut`, `New-OneDriveShortcut`, `Remove-OneDriveShortcut`
