function Invoke-odscApply {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $false)]
        [string] $ReportPath,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Csv', 'Json', 'Clixml')]
        [string] $OutputFormat = 'Csv',

        [Parameter(Mandatory = $false)]
        [switch] $StopOnError
    )

    try {
        # A plan that cannot be read always stops the run.
        $Plans = @(Invoke-odscPlan -Path $Path -ErrorAction Stop)
    } catch {
        Write-Error $_.Exception.Message
        return
    }

    $Results = New-Object System.Collections.Generic.List[object]
    $StopParameters = if ($StopOnError) { @{ ErrorAction = 'Stop' } } else { @{} }

    try {
        foreach ($Plan in $Plans) {
            $Target = $Plan.Target
            if ($Target.groupId) {
                $TargetDescription = "group '$($Target.groupId)'"
            } elseif ($Target.csvPath) {
                $TargetDescription = "users in '$($Target.csvPath)'"
            } elseif ($Target.filter) {
                $TargetDescription = "users matching '$($Target.filter)'"
            } elseif ($Target.allUsers) {
                $TargetDescription = 'all users'
            } else {
                Write-Error "Plan '$($Plan.Name)' does not define a supported target." @StopParameters
                continue
            }

            if (-not $PSCmdlet.ShouldProcess("plan '$($Plan.Name)' for $TargetDescription", "Apply shortcut state '$($Plan.State)'")) {
                continue
            }

            try {
                if ($Target.groupId) {
                    $Users = @(Get-odscTargetUser -GroupId $Target.groupId -ErrorAction Stop)
                } elseif ($Target.csvPath) {
                    $Users = @(Get-odscTargetUser -CsvPath $Target.csvPath -ErrorAction Stop)
                } elseif ($Target.filter) {
                    $Users = @(Get-odscTargetUser -Filter $Target.filter -ErrorAction Stop)
                } else {
                    $Users = @(Get-odscTargetUser -AllUsers -ErrorAction Stop)
                }
            } catch {
                Write-Error "Plan '$($Plan.Name)': unable to resolve $TargetDescription. $($_.Exception.Message)" @StopParameters
                continue
            }

            if ($Users.Count -eq 0) {
                Write-Warning "Plan '$($Plan.Name)' resolved no users."
                continue
            }

            $AssignmentParameters = @{
                User = $Users
                Uri = $Plan.Uri
                FolderPath = $Plan.FolderPath
                RelativePath = $Plan.RelativePath
                ShortcutName = $Plan.Name
                State = $Plan.State
                ConflictAction = $Plan.ConflictAction
                StopOnError = $StopOnError
                Confirm = $false
            }

            if ($Plan.DocumentLibraryId) { $AssignmentParameters.DocumentLibraryId = $Plan.DocumentLibraryId } else { $AssignmentParameters.DocumentLibrary = $Plan.DocumentLibrary }

            # Collect results as they arrive so the report is complete even if -StopOnError stops the run.
            Invoke-odscShortcutAssignment @AssignmentParameters | ForEach-Object {
                $Results.Add($_) | Out-Null
                $_
            }
        }
    } finally {
        if ($ReportPath) {
            Export-odscReport -InputObject $Results.ToArray() -Path $ReportPath -Format $OutputFormat
        }
    }
}
