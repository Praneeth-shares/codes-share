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


.EXAMPLE
Add-Safe-CYBR-Personal 

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by:  Srikanth Kamarthy @ 12/8/2020
History of maintenances:
Sergio Bascon @ 9/11/2020

#>

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
."./functions-CyberArk/Function-Create-CyberArk-Session.ps1"

<# If request is bulk get input file #>
if ($global:input_method -eq $global:input_methods[1]) {
	Write-Host "--- Warning!" -fore yellow -back black 
	Write-Host "Before you continue make sure the CSV file is properly formatted."
	Write-Host "Headers in your file must be exactly typed as sample below:"
	Write-Host "VarSafeIdentifier,VarRITM,VarAccountPassword" -fore green -back black 
	Write-Host "799887,RITM9999999,changeme" -fore green -back black 
	Write-Host ""
	Read-Host "Press any key to continue or Ctrl-C to cancel" 
	do
    {
		[bool]$valLoop = $TRUE
        if($valErr) {
            Write-Host " "
			Write-Host "Error! You didn't select a file, please try again." -foreGroundColor RED
			Write-Host "If the problem persist please contact PamEng." -foreGroundColor RED
			Read-Host "Press any key to continue "
			$valErr = $FALSE
        }
		$VarInputFile = Get-FileName -initialDirectory "$global:files_drive$global:input_files_path"
		if ($VarInputFile -eq "") {$valErr = $TRUE} else {$valLoop = $FALSE}
	}
	while($valLoop)
	try {
		Read-host "Any key to continue with your file selection or Ctrl-C to cancel " $VarInputFile
	}
	catch
	{  
		$ErrorMessage = $_.Exception.Message
		$ErrorMessage = $ErrorMessage.ToString()
		write-output " "        
		write-Host "Error! You didn't select a file, please try again. "  -fore yellow -back black		
		write-Host "If the problem persists please contact PamEng. "  -fore yellow -back black		
		read-host "Press any key to continue "
		break
	}    

}

$nam1 = (get-date).month
$nam2 = (get-date).day
$nam3 = (get-date).year
$nam4 = (get-date).hour
$nam5 = (get-date).minute
$nam6 = $MyInvocation.MyCommand
$filename = "$nam1-$nam2-$nam3--$nam4-$nam5--$nam6-$global:cyberark_region--ExecutedBy-$env:username.txt"
$valid_admin = $true;

<# Script Main Code & Logging #>
try{

[System.DateTime]::Now

if ($global:input_method -eq $global:input_methods[1]) {
	<# Import file with headers and data #>
	$InputValues = Import-Csv -Path $VarInputFile
	}
else {
	<# Manually create input file #>
	do
    {
		[bool]$valLoop = $TRUE
        if($valErr) {
            Write-Host " "
			Write-Host "Wrong RITM, please use full RITM description. (Example RITM123456)." -foreGroundColor RED
			Write-Host "If the problem persist please contact PamEng." -foreGroundColor RED
			$valErr = $FALSE
        }
        try {
			$TmpRITM = Get-RITM
			$TmpRITM = $TmpRITM.ToUpper()
			$TmpRITM = $TmpRITM.Trim()	
			if ($TmpRITM.substring(0,4) -eq "RITM") {$valLoop = $FALSE} else {$valErr = $TRUE}
        }
        catch
        {  
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage = $ErrorMessage.ToString()
            $valErr = $TRUE
        } 
	}
	while($valLoop)

	do
    {
        [bool]$valLoop = $TRUE
        if($valErr) {
            Write-Host " "
            Write-Host "Error! Value is blank or not a valid employee 6 digit number." -foreGroundColor RED
            Write-Host "Please try again. If the problem persist please contact PamEng." -foreGroundColor RED
            $valErr = $FALSE
        }
        try {
			$TmpSafeIdentifier = Get-EmpID-Identifier
			$TmpSafeIdentifier = $TmpSafeIdentifier.Trim()
			if ($TmpSafeIdentifier.length -eq 6) {$valLoop = $FALSE} else {$valErr = $TRUE}
        }
        catch
        {  
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage = $ErrorMessage.ToString()
            $valErr = $TRUE
        } 
    }
    while($valLoop) 
		
#	if ($TmpSafeIdentifier.length -eq 6) {} else {Throw "Wrong Employee ID, please only use numbers and must be 6 digit long. (Example 712345).  If the problem persist, please contact PamEng to fix the code."}
	$TmpAccountPasswordSecure = Get-Account-Password
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TmpAccountPasswordSecure)
	$TmpAccountPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
		
	<# Build input file of 2 rows, 1st row labels, second row data #>
	$InputValues = [PSCustomObject]@{
		VarSafeIdentifier = $TmpSafeIdentifier
		VarRITM = $TmpRITM
		VarAccountPassword = $TmpAccountPassword
		}
	}

