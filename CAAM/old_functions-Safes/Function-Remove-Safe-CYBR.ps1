Function Remove-Safe-CYBR {
<#

.SYNOPSIS
Deletes Safe/Safes in CyberArk for Personal user IDs

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of VOYA Financial CyberArk operations automation is prohibited from being copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
Delete Safe/Safes in CyberArk for to host personal service accounts. 
This function will be Deleting Safe/Safes from CyberArk

.MODULES & FUNCTIONS REQUIRED
[psPAS] - https://github.com/pspete - Should be placed into PS paths prior to running the scripts
[Get-FileName] - Function-Get-Filename.ps1
[Get-RITM] - Function-Get-RITM.ps1
[Get-App-Identifier] - Function-Get-Safename-Identifier.ps1
[Get-Safename] - Function-Get-Safename.ps1
[Get-Safe-Description] - Function-Get-Safe-Description.ps1
[Get-Safe-Region] - Function-Get-Safe-Region.ps1
[Get-Safe-Region-Accp] - Function-Get-Safe-Region-Accp.ps1

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 11/18/2020
History of maintenances:

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
	Write-Host "VarSafeName,VarRITM" -fore green -back black 
	Write-Host "P_799999,RITM9999999" -fore green -back black 
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
$filename = "$nam1-$nam2-$nam3--$nam4-$nam5--$nam6--$global:cyberark_region--ExecutedBy-$env:username.txt"
$valid_admin = $true;

<# Script Main Code & Logging #>
try{

#$Startdate = [DateTime]::Now
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
        $TmpSafeName = ""
        if($valErr) {
            Write-Host " "
            Write-Host "Error! Value is blank. You need to type the safe name." -foreGroundColor RED
            Write-Host "If the problem persist please contact PamEng." -foreGroundColor RED
            $valErr = $FALSE
        }
        try {
            $TmpSafeName = Get-SafeName
            $TmpSafeName = $TmpSafeName.Trim()
            if ($TmpSafeName -eq "") {$valErr = $TRUE} else {$valLoop = $FALSE}
        }
        catch
        {  
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage = $ErrorMessage.ToString()
            $valErr = $TRUE
        } 
    }
    while($valLoop)    
    
	$InputValues = [PSCustomObject]@{
		VarSafeName = $TmpSafeName
		VarRITM = $TmpRITM
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

<# Remove Safe Main Section based on input file data #>	
$InputValues | ForEach-Object {

	Write-host ""
	Write-host "**********************************************************************"
	Write-host "Processing data for" $_.VarRITM "/ Safe " $_.VarSafeName
	Write-host "**********************************************************************"
	Write-host ""

    $TmpSafeNameFinal = $_.VarSafeName
    $TmpErrorMessage = ""
    try {
        Remove-PASSafe -SafeName $TmpSafeNameFinal 
        }
    catch
    {   
        $ErrorMessage = $_.Exception.Message
        $ErrorMessage = $ErrorMessage.ToString()
        
        if($ErrorMessage.contains('404'))
        {
#            write-output "Safe $TmpSafeNameFinal not found! Please verify you have typed it correctly."
            $TmpErrorMessage = "Safe $TmpSafeNameFinal not found! Please verify you have typed it correctly." 
        }

        if ($ErrorMessage.contains('500'))
        {
#            Write-Output "Safe $TmpSafeNameFinal has non-expiring objects. Objects have been marked as deleted & please retry deletion of safe again in 7 days."
            $TmpErrorMessage = "Safe $TmpSafeNameFinal has non-expiring objects. Objects flagged for deletions, please retry safe deletion in 7 days." 
        }
        write-host " "        
        write-host "************** Error summary below ************ " -ForegroundColor Red;
        write-host $TmpErrorMessage -ForegroundColor Red;
    }   
    
#    Write-Output $TmpErrorMessage

	}
Write-host ""
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