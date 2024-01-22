function Find-ADobject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][string]$SearchFor
    )
    $i = 1
    Get-ADObject -Filter "Name -like '*$SearchFor*' -or SamAccountName -like '*$SearchFor*'" -Properties SamAccountName,Description,CanonicalName,DistinguishedName | Sort-Object ObjectClass,CanonicalName | Foreach-object {
        $Object = $_ | Select-Object num,OC,Name,SamAccountName,CanonicalName,Description
        $Object.CanonicalName = $Object.CanonicalName -replace '.stanislaus.ca.us','' -replace '/',' ▶ '
        $Object.num = $i
        
        If ($_.ObjectClass -eq "user") {$Object.OC = "👤";$Object}
        If ($_.ObjectClass -eq "group") {$Object.OC = "👥";$Object}
        #If ($_.ObjectClass -eq "dnsNode") {$Object.OC = $_.ObjectClass;$Object}
        If ($_.ObjectClass -eq "computer") {$Object.OC = "💻";$Object}
        
        $i++
    } | FT
}