<# RestAPI LogIn into CyberArk to submit all input data #>
if(-not (Create-CyberArk-Session)){
	#Finish-Now; # User Cancelled
	$valid_admin = $false;
	return;  # User Cancelled
}

start-transcript -path "$global:files_drive$global:log_files_path\temp\$filename" |
out-null

Write-host ""
Write-host "*************************************************************************"
Write-host "This is the log transcript for" $nam6 "in CyberArk" $global:cyberark_region "ExecutedBy" $env:username
Write-host "*************************************************************************"


<# Create Safe Main Section based on input file data #>	
$InputValues | ForEach-Object {

	Write-host ""
	Write-host "******************************"
	Write-host "Processing data for" $_.VarRITM
	Write-host "******************************"
	Write-host ""
	
	$TmpSafeIdentifierFinal = $_.VarSafeIdentifier 
	$TmpSafeDescriptionFinal = $_.VarSafeIdentifier
	$TmpAccountUserNameFinal = "j$TmpSafeIdentifierFinal"
	$TmpAccountPassword = $_.VarAccountPassword
	$TmpAccountPasswordFinal = ConvertTo-SecureString "$TmpAccountPassword" -AsPlainText -force

	if ($global:cyberark_region -eq $global:cyberark_prod_region_tag) {
		$TmpSafeNameFinal = "P_$TmpSafeIdentifierFinal" 
		$TmpMember1 = "B-CyberPersonal-$TmpSafeIdentifierFinal"
		}	
	Else {
		$TmpSafeNameFinal = "P_$TmpSafeIdentifierFinal" 
		$TmpMember1 = "B-CyberNonDeveloper-AMO AD Sec-Win-PRD"
		}
	<# Add Standard Safe Members #>
	Add-PASSafe -SafeName $TmpSafeNameFinal -Description $TmpSafeDescriptionFinal -ManagingCPM PasswordManager -NumberOfDaysRetention 7
	Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName 'Vault Administrators' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true
	Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName 'Administrator' -SearchIn Vault -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -RequestsAuthorizationLevel 1 -AccessWithoutConfirmation $true -CreateFolders $true -DeleteFolders $true -MoveAccountsAndFolders $true
    
	<# Add Specific Safe Type Members based on region #>
	Add-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName $TmpMember1 -SearchIn 'DSGLOBAL' -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true -InitiateCPMAccountManagementOperations $true -ViewAuditLog $true -ViewSafeMembers $true
	if ($global:cyberark_region -eq $global:cyberark_prod_region_tag) {
		Add-PASAccount -Address 'dsglobal.org' -Username $TmpAccountUserNameFinal -PlatformID 'WindowsPersonal20Hours' -SafeName $TmpSafeNameFinal -Secret $TmpAccountPasswordFinal
		}
	else {
		Add-PASAccount -Address 'dsglobal.org' -Username $TmpAccountUserNameFinal -PlatformID 'WindowsPersonal20Hours' -SafeName $TmpSafeNameFinal -Secret $TmpAccountPasswordFinal
	}
	
	<# Rotate credential in personal account #>
	$TmpAccountDetailsFinal = Get-PASAccount -Keywords $TmpAccountUserNameFinal -Safe $TmpSafeNameFinal
	$TmpAccountIDFinal = $TmpAccountDetailsFinal.AccountID
   	Invoke-PASCPMOperation -AccountID $TmpAccountIDFinal -ChangeTask 

	<# Remove admin user creating Safe (Security Cleanup) #>
    	Remove-PASSafeMember -SafeName $TmpSafeNameFinal -MemberName $global:cyberark_cred.username
	}

Write-host "*********************************************************"
Write-host "All tasks for run" $nam6 "in CyberArk" $global:cyberark_region "are completed successfully" 
Write-Host "*********************************************************"
}
finally
{
If ($valid_admin) 
	{
	stop-transcript | Out-null
	}
}

<# Produce & email log and run notification #>
If ($valid_admin) 
{
	$log = Get-Content "$global:files_drive$global:log_files_path\temp\$filename"
	$logfixed = New-Object System.Text.StringBuilder; foreach ($line in $log){[void] $logfixed.AppendLine($line.ToString())}
	$bodyemail = "Find the log transcript attached for $nam6 executed at $global:cyberark_region by $env:username"
	new-item -Path $global:files_drive -Name $global:log_files_path\$nam6 -ItemType directory -ErrorAction SilentlyContinue
	$locfile = "$global:files_drive$global:log_files_path\$nam6\$filename"
	"Script: $logfixed"| out-file $locfile

	Send-MailMessage -From $global:caam_email_sender -To $global:caam_email_recepients -Subject "$nam6 run for $global:cyberark_region completed by $env:username" -body $bodyemail -Attachments $locfile -SmtpServer smtp1.dsglobal.org
	remove-item -path "$global:files_drive$global:log_files_path\temp\$filename"
}
}



End { }


}
