Function Get-FileName($initialDirectory)
<#

.SYNOPSIS
Open a dialog box to select an input CSV comma delimited file

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
This function was copied from https://devblogs.microsoft.com/scripting/hey-scripting-guy-can-i-open-a-file-dialog-box-with-windows-powershell/

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
initialDirectory - default path of input files

.EXAMPLE
Get-FileName -initialDirectory “c:\temp”

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

{  
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} 