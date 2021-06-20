function Migrate-NePIS-Applications {
	
	."./functions-NePIS/Function-Create-NePIS-Session.ps1"
	."./functions-NePIS/Function-Get-NePIS-Export.ps1"
	."./functions-NePIS/Function-Get-NePIS-Platform-Map.ps1"
	."./functions-NePIS/Function-Process-NePIS-Data.ps1"
#	."./functions-Form/Function-Edit-Safes-Accounts.ps1"
	."./functions-Nepis/Function-Edit-Safes-Accounts.ps1"
	."./functions-NePIS/Function-Vault-NePIS-Data.ps1"
	."./functions-NePIS/Function-Get-Meta-Migration-Info.ps1"
	."./functions-CyberArk/Function-Create-CyberArk-Session.ps1"
	."./functions-CAAM/Function-Send-Email.ps1"

	# Get NePIS Session (via WebSeal)
	#if(-not (Create-NePIS-Session)){
	#	return;
	#}

	# Get Meta Info about the migration (ritm, application, pcf info)
	Get-Meta-Migration-Info;
	if($null -eq $global:migration_meta){
		return;
	}
	$application_name = $global:migration_meta.application_name;
	
	# Function to log info to a file, used in following functions
	$log_path = "$($global:files_drive)$($global:log_files_path)\$($MyInvocation.MyCommand)\$(Get-Date -format "yyyy-MM-dd")-Migrate-$($global:migration_meta.application_name)-By-$($env:username).txt";
	if (!(Test-Path $log_path)){
		New-Item $log_path -Force | Out-Null;
	}
	function log($string){
		$time_string = Get-Date -format "[yyyy-MM-dd HH:mm K]";
		Add-Content -Path $log_path -Value "$($time_string) $($string)" -Force;
		# Write-Host $string -ForegroundColor Magenta
	}	
	log "===== Starting Migration ($($global:migration_meta.ritm) by $($env:username)) =====";

	# $global:migration_meta | ConvertTo-Json -Depth 10; # View data for debugging

	# Get credential data from NePIS
	$result = Get-NePIS-Export $application_name;
	if($null -eq $result){
		return;
	}
	
	# $result | ConvertTo-Json -Depth 10; # View data for debugging

	# Process credential data to get CyberArk format data
	$result = [System.Collections.ArrayList]@(Process-NePIS-Data $result);
	
	# Get DAP platforms
	$global:platforms = [System.Collections.ArrayList]@()
	foreach($platform in ((Get-NePIS-Platform-Map "prod").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}
	foreach($platform in ((Get-NePIS-Platform-Map "nonprod").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}
	foreach($platform in ((Get-NePIS-Platform-Map "prod_virtualname").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}
	foreach($platform in ((Get-NePIS-Platform-Map "nonprod_virtualname").Values | Select-Object -Unique)){
		$global:platforms.Add($platform) | Out-Null;
	}



	# Show form to user to confirm and fill in missing data
	$result = @(Edit-Safes-Accounts $result);
	
	# $result | ConvertTo-Json -Depth 10; # View data for debugging
	
	# Check that there is data to upload to CyberArk
	if($result.count -eq 0){
		Write-Host "No data was selected to migrate." -ForegroundColor Yellow;
		return;
	}

	# Create CyberArk Session
	if(-not (Create-CyberArk-Session)){
		return;
	}

	# Insert the data into CyberArk 
	Vault-NePIS-Data($result);

	# Send Email
	Send-Email -LogFile $log_path -JobName $MyInvocation.MyCommand;

}