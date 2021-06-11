function Get-PCF-Space-DR-Identifier {
<#

.SYNOPSIS
Requests input from user, provides help on content and errors out if null

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
See Synopsis Section

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
PCFSpace - This is the name of the PCF Space in the PCF Foundation

.EXAMPLE
$VariableName = Get-PCF-Space-DR-Identifier -PCFSpace "prod-external"

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>
Param(
	[parameter(Mandatory = $true)]
	[string]$PCFSpace
	)

<# This will provide the binding ID of a PCF element in DAP #>
switch -Wildcard ($PCFSpace) {
	"prod-external" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa392"
		break
		}
	"prod-internal" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa393"
		break
		}
	"accp-external" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa394"
		break
		}
	"accp-internal" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa395"
		break
		}
    default {
		Throw "Missing PCF Binding ID. Please contact PamEng to fix the code."
		break
		}
}
return $PCFSpaceIdentifier
}