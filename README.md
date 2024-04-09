# odsc PowerShell Module

[![GitHub Release](https://badge.fury.io/gh/innovara%2Fodsc.svg)](https://github.com/innovara/odsc/releases)
[![PowerShell Gallery Release](https://img.shields.io/powershellgallery/v/odsc)](https://www.powershellgallery.com/packages/odsc)
[![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/innovara/odsc/blob/main/LICENSE.md)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/innovara/odsc)](https://github.com/innovara/odsc/commits/main)

#### Table of Contents

*   [Overview](#overview)
*   [What's New](#whats-new)
*   [Installation](#installation)
*   [Usage](#usage)
*   [Licensing](#licensing)

----------

## Overview

odsc is a [PowerShell](https://microsoft.com/powershell) [module](https://technet.microsoft.com/en-us/library/dd901839.aspx)
that provides CLI access to managing SharePoint shortcuts in OneDrive.

## What's New

Check out [CHANGELOG.md](CHANGELOG.md) to review the details of all releases.

## Installation

You can get latest release of the odsc module on the [PowerShell Gallery](https://www.powershellgallery.com/packages/odsc)

```PowerShell
Install-Module -Name odsc
```

## Usage

Example command:

```powershell
$Shortcut = Get-odsc -ShortcutName "Working Folder" -UserPrincipalName "user@contoso.com"
```

For more example commands, please refer to [USAGE.md](USAGE.md).

## Licensing

odsc is licensed under the [MIT license](LICENSE.md).
