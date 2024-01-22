function Start-AADDeltaSync {
	#Defaults
		[string]$AADConnector = "" #server name or FQDN

	#if no defaults, prompt
		if(!($AADConnector)){[string]$AADConnector = Read-Host -Prompt "Enter name of Connector Server"}
		if(!($Credentials)){$Credentials = Get-Credential}
	
	#the work
		Invoke-Command -ComputerName $AADConnector -Credential $Credentials -ScriptBlock {
			do {
				Write-Host "Attempting Sync" -ForegroundColor Green;
				Start-Sleep -Seconds 5;
				$DeltaSync = Start-ADSyncSyncCycle -PolicyType Delta;
			} until ($DeltaSync.Result -eq "Success");
			Write-Host "Sync request has completed.";
		}
  }
