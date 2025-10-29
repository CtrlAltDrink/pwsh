function Find-ADObject {
	<#
	.SYNOPSIS
		Quick search tool for Active Directory objects.

	.DESCRIPTION
		This takes an string input and uses the Get-ADObject commandlet to for matches to that string.
		Once it has a list it will output that in a numerized table format by object type.
		It can indicate if an object is enabled or lockedout.
		Table is available for other scripts to use as $ADOList.
		Use -Last to output last search results

	.LINK
		Internal Gitea Link	- https://raw.githubusercontent.com/CtrlAltDrink/pwsh/refs/heads/zero/functions/function-Find-ADObject.ps1
	
		Powershel Commandlets used:
			Get-ADComputer	- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adcomputer?view=windowsserver2025-ps
			Get-ADDomain	- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-addomain?view=windowsserver2025-ps
			Get-ADObject	- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adobject?view=windowsserver2022-ps
			Get-ADUser		- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser?view=windowsserver2025-ps
			Write-Error		- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-error?view=powershell-7.5
			Write-Host		- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host?view=powershell-7.5
			Write-Warning	- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-warning?view=powershell-7.5

	.PARAMETER SearchFor
		Alias: S

		All searches can be partial.
		Can search for users by Name, Display Name, SamAccountName, Email, or Employee number.
		Can Search for computers by Name, Display Name, SamAccountName.

	.PARAMETER OU
		Alias: O
		
		Switch used to include OU of object.

	.PARAMETER Description
		Alias: Desc,D	
		
		Switch used to include Description property of object.

	.PARAMETER Full
		Alias: F
		
		Switch to include all information.

	.PARAMETER Version
		Returns version, build, and source information.

	.PARAMETER Update
		Provices Update information.

	.PARAMETER Last
		Outputs last Search to screen.
		
	.NOTES
		Created by:	Robert "R2" Rawers
		Contact:	rawersr@stancounty.com
	#>
	[CmdletBinding()]
	param (
		[alias("S")][string]$SearchFor=$env:USERNAME,
		[alias("O")][switch]$OU,
		[alias("Desc","D")][switch]$Description,
		[alias("F")][switch]$Full,
		[switch]$Version,
		[switch]$update
	)
	# Metadata
	$VerInfo = @{
			Version = "0.2.0"
			Build 	= "20250923"
			Source	= "https://raw.githubusercontent.com/CtrlAltDrink/pwsh/refs/heads/zero/functions/function-Find-ADObject.ps1"
	}

	# Update checker
	$TargetUri = $VerInfo.Source
	if($true -ne $global:faoupdchecked){
		try {
			$WebContent = Invoke-WebRequest -Uri $TargetUri
			$WebVersion = ($WebContent.Content -split "`n" | Select-String -Pattern "version =").Line.split("=")[1].replace('"','').trim()
			If($VerInfo.Version -lt $WebVersion){
				Write-host "`nThere is an update available for this module. See help for information." -ForegroundColor Yellow
				Write-host "Installed version is $($VerInfo.Version), version $WebVersion available.`n" -ForegroundColor Yellow
			}
		}
		catch {

		}
		# sets this var to true and will not recheck as long as terminal remains open.
		$global:faoupdchecked = $true
	}

	# Used for giving version information
	If($version){
		$VerInfo;return
	}

	# Used to give update information
	If($update){
		Write-Host "Get the lastest version here $($VerInfo.Source)";return
	}

	if($last){
		if ($ADOList.count -eq 0) {Write-host "Last search is unavailable. Please try a new search" -ForegroundColor Yellow;return}
		$ADOList | Format-Table -AutoSize;return
	}

	# Test if able to communicate with a domain controller
	try {
		Get-AdDomain | Out-Null
	}
	catch {
		Write-Error $Error[0]
		Write-Warning "Check your internet or vpn connection";pause;return
	}

	# Main script
	$i = 1
	Write-Host "Key: 💻 - Computers || 🕋 - DNSNODE || 👥 - Groups || 👤 - Users || 🔻 - Disabled || 🔒 - Lockedout" -ForegroundColor Green
	$script:ADOList = Get-ADObject -Filter "Name -like '*$SearchFor*' -or SamAccountName -like '*$SearchFor*' -or Mail -like '*$SearchFor*' -or EmployeeID -like '*$SearchFor*' -or DisplayName -like '*$SearchFor*'" -Properties SamAccountName,Description,CanonicalName,DistinguishedName,Mail,EmployeeID,DisplayName | Sort-Object ObjectClass,CanonicalName | Foreach-object {
		$Object = $_ | Select-Object num,Type,Name,EmployeeID,SamAccountName,Mail,CanonicalName,Description,Enabled,LockedOut
		if ($_.objectClass -eq "user"){
			$TmpUsr = Get-ADUser -Identity $_.SamAccountName -Properties Enabled,LockedOut
			$Object.Enabled = $TmpUsr.enabled
			$Object.LockedOut = $tmpUsr.LockedOut
		}
		if ($_.objectClass -eq "computer"){$Object.Enabled = (
			get-adComputer -Identity $_.SamAccountName).enabled
		}
		
		$Object.CanonicalName = $Object.CanonicalName -replace '.stanislaus.ca.us','' -replace '/',' ▶ '
		
		$Object.num = $i
		If ($_.ObjectClass -eq "user") {$Object.Type = "👤"}
		If ($_.ObjectClass -eq "group") {$Object.Type = "👥"}
		If ($_.ObjectClass -eq "dnsNode") {$Object.Type = "🕋"}
		If ($_.ObjectClass -eq "computer") {$Object.Type = "💻"}
		If ($false -eq $Object.Enabled) {$Object.Type = $Object.Type + "🔻"}
		If ($true -eq $Object.LockedOut) {$Object.type = $Object.Type + "🔒"}
		
		$selectOptions = "num","Type","Name","EmployeeID","SamAccountName","Mail"
		If($OU){$selectOptions += "CanonicalName"}
		If($Description){$selectOptions += "Description"}
		If($Full){$selectOptions += "CanonicalName","Description"}

		$Object = $Object | Select-Object $selectOptions
		$Object

		$i++
	} 
	$ADOList | Format-Table -AutoSize
}
$AliasParams = @{
    Name            = "FAO"
    Value           = "Find-ADObject"
    Description     = "Tool to find ad objects matching Name, SamAccountName, Mail, EmployeeID or DisplayName."
}
New-Alias @AliasParams
