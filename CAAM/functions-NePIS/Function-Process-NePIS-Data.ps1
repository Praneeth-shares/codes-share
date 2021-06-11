Function Process-NePIS-Data()
<#

.SYNOPSIS
Process exported credential data from NePIS into data needed for CyberArk. Example output:
[
	{
		"Identifier":  "2_N_Non_Personal_ID_Solution",
		"Description":  "6442c965cc88f100bcb88af21d479d81",
		"Region":  "acceptance",
		"RITM":  "RITM123456",
		"Accounts":  [
			{
				"sid_key": 143242,
				"Resource":  "sida@sida@ajaxlora1015_3",
				"Platform":  "Oracle20HourPolicy_EA",
				"Username":  "SIDADM",
				"Address":  "sida.oracle.db",
				"Port":  "50001",
				"Password":  "Wxrbp87#kcmaznh",
				"Name":  "SIDADM-sida.oracle.db"
			},
			...
		],
	},
	...
]

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
[Get-NePIS-Platform-Map] - Function-Get-NePIS-Platform-Map.ps1

.PARAMETERS
data - an object returned from Get-NePIS-Export

.EXAMPLE
Process-NePIS-Data $data

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 11/20/2020

#>

{
	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		$data
	)

	[OutputType([System.Collections.ArrayList])]

	# Parse NePIS Response
	$safes = [System.Collections.ArrayList]@();
	foreach($app_data in $data){
		
		# Basic safe information
		$app_name = $app_data.app_name;
		$region = $app_data.environment;
		$sys_id = $app_data.sys_id;	
		
		# Build safe identifier
		$safe_identifier = "";
		switch -wildcard ($region){
			
			"Production*" {
				$safe_identifier += "1_N_";
				break;
			}
			
			"Acceptance" {
				$safe_identifier += "2_N_";
				break;
			}
			
			"Integration" {
				$safe_identifier += "3_N_";
				break;
			}
			
			"Development" {
				$safe_identifier += "4_N_";
				break;
			}
			
			default {
				$safe_identifier += "5_N_";
				break;
			}
		}
		$safe_identifier += $app_name -replace "\s\([A-Za-z]{2,8}\)$"; # Remove "(ACCP)", "(PRD)", etc.
		$safe_identifier = $safe_identifier -replace "\s", "_"; # Replace spaces with underscores
		$safe_identifier = $safe_identifier.subString(0, [System.Math]::Min(28, $safe_identifier.Length))  # Trim to proper size
##
		$platform_map = $null;
		if($global:migration_meta.include_virtualname){
			if($region -match "Production*"){
				$platform_map = Get-NePIS-Platform-Map("prod_virtualname");
			} else {
				$platform_map = Get-NePIS-Platform-Map("nonprod_virtualname");
			}
		} else {
			if($region -match "Production*"){
				$platform_map = Get-NePIS-Platform-Map("prod");
			} else {
				$platform_map = Get-NePIS-Platform-Map("nonprod");
			}
		}

##
#if($region -match "Production*"){
#	$platform_map = Get-NePIS-Platform-Map("prod");
#} else {
#	$platform_map = Get-NePIS-Platform-Map("nonprod");
#}



		# Iterate accounts for application
		$accounts = [System.Collections.ArrayList]@();
		foreach($account_data in $app_data.accounts){
			
			$account = [PSCustomObject]@{
				MainApplication = $account_data.main_application;
				sid_key = $account_data.sid_key;
				Resource = $account_data.resource;
				Name = "";
				Username = $account_data.service_id;
				Password = $account_data.password;
				Platform = "";
				Address = "";
			};
##
			if($global:migration_meta.include_virtualname){
				Add-Member -InputObject $account -NotePropertyName VirtualUsername -NotePropertyValue "";
				Add-Member -InputObject $account -NotePropertyName Index -NotePropertyValue 1;
				Add-Member -InputObject $account -NotePropertyName DualAccountStatus -NotePropertyValue "Active";
			}	

			switch -wildcard ($account_data.platform){
				
				# SYBASE
				"*Sybase*" {
					
					$account.Platform = $platform_map["Sybase"];
					Add-Member -InputObject $account -NotePropertyName Port -NotePropertyValue $account_data.port;
										
					# Get address and account name
					$db_name = "";
					$account_data.resource -match "[a-z]{4,6}[0-9]{1,2}" | Out-Null;
					$db_name = $matches[0];
					# $account.Name = $account_data.service_id + "-" + $db_name;

					# Prod Sybases
					if($db_name -match "p"){
						$account.Address = $db_name + ".apptoapp.org";
					
					# NonProd Sybases
					} else {
						$account_data.resource -match "[a-z]{8}[0-9]{4}" | Out-Null;
						$server_name = $matches[0];

						# Try to connect to two domains to find out which is correct
						if($null -ne (Test-Connection "$($server_name).corp.citistreet.org" -Count 1 -ErrorAction "SilentlyContinue")){
							$account.Address = $server_name + ".corp.citistreet.org";
						} elseif ($null -ne (Test-Connection "$($server_name).dsglobal.org" -Count 1 -ErrorAction "SilentlyContinue")){
							$account.Address = $server_name + ".dsglobal.org";
						}						
					}

					# $account.Name = $account_data.service_id + "-" + $account.Address;
					
					break;
				}
				
				# ORACLE
				"*Oracle*" {
					
					$account.Platform = $platform_map["Oracle"];
					Add-Member -InputObject $account -NotePropertyName Port -NotePropertyValue $account_data.port;
										
					# Get address and account name
					$db_name = "";
					$split_resource = $account_data.resource.split('@');
					if($split_resource.length -ge 2){
						$db_name = $split_resource[0];
						$account.Address = $db_name + ".oracle.db";
						# $account.Name = $account_data.service_id + "-" + $db_name;
					}
					
					break;
				}
				
				# SQL
				"*SQL*" {
					
					$account.Platform = $platform_map["SQL"];
					Add-Member -InputObject $account -NotePropertyName Port -NotePropertyValue $account_data.port

					# Find Address
					$address = "";
					$first_at = $account_data.resource.indexOf('@');
					$last_at = $account_data.resource.lastIndexOf('@');
					if($first_at -lt $last_at){
						$address = $account_data.resource.substring($first_at + 1, $last_at - $first_at - 1);
						$address = $address.replace("\\", "\");
					} else {
						$address = "";
					}
					
					# Get Account Name
					# $name = "";
					# $backslash_index = $address.indexOf('\');
					# $address_end = $address.substring($backslash_index + 1, $address.length - $backslash_index - 1);
					# if($address_end -ne ""){
					#	$name = $account_data.service_id + "-" + $address_end
					# }

					# Assign account name
					if($account_data.resource -match "[a-zA-Z]{8}[0-9]{4}"){
						$account.Name = $account_data.service_id + "-" + $matches[0];
					}
										
					$account.Address = $address;
										
					break;
				}
				
				# DB2
				"*db2*" {
					
					$account.Platform = $platform_map["DB2"];
					Add-Member -InputObject $account -NotePropertyName Port -NotePropertyValue $account_data.port;
					
					$server = "";
					if($account_data.resource -match "[a-z]{8}[0-9]{4}|[a-z]{5}[0-9]{3}"){
						$server = $matches[0];
						# $account.Name = $account_data.service_id + "-" + $server;
					}
					$account.Address = $server;
					
					break;
				}

				# MAINFRAME 
				"*mainframe*" {
					
					$account.Platform = $platform_map["Mainframe"];
										
					# Get address and account name
					if($account_data.resource -match "[a-z]{2}[0-9]{2}"){
						$lpar = $matches[0].ToUpper();
						# $account.Name = $account_data.service_id + "-" + $lpar;
						$account.Address = $lpar;
					}
					
					break;
				}

				# WINDOWS
				{$_ -like "*windows*" -or $_ -like "*intel*"} {
					
					$account.Platform = $platform_map["Windows"];
					$account.Address = "dsglobal.org";
					# $account.Name = $account_data.service_id + "-dsglobal";
					
					break;
				}
				
				# LINUX
				{$_ -like "*unix*" -or $_ -like "*linux*"} {
					
					$account.Platform = $platform_map["Linux"];
					
					$server = "";
					$name = "";
					if($account_data.resource -match "[a-z]{8}[0-9]{4}|[a-z]{5}[0-9]{3}"){
						$server = $matches[0];
						# $account.Name = $account_data.service_id + "-" + $server;
					}
					$account.Address = $server;
					
					break;
				}
				
				# APPLICATION LEVEL / MISC
				default {
					
					$account.Platform = $platform_map["Application"];
					$account.Name = $account_data.service_id;

					if($account_data.resource -match "[a-z]{8}[0-9]{4}"){
						$server = $matches[0];
						$account.Address = $server;
					} else {
						$account.Address = $account_data.resource;
					}
					
					break;
				}
				
			}
			
			# Set account name to username-address
			if($account.Name -eq ""){
				$account.Name = $account_data.service_id + "-" + $account.Address;
				if($global:migration_meta.include_virtualname){ 
					$account.VirtualUsername = $account.Name
				}
			}			

			# Add Previous Migration Info
			if("" -ne $account_data.migration_safe_name -and "" -ne $account_data.migration_verified){
				Add-Member -InputObject $account -NotePropertyName PreviouslyMigratedTo -NotePropertyValue $account_data.migration_safe_name;
				Add-Member -InputObject $account -NotePropertyName MigrationVerification -NotePropertyValue $account_data.migration_verified;
			}

			# Show other app associations if they exist
			if($account_data.associated_applications.length -gt 1){
				Add-Member -InputObject $account -NotePropertyName Associations -NotePropertyValue @($account_data.associated_applications | Where-Object { $_ -ne $app_data.app_name; });
			}

			$accounts.Add($account) | Out-Null;

		}
		
		# Sort Accounts
		if($accounts.count -gt 1){
			$accounts = $accounts | Sort-Object {$_.Name};
		}
		
		# Create safe object and add to safes list
		$safe = [PSCustomObject]@{
			Application = $app_data.app_name;
			Identifier = $safe_identifier;
			Description = $sys_id;
			Region = $region.toLower();
			Accounts = $accounts;
		}
		$safes.add($safe) | Out-Null;
		
	}

	return $safes;

} 