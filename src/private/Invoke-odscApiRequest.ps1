function Invoke-odscApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Resource,

        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method,

        [Parameter(Mandatory = $false)]
        [object] $Body,

        [Parameter(Mandatory = $false)]
        [hashtable] $Headers,

        [Parameter(Mandatory = $false)]
        [switch] $DoNotUsePrefer,

        [Parameter(Mandatory = $false)]
        [switch] $AllPages,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 10)]
        [int] $MaxRetryCount = 5,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 300)]
        [int] $RetryDelaySeconds = 2
    )

    begin {
        $Token = $script:ODSToken

        if ((!$Token.ExpiresOn) -or
        (!$Token.AccessToken) -or
        ($Token.ExpiresOn -le (Get-Date))) {
            Write-Verbose 'No usable Microsoft Graph token is available.'
            Write-Error 'Please run Connect-odsc first.' -ErrorAction Stop
        }
    }

    process {
        $RequestHeaders = @{
            Authorization = "Bearer $($Token.AccessToken)"
        }

        if (!($DoNotUsePrefer.IsPresent)) {
            $RequestHeaders.Prefer = 'apiversion=2.1'
        }

        if ($Headers) {
            foreach ($Key in $Headers.Keys) {
                $RequestHeaders[$Key] = $Headers[$Key]
            }
        }

        $GraphEndpoint = if ($script:ODSGraphEndpoint) { $script:ODSGraphEndpoint.TrimEnd('/') } else { 'https://graph.microsoft.com' }
        $Uri = if ($Resource -match '^https://') { $Resource } else { "$GraphEndpoint/v1.0/$($Resource)" }
        $Results = New-Object System.Collections.Generic.List[object]
        $NextUri = $Uri

        do {
            $Attempt = 0
            $Response = $null
            $Succeeded = $false

            while (-not $Succeeded) {
                $Request = @{
                    Uri = $NextUri
                    ContentType = 'application/json'
                    Headers = $RequestHeaders
                    Method = $Method
                    UseBasicParsing = $true
                }

                if ($Body -and $NextUri -eq $Uri) {
                    $Request.Body = ConvertTo-odscJsonBody -Body $Body
                }

                try {
                    $RawResponse = Invoke-WebRequest @Request
                    $Content = $RawResponse.Content
                    if ($Content -is [byte[]]) {
                        $Content = [System.Text.Encoding]::UTF8.GetString($Content)
                    }

                    $Response = if ([string]::IsNullOrWhiteSpace($Content)) {
                        $null
                    } else {
                        ConvertFrom-Json -InputObject $Content
                    }
                    $Succeeded = $true
                } catch {
                    $Attempt++
                    $StatusCode = $null
                    $RetryAfter = $null
                    $GraphRequestId = $null

                    if ($_.Exception.Response) {
                        try { $StatusCode = [int]$_.Exception.Response.StatusCode } catch { $StatusCode = $null }
                        $RetryAfter = Get-odscRetryAfterDelay -Response $_.Exception.Response
                        $GraphRequestId = Get-odscResponseHeader -Response $_.Exception.Response -Name 'request-id'
                    }

                    $IsTransient = $StatusCode -in @(429, 500, 502, 503, 504)
                    if (($Attempt -le $MaxRetryCount) -and $IsTransient) {
                        $Delay = if ($null -ne $RetryAfter) { $RetryAfter } else { [Math]::Min(300, ($RetryDelaySeconds * [Math]::Pow(2, ($Attempt - 1)))) }
                        Write-Verbose "Microsoft Graph request was throttled or transiently failed with HTTP $StatusCode. Retrying in $Delay seconds. RequestId: $GraphRequestId"
                        Start-Sleep -Seconds $Delay
                    } else {
                        $Message = "Microsoft Graph request failed. Method: $Method. Resource: $Resource. StatusCode: $StatusCode. RequestId: $GraphRequestId. Error: $($_.Exception.Message)"
                        Write-Error $Message -ErrorAction Stop
                    }
                }
            }

            if ($AllPages -and $Response -and ($null -ne $Response.value)) {
                foreach ($Item in $Response.value) {
                    $Results.Add($Item) | Out-Null
                }
                $NextUri = $Response.'@odata.nextLink'
                $Method = [Microsoft.PowerShell.Commands.WebRequestMethod]::Get
                $Body = $null
            } else {
                return $Response
            }
        } while ($AllPages -and $NextUri)

        return $Results.ToArray()
    }
}
