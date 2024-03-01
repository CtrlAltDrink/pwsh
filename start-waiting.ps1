function start-waiting {
	[CmdletBinding()]
	param ([Parameter()][int]$seconds=10,[Parameter()][string]$verb="Waiting")
	$a=1; Write-host "$verb" -NoNewline; Do{Write-host "." -NoNewline; Start-Sleep 1; $a++} while($a -le $seconds)
}
