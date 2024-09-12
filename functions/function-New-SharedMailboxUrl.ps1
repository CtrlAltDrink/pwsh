function New-SharedMailboxURL {
	[CmdletBinding()]
	param (
		[Parameter()][String]$EmailAddress
	)
	[string]$Output = "
	
	Please wait an hour then log off then back on. This will refresh your permissions and allow you to access the mailbox.
	
	You can wait up to 48 hours to allow the mailbox to automatically appear in outlook or you can follow guide below to add the mailbox manually:
	- Outlook Desktop Application: https://support.microsoft.com/en-us/office/open-and-use-a-shared-mailbox-in-outlook-d94a8e9e-21f1-4240-808b-de9c9c088afd
	- Outlook on the Web: https://support.microsoft.com/en-us/office/open-and-use-a-shared-mailbox-in-outlook-on-the-web-98b5a90d-4e38-415d-a030-f09a4cd28207

	If you'd like to access the mailbox directly, you can use the link below:

	https://outlook.office365.com/mail/$EmailAddress
	
	"

	$Output | Set-Clipboard
	Write-Host "$emailaddress set"
}
