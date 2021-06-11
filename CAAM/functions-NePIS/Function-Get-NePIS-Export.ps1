Function Get-NePIS-Export()
<#

.SYNOPSIS
Export credential data from NePIS. Example return data:
[
	{
		"app_name":  "Non Personal ID Solution (ACCP)",
		"environment":  "Acceptance",
		"sys_id":  "6442c965cc88f100bcb88af21d479d81",
		"accounts":  [
			{
				"service_id": "SIDADM",
				"password": "dnw$9Ik4Xa",
				"resource": "sida@sida@ajaxlaaa9876",
				"platform": "Oracle",
				"environment": "ACCP",
				"port": "50001"
			},
			...
		]
	},
	...
]

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
session (WebRequestSession) - a session that has authenticated through WebSeal
appName (String) - the name of the app to export the credentials for

.EXAMPLE
Get-NePIS-Export $session "Non Personal ID Solution"

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
		[string]$appName
	)

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

	# Build parameters for NePIS API request
	$uri = "$($global:nepis_url)/api/export";
	$headers = @{};
	$form = @{
		"app_name" = $appName;
	};
	
	# Write-Host ($global:nepis_session.cookies.GetCookies($global:nepis_auth_url) | ConvertTo-Json);

	# Make request and check result is not null and is powershell object, must have failed if otherwise
	$result = Invoke-RestMethod -Uri $uri -Method Get -Body $form -Headers $headers -WebSession $global:nepis_session;
	if($null -ne $result -and $result.getType() -eq [System.String]){
		if($result -match "pkmslogin"){
			Write-Host "NePIS Session expired. Please create a new one." -ForegroundColor Red;
		} else {
			Write-Host "NePIS API Request failed: $($result)" -ForegroundColor Red;
		}
		return $null;
	}

	return $result;
} 