Function Change-CyberArk-Accounts()
<#

.SYNOPSIS
Perform password rotation tasks on a set of accounts

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

	Write-Host "Starting account password rotation. The may take up to 6 minutes.";
	Write-Host;
	# Store start time (seconds)
	$start_time = [int](Get-Date -uformat %s)

	# Start password rotation Tasks
	$changing_accounts = [System.Collections.ArrayList]@();
	foreach($account in $accounts){
		$changing_result = "Not Attempted";
		$change_password = $true;
		if($account.Platform.contains("_AP_")){
			$change_password = $false;
		}
		if($change_password){
			Write-Host "Starting password rotation for $($account.Name)...";
			$changing_accounts.add($account) | Out-Null;
			
			# Start password rotation task
			try {
				Invoke-PASCPMOperation -AccountID $account.id -ChangeTask -ErrorAction Continue;
			}
			catch
			{  
				$ErrorMessage = $_.Exception.Message;
				$ErrorMessage = $ErrorMessage.ToString();
				Write-Host $ErrorMessage -ForegroundColor red;;
				$changing_accounts.remove($account) | Out-Null;
				log "Password rotation failed for $($account.Name). Error: $($ErrorMessage)";
			}   
		} else {
			$changing_result = "Not Applicable";
			log "Password rotation for account $($account.name) is not applicable"
		}
	}

	Write-Host;

	# Wait for password rotations to finish
	foreach($account in $changing_accounts){

		# Wait until finished or timed out
		while($true){
			
			# Check session
			if(-not (Create-CyberArk-Session)){
				Write-Host "Password rotation validation aborted!" -ForegroundColor Red;
				log "Error - Password rotation validation aborted!";
				return;
			}

			# Get password rotation status from account info
			$searched_account = (Get-PASAccount -ID $account.id);
			$changing_status = $searched_account.secretManagement.status;
			
			# Check if password rotation task finished
			if($null -ne $changing_status){
				break;
			}

			# Check if password rotation has been going too long
			if([int](Get-Date -uformat %s) - $start_time -gt (60*7)){
				Write-Host "Password roation timed out." -ForegroundColor Red;
				log "Password rotation timed out";
				break;
			}

			# Check if password rotation task is done every 15 seconds
			Start-Sleep -Seconds 15;
		}
	}

	# Have to wait to get the correct result for some reason
	# If you don't wait, the API sometimes returns a failure even when it succeeds...
	# ?????
	Start-Sleep -Seconds 15;

	# Get password rotation Results
	foreach($account in $changing_accounts){
		while($true){
					
			# Get password rotation status from account info
			$searched_account = (Get-PASAccount -ID $account.id);
			$changing_status = $searched_account.secretManagement.status;
			
			# Check if password rotation task was successful
			if($null -ne $changing_status -and "success" -eq $changing_status){
				Write-Host "Rotated $($account.Name) successfully." -ForegroundColor Green;
				log "Account $($account.Name) password rotated successfully";
				$changing_result = "Successful";
				break;

			# Otherwise mark as failed
			} else {
				Write-Host "Password rotation for $($account.Name) failed." -ForegroundColor Red;
				log "Error - Could not rotate password for account $($account.Name)";
				$changing_result = "Failed";
				# (Get-PASAccount -ID $account.id) | ConvertTo-Json -Depth 10; # View data for debugging
				break;
			}
		}
	}

}