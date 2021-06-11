."./functions-NePIS/Function-Migrate-NePIS-Applications.ps1"
."./functions-NePIS/Function-Print-NePIS-Credentials.ps1"
#."./functions-NePIS/Function-Create-DAP-Safes-Accounts.ps1"

<# Submenu for NePIS Migration #>
Function Show-NePIS-Migration-Menu([bool]$ssmWipe)
{

  [bool]$ssmValue = $TRUE
  [bool]$ssmErr = $FALSE

  do
  {
    if($ssmWipe) { Clear-Host }
        
    if($smmErr) {
      Write-Host " "
      Write-Host "The selection could not be determined, try again!" -foreGroundColor RED
    }

		<# Creates menu and forces selection #>
    Write-Host " "
    Write-Host " "
    Write-Host "** NePIS Migration Menu **" -foreGroundColor green
    Write-Host " "
    Write-Host "Make your selection:"
    Write-Host -ForegroundColor White "1. " -NoNewline; Write-Host -ForegroundColor Gray "Migrate Applications to CyberArk"
    Write-Host -ForegroundColor White "2. " -NoNewline; Write-Host -ForegroundColor Gray "Print NePIS Credentials"
#    Write-Host -ForegroundColor White "3. " -NoNewline; Write-Host -ForegroundColor Gray "Create Custom DAP Safe & Accounts"
    Write-Host ""
		Write-Host "Select " -NoNewline; Write-Host -ForegroundColor White "1 or 2" -NoNewline
    $sMenuSelect = Read-Host ". Q to return to Main Menu"
    Write-Host ""

    <# Executes actions based on selection #>    
    switch ($sMenuSelect)
    {
      1 {
        $ssmErr = $FALSE;
        Migrate-NePIS-Applications;
      }

      2 {
        $ssmErr = $FALSE;
        Print-NePIS-Credentials;
      }

#      3 {
#        $ssmErr = $FALSE;
#        Create-DAP-Safes-Accounts;
#      }

      Q {
        $ssmValue = $FALSE
      }
      default { $ssmErr = $TRUE }
    }
  }
  while($ssmValue)
}