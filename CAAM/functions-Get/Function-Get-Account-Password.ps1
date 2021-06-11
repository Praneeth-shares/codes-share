function Get-Account-Password {
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
Prompts the user to enter a value for the mandatory unique parameter

.EXAMPLE
$VariableName = Get-Account-Password

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>
 Param(
 [Parameter(Mandatory = $true, HelpMessage="The new account password to load into CyberArk.")]
 [ValidateNotNullorEmpty()]
 [SecureString] $AccountPassword
 )
 $AccountPassword
}