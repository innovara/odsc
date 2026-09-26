function Invoke-odscShortcutAssignment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object[]] $User,

        [Parameter(Mandatory = $true)]
        [string] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibrary,

        [Parameter(Mandatory = $false)]
        [string] $DocumentLibraryId,

        [Parameter(Mandatory = $false)]
        [string] $FolderPath,

        [Parameter(Mandatory = $false)]
        [string] $RelativePath,

        [Parameter(Mandatory = $false)]
        [string] $ShortcutName,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Present', 'Absent')]
        [string] $State = 'Present',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Skip', 'Replace', 'Rename', 'Error')]
        [string] $ConflictAction = 'Skip',

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $ResumeFrom = 0,

        [Parameter(Mandatory = $false)]
        [string] $ReportPath,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Csv', 'Json', 'Clixml')]
        [string] $OutputFormat = 'Csv',

        [Parameter(Mandatory = $false)]
        [switch] $StopOnError
    )

    begin {
        $Users = New-Object System.Collections.Generic.List[object]
        $Results = New-Object System.Collections.Generic.List[object]
    }

    process {
        # Collect users from both -User and the pipeline so -ResumeFrom indexes the whole list.
        foreach ($Item in $User) {
            $Users.Add($Item) | Out-Null
        }
    }

    end {
        if (-not $DocumentLibrary -and -not $DocumentLibraryId) {
            Write-Error 'Specify -DocumentLibrary or -DocumentLibraryId.'
            return
        }

        try {
            for ($Index = $ResumeFrom; $Index -lt $Users.Count; $Index++) {
                $TargetUser = $Users[$Index]
                if ($TargetUser -is [string]) {
                    $UserPrincipalName = $TargetUser
                    $UserObjectId = $null
                } else {
                    $UserPrincipalName = $TargetUser.UserPrincipalName
                    $UserObjectId = if ($TargetUser.UserObjectId) { $TargetUser.UserObjectId } else { $TargetUser.Id }
                }
                $UserIdentifier = if ($UserObjectId) { $UserObjectId } else { $UserPrincipalName }

                try {
                    $Parameters = @{
                        Uri = $Uri
                        FolderPath = $FolderPath
                        RelativePath = $RelativePath
                        ShortcutName = $ShortcutName
                        State = $State
                        ConflictAction = $ConflictAction
                        Confirm = $false
                        ErrorAction = 'Stop'
                    }

                    if ($DocumentLibraryId) { $Parameters.DocumentLibraryId = $DocumentLibraryId } else { $Parameters.DocumentLibrary = $DocumentLibrary }
                    if ($UserObjectId) {
                        $Parameters.UserObjectId = $UserObjectId
                    } else {
                        $Parameters.UserPrincipalName = $UserPrincipalName
                    }

                    if ($PSCmdlet.ShouldProcess("${UserIdentifier}'s OneDrive", "Set shortcut '$ShortcutName' to state '$State'")) {
                        $Result = Set-odscShortcutState @Parameters
                        if ($Result) {
                            $Result | Add-Member -NotePropertyName Index -NotePropertyValue $Index -Force
                            $Results.Add($Result) | Out-Null
                            $Result
                        }
                    }
                } catch {
                    $Failure = [pscustomobject]@{
                        PSTypeName = 'odsc.ShortcutResult'
                        User = $UserIdentifier
                        ShortcutName = $ShortcutName
                        Action = if ($State -eq 'Absent') { 'Remove' } else { 'Create' }
                        Status = 'Failed'
                        TargetSite = $Uri
                        TargetLibrary = if ($DocumentLibrary) { $DocumentLibrary } else { $DocumentLibraryId }
                        TargetFolderPath = $FolderPath
                        DriveItemId = $null
                        WebUrl = $null
                        Message = $_.Exception.Message
                        Response = $null
                        Timestamp = (Get-Date).ToUniversalTime()
                        Index = $Index
                    }
                    $Results.Add($Failure) | Out-Null
                    $Failure

                    if ($StopOnError) {
                        Write-Error "Stopped at user index $Index ($UserIdentifier): $($Failure.Message) Fix the cause and continue with -ResumeFrom $Index." -ErrorAction Stop
                    }
                }
            }
        } finally {
            # Write the report even when -StopOnError stops the run, so it can be resumed.
            if ($ReportPath) {
                Export-odscReport -InputObject $Results.ToArray() -Path $ReportPath -Format $OutputFormat
            }
        }
    }
}
