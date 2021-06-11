Function Show-Acceptance-Menu()

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
Show-CyberArk-Acceptance-Menu

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

{

<# Acceptance default values #>
$global:cyberark_url = $global:cyberark_accp_url;
$global:cyberark_region = $global:cyberark_accp_region_tag;
$global:dap_write_url = $global:dap_write_accp_url;
$global:dap_read_url = $global:dap_read_accp_url;
$global:dap_write_url = $global:dap_write_accp_url;
$global:dap_account = $global:dap_accp_account;

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
    Write-Host "Option comming soon in 2021!" -ForegroundColor Red
    $err1 = $FALSE
  }
        
  <# Introduction to VOYA CyberArk Operations Automation #>
  Write-Host " "
  Write-Host "		                        CAAM (rls-2021.03-01)	     " -foreGroundColor magenta
  Write-Host "		               CyberArk Admin Automation Menu @ VOYA  " -foreGroundColor magenta
  Write-Host "		            FOR CYBERARK & CONJUR ACCEPTANCE TESTING ONLY    " -foreGroundColor magenta
  Write-Host "" 
  
  <# Creates menu and forces selection #>       
  Write-Host "** Acceptance Menu **" -foreGroundColor green
  Write-Host ""
  Write-Host "Make your sub-menu selection:"
  Write-Host -ForegroundColor White "1. " -NoNewline; Write-Host -ForegroundColor Gray "Safes"
  Write-Host -ForegroundColor White "2. " -NoNewline; Write-Host -ForegroundColor Gray "Accounts"
  Write-Host -ForegroundColor White "3. " -NoNewline; Write-Host -ForegroundColor Gray "Users"
  Write-Host -ForegroundColor White "4. " -NoNewline; Write-Host -ForegroundColor Gray "Reports"
  Write-Host -ForegroundColor White "5. " -NoNewline; Write-Host -ForegroundColor Gray "Utilities"
  Write-Host -ForegroundColor White "6. " -NoNewline; Write-Host -ForegroundColor Gray "Conjur/DAP"
  Write-Host -ForegroundColor White "7. " -NoNewline; Write-Host -ForegroundColor Gray "Nepis Migration"
  Write-Host ""
  Write-Host "Select " -NoNewline; Write-Host -ForegroundColor white "1-7, Q to return to main menu" -NoNewline
  $sMenuSelect = Read-Host " "
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
      $err1 = $TRUE
      # Show-Conjur-Menu
      }
    7 {
      $err = $FALSE
      Show-Nepis-Migration-Menu
      }       
    Q {
      $value = $FALSE
      }
    default { $err = $TRUE }
  }
}
while($value)
Return
}