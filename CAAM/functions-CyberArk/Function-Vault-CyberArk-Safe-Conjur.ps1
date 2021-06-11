Function Vault-CyberArk-Safe-Conjur()
<#

.SYNOPSIS
Create the safes and vault the accounts in CyberArk.

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
[psPAS] - https://github.com/pspete - Should be placed into PS paths prior to running the scripts

.PARAMETERS
safes - an object returned from Confirm-NePIS-Data

.EXAMPLE
Vault-NePIS-Data $safes

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
		$safes
	)
	
	
	# $safes | ConvertTo-Json -Depth 10; # Show data that will try to be added CyberArk



	."./functions-Conjur/Function-Create-Conjur-YAML.ps1"
	."./functions-CyberArk/Function-Verify-CyberArk-Accounts.ps1"


	Set-ExecutionPolicy Bypass -Scope process -Force;
	Import-Module pspas;
	
	# Function to search existing accounts in CyberArk, returns array of existing accounts
	# Warning: wrap the result in @() to make sure it returns an array.
	function search_account($account){
		$existing_accounts = @(Get-PASAccount -search "$($account.username), $($account.address)");
		return $existing_accounts;
	}

	$vaulted_accounts = [System.Collections.ArrayList]@();

	# Iterate safe data
	foreach($safe in $safes){

		# Check if safe already exists
		$create_safe = $null -eq (Get-PASSafe -SafeName $safe.Identifier -ErrorAction "SilentlyContinue");

		# Add Safe (if it doesn't exist)
		if($create_safe){
			Add-PASSafe -SafeName $safe.Identifier -Description $safe.Description -ManagingCPM PasswordManager -NumberOfDaysRetention 7 | Out-Null;
			
			# Add Standard Safe Members
			Add-PASSafeMember -SafeName $safe.Identifier -MemberName 'Vault Administrators' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true | Out-Null;
			Add-PASSafeMember -SafeName $safe.Identifier -MemberName 'Administrator' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true | Out-Null;
			
			# Add DAP LOB User Member
#			if($global:cyberark_region = "cybr-prod") {
				$LOBUser = "LOBUser_voya-pp";
				if($safe.Region -match "prod*"){
					$LOBUser = "LOBUser_voya";
				}
#			} else {
#				$LOBUser = "LOBUser_voya-poc";
#				if($safe.Region -match "prod*"){
#					$LOBUser = "LOBUser_voya";
#				}
#			}

			Add-PASSafeMember -SafeName $safe.Identifier -MemberName $LOBUser -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $false -ViewSafeMembers $false -AccessWithoutConfirmation $true | Out-Null;
			
			# Check that safe was created. If not, skip to the next safe.
			$safe_created = $null -ne (Get-PASSafe -SafeName $safe.Identifier -ErrorAction "SilentlyContinue");
			if($safe_created){
				Write-Host "Created safe" $safe.Identifier -ForegroundColor Green;
				log "Created safe $($safe.Identifier)";
			} else {
				Write-Host "Error creating safe" $safe.Identifier -ForegroundColor Red;
				log "Error - Could not create safe $($safe.Identifier)";
				continue;
			}
			
			# Create YAML files
			Write-Host;
			Create-Conjur-YAML $safe $safe.Application;
	
		# If safe already exists
		} else {
			Write-Host "Safe" $safe.Identifier "already exists." -ForegroundColor Yellow;
			log "Safe $($safe.Identifier) already exists";
		}
		
		Write-Host;

		# Add all accounts in safe data
		foreach($account in $safe.Accounts){

			# Remove illegal characters from account name
			$account.Name = $account.Name -replace "[\\/:*?`"<>|`t`n`r]";

			# Check if account with this name already exists. If so, skip to next account.
			$existing_accounts = @(search_account $account);
			if($existing_accounts.count -gt 0){
				$existing_safes = $existing_accounts.safeName;
				
				# If it exists in this safe, assign what CyberArk ID is has
				foreach($existing_account in $existing_accounts){
					if($existing_account.safeName -eq $safe.Identifier){
						Add-Member -InputObject $account -NotePropertyName id -NotePropertyValue $existing_account.id -Force;
					} else {
						Write-Host "Account $($account.name) already exists in $($existing_safes)." -ForegroundColor Yellow;
						log "Account $($account.name) already exists in $($existing_safes)";
						
						# TODO
						# If account exists elsewhere, create additional yaml file
						
						continue;
					}
					
				}
			}

			# If the account platform has extra properties, add them here
			$extra_properties = @{};
			if($null -ne $account.Port){
				$extra_properties["Port"] = [int] $account.Port;
			}
			if($global:migration_meta.include_virtualname){
				$extra_properties["Index"] = [int] $account.Index;
				$extra_properties["DualAccountStatus"] = $account.DualAccountStatus;
				if($account.VirtualUsername -eq "") {
					$extra_properties["VirtualUsername"] = $account.Name;
				} else {
					$extra_properties["VirtualUsername"] = $account.VirtualUsername;
				}
			}	

			# Add account to CyberArk
			if($global:migration_meta.include_virtualname){
				if ($account.Platform -like "KEY") {
					$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -SecretType Key -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties -VirtualUsername $account.VirtualUsername -Index $account.Index -AccountStatus $account.AccountStatus -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;
	
				} else {
					$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -Username $account.Username -Address $account.Address -SecretType Password -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties $extra_properties -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;
				}
			} else {
				if ($account.Platform -like "KEY") {
					$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -SecretType Key -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;
	
				} else {
					$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -Username $account.Username -Address $account.Address -SecretType Password -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties $extra_properties -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;
				}
			}

			Add-Member -InputObject $account -NotePropertyName id -NotePropertyValue $cyberark_account.id -Force;
			Add-Member -InputObject $account -NotePropertyName safe -NotePropertyValue $safe.Identifier;
			
			# Check account was created successfully
			if($null -ne $cyberark_account){
				Write-Host "Created account $($account.Name) in $($safe.Identifier)." -ForegroundColor Green;
				log "Created account $($account.Name) in $($safe.Identifier) successfully";
				$vaulted_accounts.add($account) | Out-Null;

			# If account was not created
			} else {
				Write-Host "Error creating account $($account.Name): `n$($add_account_error)" -ForegroundColor Red;
				log "Error - Could not create account $($account.Name) in $($safe.Identifier):`n$($add_account_error)";
			}
			
		}

		# Remove admin user creating the safe
		if($create_safe){
			Remove-PASSafeMember -SafeName $safe.Identifier -MemberName $global:cyberark_cred.username;
		}
		
		Write-Host;

	}
	If ($account.Platform -like "_AP_") {
		log "Skipping verification. Not applicable for this type of account";
	}
	if($global:migration_meta.verify_passwords){
		Verify-CyberArk-Accounts $vaulted_accounts;
	} else {
		log "Skipping verification.";
	}
	

}