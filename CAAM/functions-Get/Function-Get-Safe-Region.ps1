function Get-Safe-Region {
<#

.SYNOPSIS
Requests input from user, provides help on content and errors out if null

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.DESCRIPTION
See Synopsis Section

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
Prompts the user to enter a value for the mandatory unique parameter

.EXAMPLE
$VariableName = Get-Safe-Region

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'CyberArk Safe Region'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select the target region for the account:'
$form.Controls.Add($label)

$listBox1 = New-Object System.Windows.Forms.ListBox
$listBox1.Location = New-Object System.Drawing.Point(10,40)
$listBox1.Size = New-Object System.Drawing.Size(260,20)
$listBox1.Height = 80

[void] $listBox1.Items.Add('production')
[void] $listBox1.Items.Add('non-production-accp')
[void] $listBox1.Items.Add('non-production-intg')
[void] $listBox1.Items.Add('non-production-unit')
#[void] $listBox1.Items.Add('non-production-dev')
#[void] $listBox1.Items.Add('accp')
#[void] $listBox1.Items.Add('intg')
#[void] $listBox1.Items.Add('unit')
#[void] $listBox1.Items.Add('eng')

$form.Controls.Add($listBox1)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
		$SafeRegion = $listBox1.SelectedItem
    }
 $SafeRegion
}