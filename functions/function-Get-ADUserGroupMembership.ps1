function Get-ADUserGroupMembership {
	[CmdletBinding()]
    	param (
	[Parameter(Mandatory)][string]$UserName,
	[Parameter()][string]$match
	)
	If($match){Get-Aduser -filter "SamAccountName -like '$UserName'" -properties MemberOf | Select-Object -ExpandProperty MemberOf | Sort-Object MemberOf | Select-String -Pattern $match}
	Else{Get-Aduser -filter "SamAccountName -like '$UserName'" -properties MemberOf | Select-Object -ExpandProperty MemberOf | Sort-Object MemberOf}
}
