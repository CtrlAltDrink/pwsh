function Find-ADobject {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)][string]$SearchFor
	)
	$DomainNameFilter = ""
	$i = 1
	Write-Host "Key: 💻 - Computers || 🕋 - DNSNODE || 👥 - Groups || 👤 - Users" -ForegroundColor Green
	Get-ADObject -Filter "Name -like '*$SearchFor*' -or SamAccountName -like '*$SearchFor*' -or Mail -like '*$SearchFor*'" -Properties SamAccountName,Description,CanonicalName,DistinguishedName,Mail | Sort-Object ObjectClass,CanonicalName | Foreach-object {
		$Object = $_ | Select-Object num,OC,Name,SamAccountName,Mail,CanonicalName,Description
		$Object.CanonicalName = $Object.CanonicalName -replace '$DomainNameFilter','' -replace '/',' ▶ '
		$Object.num = $i
		
		If ($_.ObjectClass -eq "user") {$Object.OC = " 👤 ";$Object}
		If ($_.ObjectClass -eq "group") {$Object.OC = "👥👥";$Object}
		If ($_.ObjectClass -eq "dnsNode") {$Object.OC = " 🕋 ";$Object}
		If ($_.ObjectClass -eq "computer") {$Object.OC = " 💻 ";$Object}
		
		$i++
    } | FT
}
