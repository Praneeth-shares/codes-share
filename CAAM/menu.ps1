<#

.SYNOPSIS
Main menu and submenus brances of VOYA Financial CyberArk operations automation 

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of VOYA Financial CyberArk operations automation is prohibited from being copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
This is a tool to simplify and standarize the CyberArk operations for the AMO, PamEng & Support teams through automation and menu driven selections. 

.MODULES & FUNCTIONS REQUIRED
[psPAS] - https://github.com/pspete - Should be placed into PS paths prior to running the scripts
[Get-FileName] - Function-Get-Filename.ps1

.PARAMETERS
Not applicable

.EXAMPLE
.\menu.ps1

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

<# Import Modules & Functions #>
."./functions-CAAM/Function-Publish-CAAM-Settings.ps1"
."./functions-CAAM/Function-Publish-CyberArk-Settings.ps1"
."./functions-CAAM/Function-Publish-DAP-Settings.ps1"
."./functions-CAAM/Function-Publish-NePIS-Settings.ps1"
."./functions-CAAM/Function-Show-CyberArk-Safes-Menu.ps1"
."./functions-CAAM/Function-Show-Acceptance-Menu.ps1"
."./functions-CAAM/Function-Show-NePIS-Migration-Menu.ps1"
."./functions-CAAM/Function-Show-ConjurDAP-Menu.ps1"

<# Load Application Properties & needed modules #>
Set-ExecutionPolicy Bypass -Scope process -Force
Import-Module pspas 
Publish-CAAM-Settings;
Publish-CyberArk-Settings;
Publish-DAP-Settings;
Publish-NePIS-Settings;

<# Global CAAM static values #>
$global:caam_email_sender = $global:caam_email_sender
[string[]]$global:caam_email_recepients = $global:caam_email_recepients -split ","
$global:files_drive = $global:files_drive
$global:log_files_path = $global:log_files_path
$global:input_files_path = $global:input_files_path
[string[]]$global:input_methods  = $global:input_methods -split ","
$global:default_input_method = $global:default_input_method

<# Global CyberArk static values #>
$global:cyberark_prod_url = $global:cyberark_prod_url
$global:cyberark_accp_url = $global:cyberark_accp_url
$global:cyberark_prod_region_tag = $global:cyberark_prod_region_tag
$global:cyberark_accp_region_tag = $global:cyberark_accp_region_tag

<# Global Conjur/DAP static values #>
$global:dap_write_prod_url = $global:dap_write_prod_url
$global:dap_write_accp_url = $global:dap_write_accp_url
$global:dap_read_prod_url = $global:dap_read_prod_url
$global:dap_read_accp_url = $global:dap_read_accp_url
$global:dap_dev_url = $global:dap_dev_url
$global:dap_prod_account = $global:dap_prod_account
$global:dap_accp_account = $global:dap_accp_account
$global:dap_dev_account = $global:dap_dev_account
$global:dap_policy_output_path = $global:dap_policy_output_path

<# Production default values #>
$global:cyberark_url = $global:cyberark_prod_url;
$global:cyberark_region = $global:cyberark_prod_region_tag;
$global:dap_write_url = $global:dap_write_prod_url;
$global:dap_read_url = $global:dap_read_prod_url;
$global:dap_write_url = $global:dap_write_prod_url;
$global:dap_account = $global:dap_prod_account;

<# Other default values #>
$global:input_method = $global:default_input_method

<# Build folder support structure #>
new-item -Path $global:files_drive -Name $global:log_files_path -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:log_files_path\temp -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:input_files_path -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\voya -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-prod -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-prod\voya -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-prod\voya-pp -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-accp -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-accp\voya -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-accp\voya-pp -ItemType directory -ErrorAction SilentlyContinue
new-item -Path $global:files_drive -Name $global:dap_policy_output_path\cybr-accp\voya-dev -ItemType directory -ErrorAction SilentlyContinue

<# local variables #>
[bool]$value = $TRUE
[bool]$err = $FALSE
[bool]$err1 = $FALSE

do
{
  Clear-Host
        
  if($err)
  {
    Write-Host " "
    Write-Host "The selection could not be determined, try again!" -ForegroundColor Red
    $err = $FALSE
  }

  if($err1)
  {
    Write-Host " "
    Write-Host "Option comming in CAAM September release of 2021!" -ForegroundColor Red
    $err1 = $FALSE
  }
        
  <# Introduction to VOYA CyberArk Operations Automation #>
  Write-Host " "
  Write-Host "		                        CAAM (rls-2021.03-02)	     " -foreGroundColor magenta
  Write-Host "		               CyberArk Admin Automation Menu @ VOYA  " -foreGroundColor magenta
  Write-Host "		            For questions email PAMEngineering@voya.com   " -foreGroundColor magenta
  Write-Host "			  	    USE THESE APP WITH CAUTION		" -foreGroundColor magenta
  Write-Host "" 
  
  <# Creates menu and forces selection #>       
  Write-Host "** Main Menu **" -foreGroundColor green
  Write-Host ""
  Write-Host "Make your sub-menu selection:"
  Write-Host -ForegroundColor White "1. " -NoNewline; Write-Host -ForegroundColor Gray "Safes"
  Write-Host -ForegroundColor DarkGray "2. " -NoNewline; Write-Host -ForegroundColor DarkGray "Accounts"
  Write-Host -ForegroundColor DarkGray "3. " -NoNewline; Write-Host -ForegroundColor DarkGray "Users"
  Write-Host -ForegroundColor DarkGray "4. " -NoNewline; Write-Host -ForegroundColor DarkGray "Reports"
  Write-Host -ForegroundColor DarkGray "5. " -NoNewline; Write-Host -ForegroundColor DarkGray "Utilities"
  Write-Host -ForegroundColor White "6. " -NoNewline; Write-Host -ForegroundColor Gray "Conjur/DAP"
  Write-Host -ForegroundColor White "7. " -NoNewline; Write-Host -ForegroundColor Gray "Nepis Migration"
  Write-Host -ForegroundColor DarkGray "8. " -NoNewline; Write-Host -ForegroundColor DarkGray "CyberArk/Conjur ACCP"
  Write-Host ""
  Write-Host "Select " -NoNewline; Write-Host -ForegroundColor white "1 or 7" -NoNewline
  $sMenuSelect = Read-Host ". Q to quit CAAM Application"
  Write-Host ""
		
  <# Executes actions based on selection #>    
  switch($sMenuSelect)
  {
    1 {
      $err = $FALSE
      Show-CyberArk-Safes-Menu
      }
    2 {
      $err1 = $TRUE
      # Show-CyberArk-Accounts-Menu
      }
    3 {
      $err1 = $TRUE
      # Show-CyberArk-Users-Menu
      }
    4 {
      $err1 = $TRUE
      # Show-CyberArk-Reports-Menu
      }
    5 {
      $err1 = $TRUE
      # Show-CyberArk-Utilities-Menu
      }
    6 {
      $err1 = $FALSE
      Show-ConjurDAP-Menu
      }
    7 {
      $err = $FALSE
      Show-NePIS-Migration-Menu
      }       
    8 {
      $err1 = $FALSE
      Show-Acceptance-Menu
      }                  
    Q {
      Write-Host "Goodbye $env:username !"
      $value = $FALSE
      }
    default { $err = $TRUE }
  }
}
while($value)
