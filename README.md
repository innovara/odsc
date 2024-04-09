# OneDriveShortcuts PowerShell Module

[![GitHub Release](https://badge.fury.io/gh/derpenstiltskin%2Fonedriveshortcuts.svg)](https://github.com/derpenstiltskin/onedriveshortcuts/releases)
[![PowerShell Gallery Release](https://img.shields.io/powershellgallery/v/OneDriveShortcuts)](https://www.powershellgallery.com/packages/OneDriveShortcuts)
[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/derpenstiltskin/onedriveshortcuts/blob/main/LICENSE.md)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/derpenstiltskin/onedriveshortcuts)](https://github.com/derpenstiltskin/onedriveshortcuts/commits/main)

#### Table of Contents

*   [Overview](#overview)
*   [What's New](#whats-new)
*   [Installation](#installation)
*   [Usage](#usage)
*   [Licensing](#licensing)

----------

## Overview

OneDriveShortcuts is a [PowerShell](https://microsoft.com/powershell) [module](https://technet.microsoft.com/en-us/library/dd901839.aspx)
that provides CLI access to managing SharePoint shortcuts in OneDrive.

## What's New

Check out [CHANGELOG.md](CHANGELOG.md) to review the details of all releases.

## Installation

You can get latest release of the OneDriveShortcuts module on the [PowerShell Gallery](https://www.powershellgallery.com/packages/OneDriveShortcuts)

```PowerShell
Install-Module -Name OneDriveShortcuts
```

## Usage

Example command:

```powershell
$Shortcut = Get-OneDriveShortcut -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

For more example commands, please refer to [USAGE.md](USAGE.md).

## Licensing

OneDriveShortcuts is licensed under the [MIT license](LICENSE.md).
