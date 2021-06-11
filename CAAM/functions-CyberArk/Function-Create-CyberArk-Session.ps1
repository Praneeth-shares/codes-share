Function Create-CyberArk-Session()
<#

.SYNOPSIS
Open a dialog box to get the CyberArk admin credentials and open a session

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
None

.EXAMPLE
if(Create-CyberArk-Session){
	# Session was created successfully
}

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 02/23/2020

#>

{
	# Check for existing CyberArk session, create a new one if necessary
	while($true){
		
		# Check if session is valid
		try {
			Get-PASUser -ID 1 | Out-Null;  # only works if session is valid, throws error otherwise
			# Write-Host "Still Valid";
			return $true;

		# If session is not valid
		} catch {

			# Write-Host "Invalid - getting new credentials";
			
			# Get credentials new session
			$global:cyberark_cred = Get-Credential -Message "Enter CyberArk Admin Credentials";

			# User cancelled prompt, exit function
			if($null -eq $global:cyberark_cred){
				Write-Host "Operation Cancelled." -ForegroundColor Red;
				return $false;
			}

			# Create a new session
			try {
				New-PASSession -Credential $global:cyberark_cred -BaseURI $global:cyberark_url -ErrorAction SilentlyContinue -ErrorVariable pas_session_error; 
			} catch {

			}
			
			# If could not authenticate, repeat this loop
			if("" -ne $pas_session_error){
				# Write-Host $pas_session_error -ForegroundColor Red;
				Write-Host "Could not authenticate to CyberArk. Please confirm your username & password then try again." -ForegroundColor Red;
			}
		}
	}
} 