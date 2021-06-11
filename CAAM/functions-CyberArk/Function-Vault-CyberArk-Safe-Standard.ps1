Function Vault-CyberArk-Safe-Standard()
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

	."./functions-CyberArk/Function-Verify-CyberArk-Accounts.ps1"
	."./functions-CyberArk/Function-Change-CyberArk-Accounts.ps1"

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
			

			If("personal" -eq $global:migration_meta.application_region) {
				$AdditionalMember1 = "B-CyberPersonal-"+$safe.Application;
				Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -InitiateCPMAccountManagementOperations $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
			} elseif("production" -eq $global:migration_meta.application_region) {
				$AdditionalMember1 = "B-CyberApprover-"+$safe.Application;
				$AdditionalMember2 = "G-Cyber-ServiceDeskSupport";
				Switch ($global:migration_meta.application_platform) {
					"Database" {
						$AdditionalMember3 = "B-CyberDeveloper-"+$safe.Application+"-DB-PRD";
						$AdditionalMember4 = "B-CyberNonDeveloper-"+$safe.Application+"-DB-PRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -RequestsAuthorizationLevel 1 -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember3 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember4 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AccessWithoutConfirmation $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Unix" {
						$AdditionalMember3 = "B-CyberDeveloper-"+$safe.Application+"-UN-PRD";
						$AdditionalMember4 = "B-CyberNonDeveloper-"+$safe.Application+"-UN-PRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -RequestsAuthorizationLevel 1 -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember3 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember4 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AccessWithoutConfirmation $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Windows" {
						$AdditionalMember3 = "B-CyberDeveloper-"+$safe.Application+"-WIN-PRD";
						$AdditionalMember4 = "B-CyberNonDeveloper-"+$safe.Application+"-WIN-PRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -RequestsAuthorizationLevel 1 -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember3 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember4 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AccessWithoutConfirmation $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Mainframe" {
						$AdditionalMember3 = "B-CyberDeveloper-"+$safe.Application+"-MF-PRD";
						$AdditionalMember4 = "B-CyberNonDeveloper-"+$safe.Application+"-MF-PRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -RequestsAuthorizationLevel 1 -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember3 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember4 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AccessWithoutConfirmation $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Application" {
						$AdditionalMember3 = "B-CyberDeveloper-"+$safe.Application+"-AP-PRD";
						$AdditionalMember4 = "B-CyberNonDeveloper-"+$safe.Application+"-AP-PRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -RequestsAuthorizationLevel 1 -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember3 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember4 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AccessWithoutConfirmation $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Cloud" {}
					"SaaS" {}
				}
			} else {
				$AdditionalMember1 = "G-Cyber-ServiceDeskSupport";
				Switch ($global:migration_meta.application_platform) {
					"Database" {
						$AdditionalMember2 = "B-CyberUser-"+$safe.Application+"-DB-NonPRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Unix" {
						$AdditionalMember2 = "B-CyberUser-"+$safe.Application+"-UN-NonPRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Windows" {
						$AdditionalMember2 = "B-CyberUser-"+$safe.Application+"-WIN-NonPRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Mainframe" {
						$AdditionalMember2 = "B-CyberUser-"+$safe.Application+"-MF-NonPRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember1 -SearchIn 'DSGLOBAL' -UseAccounts $false -RetrieveAccounts $false -ListAccounts $true -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Application" {
						$AdditionalMember2 = "B-CyberUser-"+$safe.Application+"-AP-NonPRD";
						Add-PASSafeMember -SafeName $safe.Identifier -MemberName $AdditionalMember2 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -ViewAuditLog $true -ViewSafeMembers $true | Out-Null;					
					}
					"Cloud" {}
					"SaaS" {}
				}
			}

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

		Write-Host;

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

			# Add account to CyberArk
			If ($account.Platform -like "KEY") {
				$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -SecretType Key -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;

			} else {
				$cyberark_account = Add-PASAccount -SafeName $safe.Identifier -Name $account.Name -Username $account.Username -Address $account.Address -SecretType Password -Secret (ConvertTo-SecureString -String $account.Password -AsPlainText -Force) -PlatformID $account.Platform -PlatformAccountProperties $extra_properties -ErrorAction "SilentlyContinue" -ErrorVariable add_account_error;
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
#	If ($account.Platform -like "_AP_" -or  $account.Platform -like "_CS_" -or  $account.Platform -like "_SA_") {
#		log "Skipping verification. Not applicable for this type of account";
#	}

	if($global:migration_meta.verify_passwords){
		Verify-CyberArk-Accounts $vaulted_accounts;
	} else {
		log "Skipping verification.";
	}
	
	if($global:migration_meta.change_passwords){
		Change-CyberArk-Accounts $vaulted_accounts;
	} else {
		log "Skipping password rotation.";
	}
	

}