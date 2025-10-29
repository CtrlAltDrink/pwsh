function Get-UserGroupMembership {
	<#
	.SYNOPSIS
		Get Group Membership of User Object.

	.DESCRIPTION
		Referencing either a user SamAccountName, or Serialized output from Find-ADObject, Return list groups user is a member of.
		Can filter based on string match with -Filter switch.
		Can filter for typical remote access groups with -Remote switch.

	.LINK
		Github Link	- https://raw.githubusercontent.com/CtrlAltDrink/pwsh/refs/heads/zero/functions/function-get-usergroupmembership.ps1
	
		Powershell Commandlets used:
			Get-ADUser		- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-aduser?view=windowsserver2025-ps
			Get-ADGroup		- https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adgroup?view=windowsserver2025-ps

	.PARAMETER UserName
		Search for SamAccountName matching this string.

	.PARAMETER FaoNumber
		Search for user that matches the number from the Find-ADObject Script.

	.PARAMETER Filter
		Filter results that match string. This is wild carded.
	
	.PARAMETER OGV
		Output using the Output-GridView Commandlet
	
	.PARAMETER Remote
		Filter Groups with VDI, VPN, and DUO.

	.PARAMETER OU
		Include OU in output.

	.PARAMETER Version
		Returns version, build, and source information.

	.PARAMETER Update
		Provices Update information.

	.EXAMPLE
		Get-UserGroupMembership -UserName smithb

		Description:
		Retrives groups for user smithb.

	.EXAMPLE
		GUGM smithb

		Description:
		Also retrives groups for user smithb.

	.EXAMPLE
		GUGM 2

		Description:
		References second object from Find-ADOject output and gets the groups for that user.

	.EXAMPLE
		GUGM smithb -OU

		Description:
		Retrives groups for user smithb and includes OU information.

	.NOTES
		Created by: Robert "R2" Rawers
		Contact:	rawersr@stancounty.com
	#>
	[CmdletBinding(DefaultParameterSetName = "StringSet")]
    	param (
			[Parameter(Position=0,Mandatory,ParameterSetName="StringSet")][string]$UserName,
			[Parameter(Position=0,Mandatory,ParameterSetName="IntSet")][int]$FaoNumber,
			[Parameter(Position=0,Mandatory,ParameterSetName="VersionSet")][switch]$version,
			[Parameter(Position=0,Mandatory,ParameterSetName="UpdateSet")][switch]$update,
			[Parameter(Position=1,ParameterSetName="StringSet")][Parameter(Position=1,ParameterSetName="IntSet")][string]$Filter,
			[Parameter(ParameterSetName="StringSet")][Parameter(ParameterSetName="IntSet")][switch]$OGV,
			[Parameter(ParameterSetName="StringSet")][Parameter(ParameterSetName="IntSet")][switch]$Remote,
			[Parameter(ParameterSetName="StringSet")][Parameter(ParameterSetName="IntSet")][switch]$OU
		)
	
	# Metadata
	$VerInfo = @{
			Version = "0.2.0"
			Build 	= "20251029"
			Source	= "https://raw.githubusercontent.com/CtrlAltDrink/pwsh/refs/heads/zero/functions/function-get-usergroupmembership.ps1"
	}

	# Update checker
	$TargetUri = $VerInfo.Source
	if($true -ne $global:gugmupdchecked){
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
		$global:gugmupdchecked = $true
	}


	#Start Script Below here =================================================================================================================
	$results 	= $null
	$groups		= $null

	switch ($PSCmdLet.ParameterSetName){
		"StringSet" {
			$user = Get-ADUser -Filter "SamAccountName -like '$($UserName)'" -Properties MemberOf
            $groups = $user.MemberOf | Sort-Object
		}

		"IntSet" {
			if (-not (Get-Variable -Name ADOlist -Scope Global -ErrorAction SilentlyContinue)) {
        		Write-host "The variable `$ADOlist does not exist. Please populate it before using -FaoNumber." -ForegroundColor Yellow;return
    		}

    		if (-not $ADOlist) {
        		Write-host "`$ADOlist is empty. Please populate it before using -FaoNumber." -ForegroundColor Yellow;return
    		}
			
			if ($FaoNumber -lt 1 -or $FaoNumber -gt $ADOlist.Count) {
            	Write-host "FaoNumber $FaoNumber is out of range. Valid range is 1..$($ADOlist.Count).";return
        	}
			$ListNumber = $FaoNumber - 1

			$targetSam = $($ADOlist[$ListNumber].SamAccountName)
			$user = Get-ADUser -Identity $targetSam -Properties MemberOf
            $groups = $user.MemberOf | Sort-Object
		}

		"VersionSet" {
			$VerInfo;return
		}

		"UpdateSet" {
			Write-Host "Get the lastest version here $($VerInfo.Source)";return
		}
	}

	# Apply optional filters without turning strings into MatchInfo objects
    if ($remote) {
        $groups = $groups | Where-Object { $_ -match 'vpn|vdi|duo' }
    } elseif ($Filter) {
        $groups = $groups | Where-Object { $_ -match $Filter }
    }
	
	if ($ou) {
		$results = Foreach($line in $Groups) {
			Get-adgroup -Identity "$line" -Properties CanonicalName,Description | Select-object SamaccountName,@{Name="Location";Expression={$_.CanonicalName -replace '.stanislaus.ca.us','' -replace '/',' ▶ '}},Description
		}
	} else {
		$results = Foreach($line in $Groups) {
			Get-adgroup -Identity "$line" -Properties Description | Select-object SamaccountName,Description
		}
	}

	switch($OGV){
		$true {$results | Sort-Object SamAccountName | OGV}
		$false {$results | Sort-Object SamAccountName}
	}
}
$AliasParams = @{
    Name            = "GUGM"
    Value           = "Get-UserGroupMembership"
    Description     = "Get User group membership information for a user. Can also filter for specific keywords. Can use items references from Find-ADObject"
}
New-Alias @AliasParams
