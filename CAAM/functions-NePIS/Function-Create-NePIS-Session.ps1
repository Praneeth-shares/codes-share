Function Create-NePIS-Session()
<#

.SYNOPSIS
Open a dialog box to get the user's NePIS credentials and open a session with NePIS

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
None

.EXAMPLE
if(Create-NePIS-Session){
	# Session was created
}

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 11/20/2020

#>

{
	# Authentication URL
	$uri = "$($global:nepis_auth_url)/pkmslogin.form?token=Unknown";
	
	# Check if session already exists
	if($null -ne $global:nepis_session -and $null -ne $global:nepis_session.cookies.getCookies($uri)["PD-ID"]){
		
		# Check existing session is valid
		$result = Invoke-RestMethod -Uri "$($global:nepis_url)/admin" -Method Get -WebSession $global:nepis_session;
		if($null -ne $result){
			if($result -match "pkmslogin"){
				# Write-Host "NePIS session expired. Creating a new one..." -ForegroundColor Yellow;
			} else {
				# Write-Host "NePIS session already exists." -ForegroundColor Green;
				return $true;
			}			
		}
	}

	# Use TLS 1.2, required for WebSeal
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

	# New session object, stores authentication-related cookies
	$global:nepis_session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
	
	# Repeated ask user for credentials until abort or success
	while($true){
		
		# Prompt user for NePIS Credentials
		$nepis_credential = Get-Credential -Message "Enter NePIS Credentials" -ErrorAction SilentlyContinue;
		if($null -eq $nepis_credential){
			Write-Host "NePIS Login Cancelled." -ForegroundColor Red;
			return $false;
		}

		# Construct request parameters to WebSeal authentication
		$headers = @{
			"Referer" = "$($global:nepis_auth_url)/pkmsvouchfor?americas&$($global:nepis_url)/admin";
		};
		$form = @{
			"userlogin" = $nepis_credential.username;
			"password" = $nepis_credential.GetNetworkCredential().password;
			"username" = "$($nepis_credential.username)@dsglobal.org";
			"login-form-type" = "pwd";
		};

		# Invoke REST call to WebSeal and check if successful
		$result = Invoke-RestMethod -Uri $uri -Method Post -Body $form -Headers $headers -WebSession $global:nepis_session;
		if($result -match "successful"){
			Write-Host "NePIS Login Successful" -ForegroundColor Green;
			return $true;
		} else {
			Write-Host "NePIS Login Failed" -ForegroundColor Red;
		}
	}
} 