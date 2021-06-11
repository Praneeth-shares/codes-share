Function Publish-CyberArk-Settings()
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
	$properties = ConvertFrom-StringData (Get-Content "./system-Settings/CyberArk.properties" -raw);
	if($null -eq $properties){
		Write-Host "Could not load CyberArk settings. Check the system-Settings/CyberArk.properties file." -ForegroundColor Red;
	}

	# Assign cyberark_prod_url variable
	if($properties.ContainsKey("cyberark_prod_url")){
		$global:cyberark_prod_url = $properties["cyberark_prod_url"];
	} else {
		Write-Host "Could not cyberark_prod_url property. Check the system-Settings/CyberArk.properties file." -ForegroundColor Red;
	}

	# Assign cyberark_accp_url variable
	if($properties.ContainsKey("cyberark_accp_url")){
		$global:cyberark_accp_url = $properties["cyberark_accp_url"];
	} else {
		Write-Host "Could not cyberark_accp_url property. Check the system-Settings/CyberArk.properties file." -ForegroundColor Red;
	}

	# Assign cyberark_prod_region_tag variable
	if($properties.ContainsKey("cyberark_prod_region_tag")){
		$global:cyberark_prod_region_tag = $properties["cyberark_prod_region_tag"];
	} else {
		Write-Host "Could not cyberark_prod_region_tag property. Check the system-Settings/CyberArk.properties file." -ForegroundColor Red;
	}
	
	# Assign cyberark_prod_region_tag variable
	if($properties.ContainsKey("cyberark_accp_region_tag")){
		$global:cyberark_accp_region_tag = $properties["cyberark_accp_region_tag"];
	} else {
		Write-Host "Could not cyberark_accp_region_tag property. Check the system-Settings/CyberArk.properties file." -ForegroundColor Red;
	}
	
}
