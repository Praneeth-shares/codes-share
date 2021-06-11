function Get-PCF-Space-Prod {
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
The ServiceNow RITM #

.EXAMPLE
$VariableName = Get-PCF-Space-Prod -RITM RITM123456

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Sergio Bascon @ 9/11/2020
History of maintenances:

#>

Param(
	[parameter(Mandatory = $true)]
	[string]$RITM
	)
$RITM

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = $RITM
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
$label.Text = 'Please select a PCF Space:'
$form.Controls.Add($label)

$listBox2 = New-Object System.Windows.Forms.ListBox
$listBox2.Location = New-Object System.Drawing.Point(10,40)
$listBox2.Size = New-Object System.Drawing.Size(260,20)
$listBox2.Height = 80

[void] $listBox2.Items.Add('prod-external')
[void] $listBox2.Items.Add('prod-internal')
#[void] $listBox2.Items.Add('accp-external')
#[void] $listBox2.Items.Add('accp-internal')

$form.Controls.Add($listBox2)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
		$PCFSpaceProd = $listBox2.SelectedItem
    }
 return $PCFSpaceProd
}