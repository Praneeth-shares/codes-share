Function Publish-CAAM-Settings()
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
	$properties = ConvertFrom-StringData (Get-Content "./system-Settings/CAAM.properties" -raw);
	if($null -eq $properties){
		Write-Host "Could not load CAAM settings. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign caam_email_sender variable
	if($properties.ContainsKey("caam_email_sender")){
		$global:caam_email_sender = $properties["caam_email_sender"];
	} else {
		Write-Host "Could not caam_email_sender property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign caam_email_recepients variable
	if($properties.ContainsKey("caam_email_recepients")){
		[string[]]$global:caam_email_recepients = $properties["caam_email_recepients"];
	} else {
		Write-Host "Could not caam_email_recepients property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign files_drive variable
	if($properties.ContainsKey("files_drive")){
		$global:files_drive = $properties["files_drive"];
	} else {
		Write-Host "Could not files_drive property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}	

	# Assign log_files_path variable
	if($properties.ContainsKey("log_files_path")){
		$global:log_files_path = $properties["log_files_path"];
	} else {
		Write-Host "Could not log_files_path property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign input_files_path variable
	if($properties.ContainsKey("input_files_path")){
		$global:input_files_path = $properties["input_files_path"];
	} else {
		Write-Host "Could not input_files_path property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign input_methods variable
	if($properties.ContainsKey("input_methods")){
		[string[]]$global:input_methods = $properties["input_methods"];
	} else {
		Write-Host "Could not input_methods property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}

	# Assign default_input_method variable
	if($properties.ContainsKey("default_input_method")){
		$global:default_input_method = $properties["default_input_method"];
	} else {
		Write-Host "Could not default_input_method property. Check the system-Settings/CAAM.properties file." -ForegroundColor Red;
	}	

}
