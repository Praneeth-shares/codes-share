Function Mark-NePIS-Account()
<#

.SYNOPSIS
Mark a NePIS account as migrated. The details will show up in the NePIS UI.

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
None

.PARAMETERS
sid_key - the account's unique sid_key from NePIS
safe_name - the name of the safe the account got vaulted in
account_name - the name of the CyberArk account
notes - any extra notes to add about this migration (optional)

.EXAMPLE
Mark-NePIS-Account -sid_key $account.sid_key -safe_name $safe.Indentifier -account_name $account.Name -migrated_by 720648 -migrated_at 01/25/2021

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 01/25/2021

#>

{
	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[int]$sid_key,
		
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$safe_name,

		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$account_name,

		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$verification_result,

		[parameter(
			Mandatory = $false,
			ValueFromPipeline = $false
		)]
		[string]$notes
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

	# Build parameters for NePIS API request
	$uri = "$($global:nepis_url)/api/migrated";
	$headers = @{};
	$form = @{
		"sid_key" = $sid_key;
		"safe_name" = $safe_name;
		"account_name" = $account_name;
		"migrated_by" = $env:UserName -replace "[a-zA-Z]";
		"migrated_at" = Get-Date -format "MM/dd/yyyy";
		"migration_verified" = $verification_result;
		"notes" = $notes;
	};
	
	# $form | ConvertTo-Json -Depth 10; # View data for debugging

	# Make request and check result is not null and is powershell object, must have failed if otherwise
	$result = Invoke-RestMethod -Uri $uri -Method Get -Body $form -Headers $headers -WebSession $global:nepis_session;
	if($null -ne $result -and $result.getType() -eq [System.String]){
		if($result -match "success"){
			# Write-Host "Account $($account_name) ($($sid_key)) marked as migrated." -ForegroundColor Green;
		} else {
			Write-Host "Account $($account_name) ($($sid_key)) could not be marked as migrated: $($result). Please mark manually in NePIS." -ForegroundColor Red;
		}
	}
}