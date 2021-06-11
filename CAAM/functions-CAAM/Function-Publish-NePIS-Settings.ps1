Function Publish-NePIS-Settings()
<#
.SYNOPSIS
Load the NePIS settings from the NePIS.properties file

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
None

.PARAMETERS
None

.EXAMPLE
Load-NePIS-Settings
$global:nepis_url  # holds something like "https://sid.unit.voya.net/isid"

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 01/26/2021
#>

{

	# Load properties file into a hashtable
	$properties = ConvertFrom-StringData (Get-Content "./system-Settings/NePIS.properties" -raw);
	if($null -eq $properties){
		Write-Host "Could not load NePIS settings. Check the system-Settings/NePIS.properties file." -ForegroundColor Red;
	}

	# Assign nepis_url variable
	if($properties.ContainsKey("nepis_url")){
		$global:nepis_url = $properties["nepis_url"];
	} else {
		Write-Host "Could not nepis_url property. Check the system-Settings/NePIS.properties file." -ForegroundColor Red;
	}

	# Assign nepis_auth_url variable
	if($properties.ContainsKey("nepis_auth_url")){
		$global:nepis_auth_url = $properties["nepis_auth_url"];
	} else {
		Write-Host "Could not nepis_auth_url property. Check the system-Settings/NePIS.properties file." -ForegroundColor Red;
	}

}
