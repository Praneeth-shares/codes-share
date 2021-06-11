Function Show-CyberArk-Safes-Menu([bool]$Wipe)

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
#  ."./functions-Safes/Function-Add-Safe-CYBR-Personal.ps1"
#  ."./functions-Safes/Function-Remove-Safe-CYBR.ps1"
  ."./functions-CyberArk/Function-New-CyberArk-Safe-Conjur.ps1"
  ."./functions-CyberArk/Function-New-CyberArk-Safe-Standard.ps1"
  ."./functions-CyberArk/Function-Remove-CyberArk-Safe-Standard.ps1"

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
    Write-Host "** Safe Menu **" -foreGroundColor green
    Write-Host " "
    Write-Host "Make your selection:"
    Write-Host -ForegroundColor Magenta "Single safe actions -------"
    Write-Host -ForegroundColor White "1. " -NoNewline; Write-Host -ForegroundColor Gray "Add standard safe"
    Write-Host -ForegroundColor White "2. " -NoNewline; Write-Host -ForegroundColor Gray "Add Conjur safe"
    Write-Host -ForegroundColor White "3. " -NoNewline; Write-Host -ForegroundColor Gray "Remove standard safe"
    Write-Host -ForegroundColor DarkGray "4. " -NoNewline; Write-Host -ForegroundColor DarkGray "Remove Conjur safe"
    Write-Host -ForegroundColor DarkGray "5. " -NoNewline; Write-Host -ForegroundColor DarkGray "Move accounts to a new safe"
    Write-Host -ForegroundColor Magenta "Bulk actions -------"
    Write-Host -ForegroundColor DarkGray "10. " -NoNewline; Write-Host -ForegroundColor DarkGray "Add standard safes"
    Write-Host -ForegroundColor DarkGray "11. " -NoNewline; Write-Host -ForegroundColor DarkGray "Add Conjur safes"
    Write-Host -ForegroundColor White "12. " -NoNewline; Write-Host -ForegroundColor Gray "Remove standard safes"
    Write-Host -ForegroundColor DarkGray "13. " -NoNewline; Write-Host -ForegroundColor DarkGray "Remove Conjur safes"
    Write-Host -ForegroundColor DarkGray "14. " -NoNewline; Write-Host -ForegroundColor DarkGray "Move accounts in multiple safes"
    Write-Host ""
    Write-Host "Select " -NoNewline; Write-Host -ForegroundColor White "1, 2, 3 or 12" -NoNewline
    $sMenuSelect = Read-Host ". Q to return to Main Menu"
    Write-Host ""

		<# Executes actions based on selection #>    
    switch ($sMenuSelect)
    {
      1 {
        $smErr = $FALSE
        Clear-Host
        New-CyberArk-Safe-Standard
      }
      2 {
        $smErr = $FALSE
        Clear-Host
        New-CyberArk-Safe-Conjur
      }
      3 {
        $smErr = $FALSE
        Remove-CyberArk-Safe-Standard
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
        $smErr = $FALSE
        $global:input_method = $global:input_methods[1]
        Remove-CyberArk-Safe-Standard      }
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