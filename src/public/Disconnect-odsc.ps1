function Disconnect-odsc {
	[CmdletBinding()]
	param()

	begin {

	}

	process {
		$PsCmdlet.SessionState.PSVariable.Set('_ODSToken', $null)
	}

	end {
		Write-Host "Disconnected."
	}
}