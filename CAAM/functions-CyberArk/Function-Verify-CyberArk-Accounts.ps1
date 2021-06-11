Function Verify-CyberArk-Accounts()
<#

.SYNOPSIS
Perform verification tasks on a set of accounts

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
None

.PARAMETERS
accounts - array of account objects, which must have the following properties:
	name - the name of the account in CyberArk
	platform - the platform policy of the account in CyberArk
	id - the ID of the account in CyberArk
	safe - the name of the safe in CyberArk
	sid_key - the account's sid_key from NePIS					# optional

.EXAMPLE
Verify-CyberArk-Accounts $accounts

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 02/17/2021

#>

{
	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		$accounts
	)
	
	# Check if there are accounts to verify
	if($accounts.Count -eq 0){
		return;
	
	}

	Write-Host "Starting account verifications. The may take up to 6 minutes.";
	Write-Host;
	# Store start time (seconds)
	$start_time = [int](Get-Date -uformat %s)

	# Start Verification Tasks
	$verifying_accounts = [System.Collections.ArrayList]@();
	foreach($account in $accounts){
		$verification_result = "Not Attempted";
		$verify_password = $true;
		if($account.Platform.contains("_AP_")){
			$verify_password = $false;
		}
		if($verify_password){
			Write-Host "Starting verification for $($account.Name)...";
			$verifying_accounts.add($account) | Out-Null;
			
			# Start verification task
			try {
				Invoke-PASCPMOperation -AccountID $account.id -VerifyTask -ErrorAction Continue;
			}
			catch
			{  
				$ErrorMessage = $_.Exception.Message;
				$ErrorMessage = $ErrorMessage.ToString();
				Write-Host $ErrorMessage -ForegroundColor red;;
				$verifying_accounts.remove($account) | Out-Null;
				log "Verification failed for $($account.Name). Error: $($ErrorMessage)";
			}   
		} else {
			$verification_result = "Not Applicable";
			log "Verification for account $($account.name) is not applicable"
		}
	}

	Write-Host;

	# Wait for verifications to finish
	foreach($account in $verifying_accounts){

		# Wait until finished or timed out
		while($true){
			
			# Check session
			if(-not (Create-CyberArk-Session)){
				Write-Host "Verification checks aborted!" -ForegroundColor Red;
				log "Error - Verification checks aborted!";
				return;
			}

			# Get verification status from account info
			$searched_account = (Get-PASAccount -ID $account.id);
			$verification_status = $searched_account.secretManagement.status;
			
			# Check if verification task finished
			if($null -ne $verification_status){
				break;
			}

			# Check if verification has been going too long
			if([int](Get-Date -uformat %s) - $start_time -gt (60*7)){
				Write-Host "Verification Timed Out." -ForegroundColor Red;
				log "Verification Timed Out";
				break;
			}

			# Check if verification task is done every 15 seconds
			Start-Sleep -Seconds 15;
		}
	}

	# Have to wait to get the correct result for some reason
	# If you don't wait, the API sometimes returns a failure even when it succeeds...
	# ?????
	Start-Sleep -Seconds 15;

	# Get Verification Results
	foreach($account in $verifying_accounts){
		while($true){
					
			# Get verification status from account info
			$searched_account = (Get-PASAccount -ID $account.id);
			$verification_status = $searched_account.secretManagement.status;
			
			# Check if verification task was successful
			if($null -ne $verification_status -and "success" -eq $verification_status){
				Write-Host "Verified $($account.Name) successfully." -ForegroundColor Green;
				log "Verified account $($account.Name) successfully";
				$verification_result = "Successful";
				break;

			# Otherwise mark as failed
			} else {
				Write-Host "Verification for $($account.Name) failed." -ForegroundColor Red;
				log "Error - Could not verify account $($account.Name)";
				$verification_result = "Failed";
				# (Get-PASAccount -ID $account.id) | ConvertTo-Json -Depth 10; # View data for debugging
				break;
			}
		}

	}

}