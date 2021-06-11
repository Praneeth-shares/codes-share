Function Show-ConjurDAP-Menu([bool]$Wipe)

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
  <# Import Modules & Functions #>
#  ."./functions-Conjur/Function-New-Conjur-Host.ps1"

  <# Menu Variables #>
  [bool]$smValue = $TRUE
  [bool]$smErr = $FALSE
  [bool]$smErr1 = $FALSE  

  <# User error input control #>  
  do
  {
    if($Wipe) { Clear-Host }
        
    if($smErr) {
      Clear-Host
      Write-Host " "
      Write-Host "The selection could not be determined, try again!" -foreGroundColor RED
    }

    if($smerr1)
    {
      Clear-Host
      Write-Host " "
      Write-Host "Option comming in CAAM May Release of 2021!" -ForegroundColor Red
      $err1 = $FALSE
    }
    
    <# Creates menu and forces selection #>
    Write-Host " "
    Write-Host " "
    Write-Host "** Conjur-DAP Menu **" -foreGroundColor green
    Write-Host " "
    Write-Host "Make your selection:"
    Write-Host -ForegroundColor Magenta "Host actions -------"
    Write-Host -ForegroundColor White "1. " -NoNewline; Write-Host -ForegroundColor Gray "Add host"
    Write-Host -ForegroundColor White "2. " -NoNewline; Write-Host -ForegroundColor Gray "Change host token"
    Write-Host -ForegroundColor White "3. " -NoNewline; Write-Host -ForegroundColor Gray "List host secrets"
    Write-Host -ForegroundColor DarkGray "4. " -NoNewline; Write-Host -ForegroundColor DarkGray "Validate host token"
    Write-Host -ForegroundColor Magenta "Secret actions -------"
    Write-Host -ForegroundColor DarkGray "10. " -NoNewline; Write-Host -ForegroundColor DarkGray "List safe and secrets"
    Write-Host -ForegroundColor DarkGray "11. " -NoNewline; Write-Host -ForegroundColor DarkGray "Add host access to secret"
    Write-Host ""
    Write-Host "Select " -NoNewline; Write-Host -ForegroundColor White "1, 2, 3, 4, 10 or 11" -NoNewline
    $sMenuSelect = Read-Host ". Q to return to Main Menu"
    Write-Host ""

		<# Executes actions based on selection #>    
    switch ($sMenuSelect)
    {
      1 {
        $smErr = $FALSE
        Clear-Host
#        New-Conjur-Host
      }
      2 {
        $smErr = $TRUE
#        Clear-Host
#        New-CyberArk-Safe-Conjur
      }
      3 {
        $smErr = $TRUE
#        Clear-Host
#        Remove-CyberArk-Safe-Standard
      }  
      4 {
        $smErr1 = $TRUE
      }
      5 {
        $smErr1 = $TRUE
      }
      10 {
        $smErr1 = $TRUE
      }
      11 {
        $smErr1 = $TRUE
     }
      12 {
        $smErr = $TRUE
#        $global:input_method = $global:input_methods[1]
#        Remove-CyberArk-Safe-Standard      
        }
      13 {
        $smErr1 = $TRUE
      }      
      14 {
        $smErr1 = $TRUE
      }      
      Q {
        $smValue = $FALSE
      }
      default { $smErr = $TRUE }
    }
    $global:input_method = $global:default_input_method  
  }
  while($smValue)
}