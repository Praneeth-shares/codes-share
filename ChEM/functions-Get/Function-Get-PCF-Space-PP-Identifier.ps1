function Get-PCF-Space-PP-Identifier {
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
$VariableName = Get-PCF-Space-PP-Identifier -PCFSpace "accp-internal"

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
	"accp-external" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa492"
		break
		}
	"accp-internal" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa493"
		break
		}
	"intg" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa494"
		break
		}
	"unit" {
		$PCFSpaceIdentifier = "5eb36105-eb0a-48e6-a1b5-7c517dbaa495"
		break
		}
    default {
		Throw "Missing PCF Binding ID. Please contact PamEng to fix the code."
		break
		}
}
return $PCFSpaceIdentifier
}