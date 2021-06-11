Function Add-Safe-CYBR-Personal {
<#

.SYNOPSIS
Creates a Safe in CyberArk for Personal user IDs

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of VOYA Financial CyberArk operations automation is prohibited from being copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
Creates a Safe in CyberArk for to host personal service accounts. 
This function will also add the default personal VOYA account. 

.MODULES & FUNCTIONS REQUIRED
[psPAS] - https://github.com/pspete - Should be placed into PS paths prior to running the scripts
[Get-FileName] - Function-Get-Filename.ps1
[Get-RITM] - Function-Get-RITM.ps1
[Get-App-Identifier] - Function-Get-Safename-Identifier.ps1
[Get-Safename] - Function-Get-Safename.ps1
[Get-Safe-Description] - Function-Get-Safe-Description.ps1
[Get-Safe-Region] - Function-Get-Safe-Region.ps1
[Get-Safe-Region-Accp] - Function-Get-Safe-Region-Accp.ps1

.PARAMETERS
parmCyberArkRegion - [prod, accp] which represent the 2 CyberArk environments
parmCyberArkURL - CyberArk URL
parmInputType - [manual, bulk] either manually get prompted for values or use a CSV comma delimited file for a bulk run
parmSender - notification sender email address
parmRecipients - notifications recipients
parmAppFilesDrive - System files Drive 
parmLogTranscriptsPath - System log transcript historical files
parmInputFilesPath - Input files for bulk processing default location

.EXAMPLE
Add-Safe-CYBR-Personal -parmCyberArkRegion "prod" -parmCyberArkURL "https://cyberark.voya.net" -parmInputType "manual" `
    -parmSender $voyaSender -parmRecipients $voyaRecipients `
    -parmAppFilesDrive $voyaAppFilesDrive -parmLogTranscriptsPath $voyaLogTranscriptPath `
    -parmInputFilesPath $voyaInputFilesPath

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

<# Define the function parameters #>
    [cmdletbinding()]
	Param(
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string]$parmCyberArkRegion,
        
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
		[string]$parmCyberArkURL,        
        
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string]$parmInputType,
 
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string]$parmSender,
        
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string[]]$parmRecipients,
        
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
		[string]$parmAppFilesDrive,       

        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string]$parmLogTranscriptsPath,
        
        [parameter(
            Mandatory = $true,
            ValueFromPipeline = $false
        )]
        [string]$parmInputFilesPath   
	)

Begin { }

Process {

<# Import Modules & Functions #>
Set-ExecutionPolicy Bypass -Scope process -Force
Import-Module pspas 
."./functions-Get/Function-Get-Account-Password.ps1"
."./functions-Get/Function-Get-Filename.ps1"
."./functions-Get/Function-Get-RITM.ps1"
."./functions-Get/Function-Get-Safename.ps1"
."./functions-Get/Function-Get-App-Identifier.ps1"
."./functions-Get/Function-Get-EmpID-Identifier.ps1"
."./functions-Get/Function-Get-Safe-Identifier.ps1"
."./functions-Get/Function-Get-Safe-Description.ps1"
."./functions-Get/Function-Get-Safe-Region.ps1"
."./functions-Get/Function-Get-Safe-Region-Accp.ps1"

<# Definition of local variables #>
$parmCyberArkRegion = $parmCyberArkRegion.ToUpper()
$parmInputType = $parmInputType.ToLower()
if ($parmInputType -eq "bulk") {
	$VarInputFile = Get-FileName -initialDirectory "$parmAppFilesDrive$parmInputFilesPath"
	}

$nam1 = (get-date).month
$nam2 = (get-date).day
$nam3 = (get-date).year
$nam4 = (get-date).hour
$nam5 = (get-date).minute
$nam6 = $MyInvocation.MyCommand
$filename = "$nam1-$nam2-$nam3--$nam4-$nam5--$nam6-$parmCyberArkRegion--ExecutedBy-$env:username.txt"

<# Script Main Code & Logging #>
try{
start-transcript -path "$parmAppFilesDrive$parmLogTranscriptsPath\temp\$filename" |
out-null

Write-host ""
Write-host "*************************************************************************"
Write-host "This is the log transcript for" $nam6 "in CyberArk" $parmCyberArkRegion "ExecutedBy" $env:username
Write-host "*************************************************************************"


#$Startdate = [DateTime]::Now
[System.DateTime]::Now

if ($parmInputType -eq "bulk") {
	$InputValues = Import-Csv -Path $VarInputFile
	}
else {
	<# Manually create input file #>
	$TmpRITM = Get-RITM
	$TmpRITM = $TmpRITM.ToUpper()
    $TmpRITM = $TmpRITM.Trim()	
	if ($TmpRITM.substring(0,4) -eq "RITM") {} else {Throw "Wrong RITM #, please use full RITM number. (Example RITM123456).  If the problem persist, please contact PamEng to fix the code."}
	$TmpSafeIdentifier = Get-EmpID-Identifier
	$TmpSafeIdentifier = $TmpSafeIdentifier.Trim()
	if ($TmpSafeIdentifier.length -eq 6) {} else {Throw "Wrong Employee ID, please only use numbers and must be 6 digit long. (Example 712345).  If the problem persist, please contact PamEng to fix the code."}
	$TmpSafeDescription = Get-Safe-Description
	$TmpSafeDescription = $TmpSafeDescription.Trim()
#	if ($TmpSafeDesription.length -eq 6) {} else {Throw "Wrong Employee ID, please only use numbers and must be 6 digit long. (Example 712345).  If the problem persist, please contact PamEng to fix the code."}
	$TmpAccountPassword = Get-Account-Password
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TmpAccountPassword)
	$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
	read-host $UnsecurePassword
	#	if ($parmCyberArkRegion -eq "PROD") {$TmpSafeRegion = Get-Safe-Region} Else {$TmpSafeRegion = Get-Safe-Region-Accp}
    if ($parmCyberArkRegion -eq "PROD") {$TmpSafeRegion = "production"} Else {$TmpSafeRegion = "non-production"}

	$InputValues = [PSCustomObject]@{
		VarSafeIdentifier = $TmpSafeIdentifier
		VarSafeDescription = $TmpSafeDescription
		VarSafeRegion = $TmpSafeRegion
		VarRITM = $TmpRITM
		VarAccountPassword = $TmpAccountPassword
		}
	}

<# RestAPI LogIn into CyberArk to submit all input data #>
$cred = Get-Credential
New-PASSession -Credential $cred -BaseURI $parmCyberArkURL

<# Create Safe Main Section #>	
$InputValues | ForEach-Object {

	Write-host ""
	Write-host "******************************"
	Write-host "Processing data for" $_.VarRITM
	Write-host "******************************"
	Write-host ""
	
	$TmpSafeIdentifierFinal = if ($_.VarSafeIdentifier.length -gt 22) {$_.VarSafeIdentifier.substring(0, 22)} else {$_.VarSafeIdentifier}
	If ($TmpSafeIdentifierFinal.length -gt 6) {$TmpSafeRegionFinal = "non-production"} else {$TmpSafeRegionFinal ="production"}
	$TmpSafeDescriptionFinal = $_.VarSafeDescription
	If ($TmpSafeRegionFinal -eq "production") {$TmpAccountFinal = "j$TmpSafeIdentifierFinal"} else {$TmpAccountFinal = "j$TmpSafeDescriptionFinal"}

	if ($parmCyberArkRegion -eq "PROD") {
		switch($TmpSafeRegionFinal) {
			"production" {$TmpSafeNameFinal = "P_$TmpSafeIdentifierFinal"; $TmpMember1 = "B-CyberPersonal-$TmpSafeIdentifierFinal";  Break}
            "non-production" {$TmpSafeNameFinal = "$TmpSafeIdentifierFinal"; $TmpMember1 = "B-CyberPersonal-$TmpSafeDescriptionFinal";  Break}
			}		

#		$TmpMember2 = ""
#		$TmpMember3 = ""
#		$TmpMember4 = ""
#		$TmpMember5 = ""
		}
	Else {
		switch($TmpSafeRegionFinal) {
			"production" {$TmpSafeNameFinal = "P_$TmpSafeIdentifierFinal"; $TmpMember1 = "B-CyberNonDeveloper-AMO AD Sec-Win-PRD";  Break}
			"non-production" {$TmpSafeNameFinal = "$TmpSafeIdentifierFinal"; $TmpMember1 = "B-CyberNonDeveloper-AMO AD Sec-Win-PRD";  Break}
			}
#		$TmpMember2 = ""
#		$TmpMember3 = ""
#		$TmpMember4 = ""
#		$TmpMember5 = ""		
	 	}
	<# Add Standard Safe Members #>
	Add-PASSafe -SafeName $TmpSafeNameFinal -Description $TmpSafeDescriptionFinal -ManagingCPM PasswordManager -NumberOfDaysRetention 7
	

	Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName 'Vault Administrators' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true
	Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName 'Administrator' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true
    
	<# Add Specific Safe Type Members based on region #>
	if ($TmpSafeRegionFinal -eq "production") {
		Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName $TmpMember1 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -InitiateCPMAccountManagementOperations $true -ViewAuditLog $true -ViewSafeMembers $true
		}
	else {
		Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName $TmpMember1 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -InitiateCPMAccountManagementOperations $true -ViewAuditLog $true -ViewSafeMembers $true
		}
	
    <# Add personal account #>
	if ($TmpSafeRegionFinal -eq "production") {
		Add-PASAccount -Address 'dsglobal.org' -Username $TmpAccountFinal -PlatformID 'WindowsPersonal20Hours' -SafeName $TmpSafeNameFinal
		}
	else {
		Add-PASAccount -Address 'dsglobal.org' -Username $TmpAccountFinal -PlatformID 'WindowsPersonal20Hours' -SafeName $TmpSafeNameFinal
		}
	
	$TmpNewAccount = Get-PASAccount -Keywords $TmpAccountFinal -Safe $TmpSafeNameFinal
	write-host $TmpNewAccount.AccountID
	read-host "AccountID"

	<# Remove admin user creating Safe (Security Cleanup) #>
    Remove-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName $cred.username
		
	}

Write-host "*********************************************************"
Write-host "All tasks for run" $nam6 "in CyberArk" $parmCyberArkRegion "are completed successfully" 
Write-Host "*********************************************************"
}
finally
{
stop-transcript | Out-null
}

<# Produce & email log and run notification #>
$log = Get-Content "$parmAppFilesDrive$parmLogTranscriptsPath\temp\$filename"
$logfixed = New-Object System.Text.StringBuilder; foreach ($line in $log){[void] $logfixed.AppendLine($line.ToString())}
$bodyemail = "Find the log transcript attached for $nam6 executed at CyberArk $parmCyberArkRegion by $env:username"
new-item -Path $parmAppFilesDrive -Name $parmLogTranscriptsPath\$nam6 -ItemType directory -ErrorAction SilentlyContinue
$locfile = "$parmAppFilesDrive$parmLogTranscriptsPath\$nam6\$filename"
"Script: $logfixed"| out-file $locfile

Send-MailMessage -From $parmSender -To $parmRecipients -Subject "$nam6 run for CyberArk $parmCyberArkRegion completed by $env:username" -body $bodyemail -Attachments $locfile -SmtpServer smtp1.dsglobal.org
remove-item -path "$parmAppFilesDrive$parmLogTranscriptsPath\temp\$filename"
}

End { }

}
