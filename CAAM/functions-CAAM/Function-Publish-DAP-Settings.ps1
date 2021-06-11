Function Publish-DAP-Settings()
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
	$properties = ConvertFrom-StringData (Get-Content "./system-Settings/DAP.properties" -raw);
	if($null -eq $properties){
		Write-Host "Could not load DAP settings. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_write_prod_url variable
	if($properties.ContainsKey("dap_write_prod_url")){
		$global:dap_write_prod_url = $properties["dap_write_prod_url"];
	} else {
		Write-Host "Could not dap_write_prod_url property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_write_accp_url variable
	if($properties.ContainsKey("dap_write_accp_url")){
		$global:dap_write_accp_url = $properties["dap_write_accp_url"];
	} else {
		Write-Host "Could not dap_write_accp_url property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_read_prod_url variable
	if($properties.ContainsKey("dap_read_prod_url")){
		$global:dap_read_prod_url = $properties["dap_read_prod_url"];
	} else {
		Write-Host "Could not dap_read_prod_url property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_read_accp_url variable
	if($properties.ContainsKey("dap_read_accp_url")){
		$global:dap_read_accp_url = $properties["dap_read_accp_url"];
	} else {
		Write-Host "Could not dap_read_accp_url property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_dev_url variable
	if($properties.ContainsKey("dap_dev_url")){
		$global:dap_dev_url = $properties["dap_dev_url"];
	} else {
		Write-Host "Could not dap_dev_url property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_prod_account variable
	if($properties.ContainsKey("dap_prod_account")){
		$global:dap_prod_account = $properties["dap_prod_account"];
	} else {
		Write-Host "Could not dap_prod_account property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_accp_account variable
	if($properties.ContainsKey("dap_accp_account")){
		$global:dap_accp_account = $properties["dap_accp_account"];
	} else {
		Write-Host "Could not dap_accp_account property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_dev_account variable
	if($properties.ContainsKey("dap_dev_account")){
		$global:dap_dev_account = $properties["dap_dev_account"];
	} else {
		Write-Host "Could not dap_dev_account property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

	# Assign dap_policy_output_path variable
	if($properties.ContainsKey("dap_policy_output_path")){
		$global:dap_policy_output_path = $properties["dap_policy_output_path"];
	} else {
		Write-Host "Could not dap_policy_output_path property. Check the system-Settings/DAP.properties file." -ForegroundColor Red;
	}

}
