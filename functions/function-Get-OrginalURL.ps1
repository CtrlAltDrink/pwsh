function Get-OrginalURL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]
        $OrginalURL
    )

# URL check to see it will work
IF(!($OrginalURL -like "https://gcc02.safelinks.protection.outlook.com/?url=*")){Write-host "`nThis tool wont work for this URL :(`n" -ForegroundColor Red;pause;exit}

# URL decode the string
$decodedUrl1 = [System.Web.HttpUtility]::UrlDecode($OrginalURL).split('?url=')[1].split('&data=')[0]
$decodedUrl2 = $decodedUrl1.split('/')[2]
# Output the decoded URL
Write-host @"

==============================================
| URL OPTIONS                                |
==============================================
"@ -ForegroundColor DarkGreen
Write-Host "1 - URL     - $decodedUrl1" -ForegroundColor DarkGreen
Write-host "2 - Domain  - $decodedUrl2" -ForegroundColor DarkGreen
$x = read-host -Prompt "`nEnter choice above to copy, any other key to exit"
switch ($x) {
    1 { $decodedUrl1 | Out-String | Set-Clipboard; Write-Host "`nCopied -> $decodedUrl1" -ForegroundColor Yellow }
    2 { $decodedUrl2 | Out-String | Set-Clipboard; Write-Host "`nCopied -> $decodedUrl2" -ForegroundColor Yellow }
    Default { Write-Host "`nNothing copied, have a good day!" -ForegroundColor Yellow}
}
}

New-Alias -Name ourl -Value "Get-OrginalURL"
