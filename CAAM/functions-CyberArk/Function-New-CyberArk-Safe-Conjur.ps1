function New-CyberArk-Safe-Conjur {
	
	#."./functions-CAAM/Function-Get-Conjur-Platform-Map.ps1"
	."./functions-CAAM/Function-Send-Email.ps1"
	."./functions-CyberArk/Function-Create-CyberArk-Session.ps1"
	."./functions-CyberArk/Function-Vault-CyberArk-Safe-Conjur.ps1"
	."./functions-CyberArk/Function-Get-CyberArk-Platform-Map-Account-Conjur.ps1"	
	."./functions-Form/Function-Edit-CyberArk-Safe-Conjur-Accounts.ps1"
	."./functions-Form/Function-Get-Meta-Info-CyberArk-Safe-Conjur.ps1"

	# Get Meta Info about the migration (ritm, application, pcf info)
	Get-Meta-Info-CyberArk-Safe-Conjur;
	if($null -eq $global:migration_meta){
		return;
	}

	# Function to log info to a file, used in following functions
	$log_path = "$($global:files_drive)$($global:log_files_path)\$($MyInvocation.MyCommand)\$(Get-Date -format "yyyy-MM-dd")-Migrate-$($global:migration_meta.application_name)-By-$($env:username).txt";
	if (!(Test-Path $log_path)){
		New-Item $log_path -Force | Out-Null;
	}
	function log($string){
		$time_string = Get-Date -format "[yyyy-MM-dd HH:mm K]";
		Add-Content -Path $log_path -Value "$($time_string) $($string)";
		# Write-Host $string -ForegroundColor Magenta
	}	
	log "===== Starting Migration ($($global:migration_meta.ritm) by $($env:username)) =====";
	
	# Get DAP platforms
	$global:platforms_production = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Conjur "prod").Values | Select-Object -Unique)){
		$global:platforms_production.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Conjur "nonprod").Values | Select-Object -Unique)){
		$global:platforms_nonproduction.Add($platform) | Out-Null;
	}
	$global:platforms_production_virtualname = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Conjur "prod_virtualname").Values | Select-Object -Unique)){
		$global:platforms_production_virtualname.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_virtualname = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Conjur "nonprod_virtualname").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_virtualname.Add($platform) | Out-Null;
	}

#For Manual input only one safe is added
#	$n_safes = 1;
#	$n_safes = [int](Read-Host "How many safes?");
#	$p_accounts = [int](Read-Host "How many password accounts?");
#	$include_port = [bool]((Read-Host "Include Port Field? (y/n)") -match "y")
#	$k_accounts = [int](Read-Host "How many APIKey accounts?");
#	$p_accounts = "";

	# Determine final safe identifier
	$safe_identifier = $global:migration_meta.application_name
	$safe_identifier = if ($safe_identifier.length -gt 24) {$safe_identifier.substring(0, 24)} else {$safe_identifier}
	Switch ($global:migration_meta.application_region)
	{
		"Production" {$safe_prefix="1_N_"}
		"Acceptance" {$safe_prefix="2_N_"}
		"Integration" {$safe_prefix="3_N_"}
		"Unit" {$safe_prefix="4_N_"}
		"Other" {$safe_prefix="5_N_"}
	}
	$safe_identifier = $safe_identifier.replace(" ","_")
	$safe_identifier = $safe_prefix + $safe_identifier
	
	$paccounts = [System.Collections.ArrayList]@();
	for($i = 0; $i -lt $global:migration_meta.number_of_accounts_password; $i++){
		$paccount = [PSCustomObject]@{
			Name = "";
			Username = "";
			Password = "";
			Platform = "";
			Address = "";

		}
		if($global:migration_meta.include_port){
			Add-Member -InputObject $paccount -NotePropertyName Port -NotePropertyValue "";
		}
		if($global:migration_meta.include_virtualname){
			Add-Member -InputObject $paccount -NotePropertyName VirtualUsername -NotePropertyValue "";
			Add-Member -InputObject $paccount -NotePropertyName Index -NotePropertyValue 1;
			Add-Member -InputObject $paccount -NotePropertyName DualAccountStatus -NotePropertyValue "Active";

		}
		$paccounts.add($paccount) | Out-Null;
	}
	
#	for($i = 0; $i -lt $global:migration_meta.number_of_accounts_key; $i++){
#		$kaccount = [PSCustomObject]@{
#			Name = "";
#			Key = "";
#			Platform = "";
#		}
#		$accounts.add($kaccount) | Out-Null;
#	}

	If ("Traditional" -eq $global:migration_meta.application_type) {
		$safes = [System.Collections.ArrayList]@();
		for($i = 0; $i -lt $global:migration_meta.number_of_safes; $i++){
			$safes.add([PSCustomObject]@{
				Application = $global:migration_meta["application_name"];
				Identifier = $safe_identifier;
				Description = $global:migration_meta.application_unid;
				Region = $global:migration_meta.application_region;
				AppType = $global:migration_meta.application_type;
				Accounts = $paccounts;
			}) | Out-Null;
		}
	} else {
		if ("Production" -eq $global:migration_meta.application_region){
			$safes = [System.Collections.ArrayList]@();
			for($i = 0; $i -lt $global:migration_meta.number_of_safes; $i++){
				$safes.add([PSCustomObject]@{
					Application = $global:migration_meta["application_name"];
					Identifier = $safe_identifier;
					Description = $global:migration_meta.application_unid;
					Region = $global:migration_meta.application_region;
					AppType = $global:migration_meta.application_type;
					Foundation = $global:migration_meta.pcf_foundation;
					Org = $global:migration_meta.pcf_org_guid;
					Space = $global:migration_meta.pcf_space_guid;
					FoundationDR = $global:migration_meta.pcf_foundation_dr;
					OrgDR = $global:migration_meta.pcf_org_guid_dr;
					SpaceDR = $global:migration_meta.pcf_space_guid_dr;
					Accounts = $paccounts;
				}) | Out-Null;
			}
		} else {
			$safes = [System.Collections.ArrayList]@();
			for($i = 0; $i -lt $global:migration_meta.number_of_safes; $i++){
				$safes.add([PSCustomObject]@{
					Application = $global:migration_meta["application_name"];
					Identifier = $safe_identifier;
					Description = $global:migration_meta.application_unid;
					Region = $global:migration_meta.application_region;
					AppType = $global:migration_meta.application_type;
					Foundation = $global:migration_meta.pcf_foundation;
					Org = $global:migration_meta.pcf_org_guid;
					Space = $global:migration_meta.pcf_space_guid;
					Accounts = $paccounts;
				}) | Out-Null;
			}
		}

	}


	# Show form to user to confirm and fill in missing data
	$result = @(Edit-CyberArk-Safe-Conjur-Accounts $safes);
	# $result | ConvertTo-Json -Depth 10; # View data for debugging
	
	# Check that there is data to upload to CyberArk
	if($result.count -eq 0){
		Write-Host "No data was selected to vault." -ForegroundColor Yellow;
		return;
	}

	# Create CyberArk Session
	if(-not (Create-CyberArk-Session)){
		return;
	}

	# Insert the data into CyberArk 
	Vault-CyberArk-Safe-Conjur($result);

	# Send Email
	Send-Email -LogFile $log_path -JobName $MyInvocation.MyCommand;

}