function Create-DAP-Safes-Accounts {
	
	."./functions-NePIS/Function-Get-NePIS-Platform-Map.ps1"
#	."./functions-Form/Function-Edit-Safes-Accounts.ps1"
	."./functions-Nepis/Function-Edit-Safes-Accounts.ps1"
	."./functions-NePIS/Function-Vault-NePIS-Data.ps1"
	."./functions-NePIS/Function-Get-Meta-Migration-Info.ps1"
	."./functions-CyberArk/Function-Create-CyberArk-Session.ps1"
	."./functions-CAAM/Function-Send-Email.ps1"

	# Get Meta Info about the migration (ritm, application, pcf info)
	Get-Meta-Migration-Info;
	if($null -eq $global:migration_meta){
		return;
	}

	."./functions-Form/Function-Edit-Safes-Accounts.ps1"
	."./functions-CyberArk/Function-Vault-CyberArk-Safe-Conjur.ps1"

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
	$global:platforms = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-NePIS-Platform-Map "prod").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}
	foreach($platform in ((Get-NePIS-Platform-Map "nonprod").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}

	$n_safes = [int](Read-Host "How many safes?");
	$n_accounts = [int](Read-Host "How many accounts?");
	$include_port = [bool]((Read-Host "Include Port Field? (y/n)") -match "y")

	$accounts = [System.Collections.ArrayList]@();
	for($i = 0; $i -lt $n_accounts; $i++){
		$account = [PSCustomObject]@{
			Name = "";
			Username = "";
			Password = "";
			Platform = "";
			Address = "";
		}
		if($include_port){
			Add-Member -InputObject $account -NotePropertyName Port -NotePropertyValue "";
		}
		$accounts.add($account) | Out-Null;
	}

	$safes = [System.Collections.ArrayList]@();
	for($i = 0; $i -lt $n_safes; $i++){
		$safes.add([PSCustomObject]@{
			Application = $global:migration_meta["application_name"];
			Identifier = "";
			Description = "";
			Region = "";
			Accounts = $accounts;
		}) | Out-Null;
	}

	# Show form to user to confirm and fill in missing data
	$result = @(Edit-Safes-Accounts $safes);
	
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