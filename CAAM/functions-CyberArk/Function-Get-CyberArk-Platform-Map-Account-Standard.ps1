function Get-CyberArk-Platform-Map-Account-Standard {
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
		[Parameter(Mandatory = $true)]
		[string] $region
	)

	Switch ($region)
	{
		"personal" {return ConvertFrom-StringData (Get-Content "./system-Settings/PersonalPlatformMap.properties" -raw)}
		"prod" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod.properties" -raw)}
		"nonprod" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd.properties" -raw)}
		"prod_database" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Database.properties" -raw)}
		"nonprod_database" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Database.properties" -raw)}
		"prod_unix" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Unix.properties" -raw)}
		"nonprod_unix" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Unix.properties" -raw)}	
		"prod_windows" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Windows.properties" -raw)}
		"nonprod_windows" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Windows.properties" -raw)}
		"prod_mainframe" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Mainframe.properties" -raw)}
		"nonprod_mainframe" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Mainframe.properties" -raw)}
		"prod_application" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Application.properties" -raw)}
		"nonprod_application" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Application.properties" -raw)}
		"prod_cloud" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_Cloud.properties" -raw)}
		"nonprod_cloud" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_Cloud.properties" -raw)}
		"prod_saas" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_Prod_SaaS.properties" -raw)}
		"nonprod_saas" {return ConvertFrom-StringData (Get-Content "./system-Settings/NonPersonalPlatformMap_NonProd_SaaS.properties" -raw)}							
	}	
}