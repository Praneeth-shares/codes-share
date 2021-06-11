function New-CyberArk-Safe-Standard {
	
	."./functions-CAAM/Function-Send-Email.ps1"
	."./functions-CyberArk/Function-Create-CyberArk-Session.ps1"
	."./functions-CyberArk/Function-Vault-CyberArk-Safe-Standard.ps1"
	."./functions-CyberArk/Function-Get-CyberArk-Platform-Map-Account-Standard.ps1"	
	."./functions-Form/Function-Edit-CyberArk-Safe-Standard-Accounts.ps1"
	."./functions-Form/Function-Get-Meta-Info-CyberArk-Safe-Standard.ps1"

	# Get Meta Info about the migration (ritm, application, pcf info)
	Get-Meta-Info-CyberArk-Safe-Standard;
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
	
	# Get Standard platforms
	$global:platforms_personal = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "personal").Values | Select-Object -Unique)){
		$global:platforms_personal.Add($platform) | Out-Null;
	}
	$global:platforms_production = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod").Values | Select-Object -Unique)){
		$global:platforms_production.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod").Values | Select-Object -Unique)){
		$global:platforms_nonproduction.Add($platform) | Out-Null;
	}
	$global:platforms_production_database = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_database").Values | Select-Object -Unique)){
		$global:platforms_production_database.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_database = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_database").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_database.Add($platform) | Out-Null;
	}
	$global:platforms_production_unix = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_unix").Values | Select-Object -Unique)){
		$global:platforms_production_unix.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_unix = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_unix").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_unix.Add($platform) | Out-Null;
	}
	$global:platforms_production_windows = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_windows").Values | Select-Object -Unique)){
		$global:platforms_production_windows.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_windows = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_windows").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_windows.Add($platform) | Out-Null;
	}
	$global:platforms_production_mainframe = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_mainframe").Values | Select-Object -Unique)){
		$global:platforms_production_mainframe.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_mainframe = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_mainframe").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_mainframe.Add($platform) | Out-Null;
	}
	$global:platforms_production_application = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_application").Values | Select-Object -Unique)){
		$global:platforms_production_application.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_application = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_application").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_application.Add($platform) | Out-Null;
	}
	$global:platforms_production_cloud = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_cloud").Values | Select-Object -Unique)){
		$global:platforms_production_cloud.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_cloud = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_cloud").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_cloud.Add($platform) | Out-Null;
	}
	$global:platforms_production_saas = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "prod_saas").Values | Select-Object -Unique)){
		$global:platforms_production_saas.Add($platform) | Out-Null;
	}
	$global:platforms_nonproduction_saas = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-CyberArk-Platform-Map-Account-Standard "nonprod_saas").Values | Select-Object -Unique)){
		$global:platforms_nonproduction_saas.Add($platform) | Out-Null;
	}

	# Determine final safe identifier
	Switch ($global:migration_meta.application_region)
	{
		"production" {
				Switch ($global:migration_meta.application_platform)
				{
					"Database" {$safe_prefix="1_H_D_"}
					"Unix" {$safe_prefix="1_H_U_"}
					"Windows" {$safe_prefix="1_H_W_"}
					"Mainframe" {$safe_prefix="1_H_M_"}
					"Cloud" {$safe_prefix="1_H_C_"}
					"SaaS" {$safe_prefix="1_H_S_"}
					"Application" {$safe_prefix="1_H_A_"}
				}
			}
		"non-production" {
				Switch ($global:migration_meta.application_platform)
				{
					"Database" {$safe_prefix="2_H_D_"}
					"Unix" {$safe_prefix="2_H_U_"}
					"Windows" {$safe_prefix="2_H_W_"}
					"Mainframe" {$safe_prefix="2_H_M_"}
					"Cloud" {$safe_prefix="2_H_C_"}
					"SaaS" {$safe_prefix="2_H_S_"}
					"Application" {$safe_prefix="2_H_A_"}
				}	
			}
		"personal" {
				$safe_prefix="P_"
				}
	}
	$safe_identifier = $global:migration_meta.application_name
	$safe_identifier = if ($safe_identifier.length -gt 22) {$safe_identifier.substring(0, 22)} else {$safe_identifier}
	$safe_identifier = $safe_identifier.replace(" ","_")
	$safe_identifier = $safe_prefix + $safe_identifier
	
	$paccounts = [System.Collections.ArrayList]@();
	if($global:migration_meta.include_secondary){ 
		$paccount = [PSCustomObject]@{
			Name = "j"+$global:migration_meta.application_name+"-dsglobal";
			Username = "j"+$global:migration_meta.application_name;
			Password = "";
			Platform = "WindowsPersonal20Hours";
			Address = "dsglobal.org";
		}
		$paccounts.add($paccount) | Out-Null;
	}
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

	$safes = [System.Collections.ArrayList]@();
	for($i = 0; $i -lt $global:migration_meta.number_of_safes; $i++){
		If("personal" -eq $global:migration_meta.application_region){
			$safes.add([PSCustomObject]@{
				Application = $global:migration_meta["application_name"];
				Identifier = $safe_identifier;
				Description = $global:migration_meta.application_unid;
				Accounts = $paccounts;
			}) | Out-Null;
		} Else {
			$safes.add([PSCustomObject]@{
				Application = $global:migration_meta["application_name"];
				Identifier = $safe_identifier;
				Description = $global:migration_meta.application_unid;
				Platform = $global:migration_meta.application_platform;
				Region = $global:migration_meta.application_region;
				Accounts = $paccounts;
			}) | Out-Null;
		}
	}

	# Show form to user to confirm and fill in missing data
	$result = @(Edit-CyberArk-Safe-Standard-Accounts $safes);
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
	Vault-CyberArk-Safe-Standard($result);

	# Send Email
	Send-Email -LogFile $log_path -JobName $MyInvocation.MyCommand;

}