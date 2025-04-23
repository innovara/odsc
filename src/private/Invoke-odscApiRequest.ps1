function Invoke-odscApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Resource,

        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method,

        [Parameter(Mandatory = $false)]
        [string] $Body,

        [Parameter(Mandatory = $false)]
        [switch] $DoNotUsePrefer
    )

    begin {
        $Token = $script:ODSToken

        if ((!$Token.ExpiresOn) -or 
        (!$Token.AccessToken) -or
        ($Token.ExpiresOn -le (Get-Date))) {
            Write-Verbose "Token: ${Token}"
            Write-Error "Please run Connect-odsc first." -ErrorAction Stop
        }
    }

    process {
        $Request = @{
            Uri = "https://graph.microsoft.com/v1.0/$($Resource)"
            ContentType = "application/json"
            Headers = @{
                Authorization = "Bearer $($Token.AccessToken)"
            }
            Method = $Method
        }

        if (!($DoNotUsePrefer.IsPresent)) {
            $Request.Headers.Prefer = "apiversion=2.1"
        }

        if ($Body) {
            $Request.Body = $Body
        }

        $Response = $null

        try {
            $Response = Invoke-WebRequest @Request
            $Response = ConvertFrom-Json $([string]::new($Response.Content))
        } catch {
            Write-Error $_
        }

        return $Response
    }

    end {

    }
}
