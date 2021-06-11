function Get-PCF-Org-DR-Identifier {
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
PCFOrg - This is the name of the PCF Org in the PCF Foundation

.EXAMPLE
$VariableName = Get-PCF-Org-DR-Identifier -PCFOrg "b2bapps" 

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>
Param(
	[parameter(Mandatory = $true)]
	[string]$PCFOrg
	)
<# This will provide the binding ID of a PCF element in DAP #>
switch ($PCFOrg) {
	"apptx-sandbox-org" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fa"
		break
		}
	"b2bapps" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fb"
		break
		}
	"b2bportalapps" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fc"
		break
		}
	"b2bservices" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fd"
		break
		}
	"batchrs" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fe"
		break
		}
	"configandcontent" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648ff"
		break
		}
	"corers" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fg"
		break
		}
	"correspondence" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fh"
		break
		}
	"financialtools" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fi"
		break
		}
	"portalapps" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fk"
		break
		}
	"retail" {
		$PCFOrgIdentifier = "0d6740ff-58b5-4dd7-8a73-8d05654648fl"
		break
		}
    default {
		Throw "Missing PCF Binding ID. Please contact PamEng to fix the code."
		break
		}
}
return $PCFOrgIdentifier 
}