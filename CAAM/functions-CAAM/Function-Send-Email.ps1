Function Send-Email()
<#
.SYNOPSIS
Send an email that a job was run.

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
None

.PARAMETERS
LogFile (string) - path to the log file
JobName (string) - name of the command that was run

.EXAMPLE
Send-Email -LogFile "D:/Logs/logfile1.txt" -JobName "Add-Safe-CYBR-Personal"

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 03/01/2021
#>

{

	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$LogFile,
		
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$JobName
	)
		
	$email_subject = "$JobName run for $global:cyberark_region completed by $env:username";
	$email_body = "Find the log transcript attached for $JobName executed at $global:cyberark_region by $env:username";

	Send-MailMessage -From $global:caam_email_sender -To $global:caam_email_recepients -Subject $email_subject -body $email_body -Attachments $LogFile -SmtpServer smtp1.dsglobal.org;
	
}