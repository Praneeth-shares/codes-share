function Get-CyberArk-Platform-Map-Account-Conjur {
<#

.SYNOPSIS
Provide a mapping from NePIS platform keywords to specific CyberArk platform IDs 

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
See Synopsis Section

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
region : string("prod", "nonprod") - Whether to provide the prod mapping or the nonprod mapping

.EXAMPLE
$platform_map = Get-NePIS-Platform-Map "nonprod"

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 12/2/2020
History of maintenances:

#>

	Param(
		[Parameter(Mandatory = $true, HelpMessage="Enter `"prod`" or `"nonprod`".")]
		[string] $region
	)


	Switch ($region)
	{
		"prod" {return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_Prod.properties" -raw)}
		"nonprod" {return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_NonProd.properties" -raw)}
		"prod_virtualname" {return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_Prod_DA.properties" -raw)}
		"nonprod_virtualname" {return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_NonProd_DA.properties" -raw)}
	}	

#	if($region -ne $null -and $region -eq "prod"){
#		return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_Prod.properties" -raw);
#	} else {
#		return ConvertFrom-StringData (Get-Content "./system-Settings/DAPPlatformMap_NonProd.properties" -raw);
#	}

}