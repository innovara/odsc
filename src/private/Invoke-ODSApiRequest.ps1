function Invoke-ODSApiRequest {
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
        $Token = $PsCmdlet.SessionState.PSVariable.GetValue('_ODSToken')

        if ((!$Token.ExpiresOn) -or 
        (!$Token.AccessToken) -or
        ($Token.ExpiresOn -le (Get-Date))) {
            Write-Verbose "Token: ${Token}"
            Write-Error "Please run Connect-ODS first." -ErrorAction Stop
        }
    }

    process {
        $Request = @{
            Uri = "https://graph.microsoft.com/beta/$($Resource)"
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