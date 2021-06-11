Function Get-Meta-Info-CyberArk-Safe-Conjur()
<#

.SYNOPSIS
Create a form to get some meta info from the user about this migration including the RITM # and whether it is PCF (and the orgs and spaces if so).

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
Not applicable

.PARAMETERS
None

.EXAMPLE
Get-Meta-Migration-Info

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 02/04/2021

#>

{

	# Global variable to store migation meta data. Structured like this:
	<#
		{
			"ritm": "RITM123456",
			"application_name": "Non Personal ID Solution (PRD)",
			"pcf_foundation": "pp", 									# optional field
			"pcf_org_guid": "0d6740ff-58b5-4dd7-8a73-8d05654649fa", 	# optional field
			"pcf_space_guid": "64d8cb48-f05e-452e-81a3-4669ec064aed" 	# optional field
			"verify_passwords": true,
			"show_passwords": false,
			"auto_vault_compliant_accounts": true
		}	
	#>
	$global:migration_meta = $null;

	# Import Dependencies
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null;
	Add-Type -AssemblyName PresentationCore, PresentationFramework


	# Load PCF information into two structures like this
	<#
		$org_map = {
			"pp": {
				"apptx-sandbox-org": "0d6740ff-58b5-4dd7-8a73-8d05654649fa",
				...
			},
			...
		}

		$space_map = {
			"pp": {
				"apptx-sandbox-org": {
					"b2bdev": "64d8cb48-f05e-452e-81a3-4669ec064aed",
					...
				},
				...
			},
			...
		}
	#>
	$org_map = @{};
	$space_map = @{};
	$pcf_files = Get-ChildItem "./system-Settings/PCF";
	foreach($pcf_file in $pcf_files){
		$foundation = $pcf_file -replace "guid-map-intrepid" -replace ".json";
		$orgs_data = (Get-Content -Raw -Path "./system-Settings/PCF/$($pcf_file)" | ConvertFrom-Json).Orgs;
		$org_map[$foundation] = @{};
		$space_map[$foundation] = @{};
		foreach($org_data in $orgs_data){
			$spaces = @{};
			foreach($space_data in $org_data.Spaces){
				$spaces[$space_data.Name] = $space_data.Guid;				
			}
			$org_map[$foundation][$org_data.Name] = $org_data.Guid;
			$space_map[$foundation][$org_data.Name] = $spaces;
		}
	}

	# $org_map | ConvertTo-Json -Depth 10;
	# $space_map | ConvertTo-Json -Depth 10;
	# return;

	
	# Function for creating 2D vectors
	function vec2([int32]$x, [int32]$y){
		return New-Object System.Drawing.Size($x, $y);
	}

	# Main Form
	$form = New-Object System.Windows.Forms.Form;
	$form.Text = "Conjur Safe Info";
	$form.Size = vec2 340 580;
	$form.StartPosition = "CenterScreen";
	$form.AutoScroll = $true;
	$form.AutoSizeMode = "GrowOnly";

	$basex = 100;
	$basey = 10;

	# Define variables for later in the form
	$combo_region = New-Object System.Windows.Forms.ComboBox;
	$combo_foundation = New-Object System.Windows.Forms.ComboBox;
	$combo_org = New-Object System.Windows.Forms.ComboBox;
	$combo_space = New-Object System.Windows.Forms.ComboBox;
	$chk_verify = New-Object System.Windows.Forms.CheckBox;
	$chk_include_virtualname = New-Object System.Windows.Forms.CheckBox;
	$txt_numberaccountskey = New-Object System.Windows.Forms.TextBox;
	
	# unintuitive, but these are arrays that will hold the blocks that update combo_org and combo_space
	$update_combo_org = @({ Write-Host "Could not update `$combo_org"});
	$update_combo_space = @({ Write-Host "Could not update `$combo_space"});

	# RITM Field
	$lbl_ritm = New-Object System.Windows.Forms.Label;
	$lbl_ritm.Location = vec2 0 $basey;
	$lbl_ritm.Size = vec2 ($basex-4) 25;
	$lbl_ritm.TextAlign = "MiddleRight";
	$lbl_ritm.Text = "RITM";
	$form.Controls.Add($lbl_ritm);
	$txt_ritm = New-Object System.Windows.Forms.TextBox;
	$txt_ritm.Location = vec2 $basex ($basey+4);
	$txt_ritm.Size = vec2 100 25;
	$txt_ritm.Text = "";
	$txt_ritm.Name = "txt_ritm";
	$form.Controls.Add($txt_ritm);

	$basey += 30;

	# Application Field
	$lbl_app = New-Object System.Windows.Forms.Label;
	$lbl_app.Location = vec2 0 $basey;
	$lbl_app.Size = vec2 ($basex-4) 25;
	$lbl_app.TextAlign = "MiddleRight";
	$lbl_app.Text = "Application Name";
	$form.Controls.Add($lbl_app);
	$txt_app = New-Object System.Windows.Forms.TextBox;
	$txt_app.Location = vec2 $basex ($basey+4);
	$txt_app.Size = vec2 200 25;
	$txt_app.Text = "";
	if($txt_app.value -eq ""){
		$txt_app.BackColor = "Pink";
	}
	$txt_app.Name = "txt_app";
	$form.Controls.Add($txt_app);

	$basey += 30;

	# Application UNID Field
	$lbl_appunid = New-Object System.Windows.Forms.Label;
	$lbl_appunid.Location = vec2 0 $basey;
	$lbl_appunid.Size = vec2 ($basex-4) 25;
	$lbl_appunid.TextAlign = "MiddleRight";
	$lbl_appunid.Text = "Application UNID";
	$form.Controls.Add($lbl_appunid);
	$txt_appunid = New-Object System.Windows.Forms.TextBox;
	$txt_appunid.Location = vec2 $basex ($basey+4);
	$txt_appunid.Size = vec2 200 25;
	$txt_appunid.Text = "";
	$txt_appunid.Name = "txt_appunid";
	$form.Controls.Add($txt_appunid);

	$basey += 30;

	# Application Region (Combobox)
	$lbl_application_region = New-Object System.Windows.Forms.Label;
	$lbl_application_region.Location = vec2 0 $basey;
	$lbl_application_region.Size = vec2 ($basex-4) 25;
	$lbl_application_region.TextAlign = "MiddleRight";
	$lbl_application_region.Text = "Application Region";
	$form.Controls.Add($lbl_application_region);
	$combo_applicationregion = New-Object System.Windows.Forms.ComboBox;
	$combo_applicationregion.Location = vec2 $basex ($basey+4);
	$combo_applicationregion.Size = vec2 170 30;
	$combo_applicationregion.Text = $applicationregion.value;
#	$combo_applicationregion.Text = "";
	if($compbo_applicationregion.value -eq ""){
		$combo_applicationregion.BackColor = "Pink";
	}
	$combo_applicationregion.Items.Add("Production") | Out-Null;
	$combo_applicationregion.Items.Add("Acceptance") | Out-Null;
	$combo_applicationregion.Items.Add("Integration") | Out-Null;
	$combo_applicationregion.Items.Add("Unit") | Out-Null;
	$combo_applicationregion.Items.Add("Other") | Out-Null;

	$combo_applicationregion.Add_SelectedIndexChanged({
		if($combo_applicationregion.Text -eq "Production"){
			$combo_foundation.Text = "production";
			Invoke-Command -ScriptBlock $update_combo_org[0];
			Invoke-Command -ScriptBlock $update_combo_space[0];
		} elseif($combo_applicationregion.Text -eq "Other") {
			$combo_foundation.Text = "eng";
			Invoke-Command -ScriptBlock $update_combo_org[0];
			Invoke-Command -ScriptBlock $update_combo_space[0];
		} else {
			$combo_foundation.Text = "pre-production";
			Invoke-Command -ScriptBlock $update_combo_org[0];
			Invoke-Command -ScriptBlock $update_combo_space[0];
		}
	}.GetNewClosure());
#	$combo_applicationregion.Name = "txt_" + $safe_index + "." + $applicationregion.name;
	$combo_applicationregion.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
#	$textboxes.Add($combo_applicationregion) | Out-Null;
	$form.Controls.Add($combo_applicationregion);
	
	$basey += 30;

	# Application type Traditional or PCF Selector
	$lbl_application_type = New-Object System.Windows.Forms.Label;
	$lbl_application_type.Location = vec2 0 $basey;
	$lbl_application_type.Size = vec2 ($basex-4) 25;
	$lbl_application_type.TextAlign = "MiddleRight";
	$lbl_application_type.Text = "Application Type";
	$form.Controls.Add($lbl_application_type);
	$combo_application_type = New-Object System.Windows.Forms.ComboBox;
	$combo_application_type.Location = vec2 $basex ($basey+3);
	$combo_application_type.Size = vec2 170 30;
	$combo_application_type.Text = "Traditional";
	$combo_application_type.Name = "application_type";
	$combo_application_type.Items.Add("Traditional") | Out-Null;
	$combo_application_type.Items.Add("PCF") | Out-Null;
	$form.Controls.Add($combo_application_type);
	$combo_application_type.Add_SelectedIndexChanged({
		if($combo_application_type.Text -eq "Traditional"){
			$combo_foundation.Enabled = $false;
			$combo_org.Enabled = $false;
			$combo_space.Enabled = $false;
			$chk_include_virtualname.Enabled = $false;
			$chk_include_virtualname.Checked = $false;
		} elseif($combo_application_type.Text -eq "PCF") {
			$combo_foundation.Enabled = $false;
			$combo_org.Enabled = $true;
			$combo_space.Enabled = $true;
			$chk_include_virtualname.Enabled = $false;
			$chk_include_virtualname.Checked = $true;	
		}
	}.GetNewClosure());
	$combo_application_type.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling

	$basey += 30;
	#$basex = 130;

	# PCF Foundation Selector
	$lbl_foundation = New-Object System.Windows.Forms.Label;
	$lbl_foundation.Location = vec2 0 $basey;
	$lbl_foundation.Size = vec2 ($basex-4) 25;
	$lbl_foundation.TextAlign = "MiddleRight";
	$lbl_foundation.Text = "PCF Foundation";
	$form.Controls.Add($lbl_foundation);
	$combo_foundation.Location = vec2 $basex ($basey+3);
	$combo_foundation.Size = vec2 170 30;
	$combo_foundation.Name = "pcf_foundation";
	$combo_foundation.Text = @($org_map.Keys)[0];
#	$combo_foundation.Text = $combo_foundation.Text;
#	$update_combo_foundation[0] = {
#		$combo_foundation.Items.Clear();
#		$combo_foundation.Text = $combo_foundation.Text;
#		}
#	}.GetNewClosure();
#	$combo_foundation.Text = @($org_map.Keys)[0];
	foreach($foundation in $org_map.Keys){
		$combo_foundation.Items.Add($foundation) | Out-Null;
	}	
	$form.Controls.Add($combo_foundation);
	$combo_foundation.Enabled = $false;
	$combo_foundation.Add_SelectedIndexChanged({
		Invoke-Command -ScriptBlock $update_combo_org[0];
		Invoke-Command -ScriptBlock $update_combo_space[0];
	}.GetNewClosure());
	$combo_foundation.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling

	$basey += 30;

	# PCF Org Selector
	$lbl_org = New-Object System.Windows.Forms.Label;
	$lbl_org.Location = vec2 0 $basey;
	$lbl_org.Size = vec2 ($basex-4) 25;
	$lbl_org.TextAlign = "MiddleRight";
	$lbl_org.Text = "PCF Org";
	$form.Controls.Add($lbl_org);
	$combo_org.Location = vec2 $basex ($basey+3);
	$combo_org.Size = vec2 170 30;
	$combo_org.Name = "pcf_org";
	$update_combo_org[0] = {
		$combo_org.Items.Clear();
		$orgs = @($org_map[$combo_foundation.Text].Keys);
		$combo_org.Text = $orgs[0];
		foreach($org in $orgs){
			$combo_org.Items.Add($org) | Out-Null;
		}
	}.GetNewClosure();
	$combo_org.Add_SelectedIndexChanged({
		Invoke-Command -ScriptBlock $update_combo_space[0];
	}.GetNewClosure());
	Invoke-Command -ScriptBlock $update_combo_org[0];
	$form.Controls.Add($combo_org);
	$combo_org.Enabled = $false;
	$combo_org.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
	
	$basey += 30;

	# PCF Space Selector
	$lbl_space = New-Object System.Windows.Forms.Label;
	$lbl_space.Location = vec2 0 $basey;
	$lbl_space.Size = vec2 ($basex-4) 25;
	$lbl_space.TextAlign = "MiddleRight";
	$lbl_space.Text = "PCF Space";
	$form.Controls.Add($lbl_space);
	$combo_space.Location = vec2 $basex ($basey+3);
	$combo_space.Size = vec2 170 30;
	$combo_space.Name = "pcf_space";
#	$form.Controls.Add($combo_space);
#	$combo_space.Enabled = $false;
	$update_combo_space[0] = {
		$combo_space.Items.Clear();
		$spaces = @($space_map[$combo_foundation.Text][$combo_org.Text].Keys);
		$combo_space.Text = $spaces[0];
		foreach($space in $spaces){
			$combo_space.Items.Add($space) | Out-Null;
		}
	}.GetNewClosure();
	Invoke-Command -ScriptBlock $update_combo_space[0];
	$form.Controls.Add($combo_space);
	$combo_space.Enabled = $false;
	$combo_space.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
	
	$basey += 40;
	$basex = 80;

	# Application UNID Field
	$lbl_account_section = New-Object System.Windows.Forms.Label;
	$lbl_account_section.Location = vec2 0 $basey;
	$lbl_account_section.Size = vec2 160 25;
	$lbl_account_section.TextAlign = "MiddleRight";
	$lbl_account_section.Text = "Account(s) Requirements:";
	$form.Controls.Add($lbl_account_section);

	$basey += 35;
	$basex = 225;

	# Number of Password Accounts
	$lbl_numberaccountspassword = New-Object System.Windows.Forms.Label;
	$lbl_numberaccountspassword.Location = vec2 0 $basey;
	$lbl_numberaccountspassword.Size = vec2 ($basex-4) 25;
	$lbl_numberaccountspassword.TextAlign = "MiddleRight";
	$lbl_numberaccountspassword.Text = "Add password type accounts";
	$form.Controls.Add($lbl_numberaccountspassword);
	$txt_numberaccountspassword = New-Object System.Windows.Forms.TextBox;
	$txt_numberaccountspassword.Location = vec2 $basex ($basey+4);
	$txt_numberaccountspassword.Size = vec2 20 25;
	$txt_numberaccountspassword.Text = "0";
	$txt_numberaccountspassword.Name = "txt_numberaccountspassword";
	$form.Controls.Add($txt_numberaccountspassword);

	$basey += 35;
	$basex = 225;

	# Number of APIKey Accounts
	$lbl_numberaccountskey = New-Object System.Windows.Forms.Label;
	$lbl_numberaccountskey.Location = vec2 0 $basey;
	$lbl_numberaccountskey.Size = vec2 ($basex-4) 25;
	$lbl_numberaccountskey.TextAlign = "MiddleRight";
	$lbl_numberaccountskey.Text = "Add API-SSH Key type accounts";
	$form.Controls.Add($lbl_numberaccountskey);
	$txt_numberaccountskey.Location = vec2 $basex ($basey+4);
	$txt_numberaccountskey.Size = vec2 20 25;
	$txt_numberaccountskey.Text = "0";
	$txt_numberaccountskey.Name = "txt_numberaccountskey";
	$txt_numberaccountskey.Enabled = $false;
	$form.Controls.Add($txt_numberaccountskey);

	$basey += 30;
	$basex = 117;

	# Include virtualname checkbox
	$chk_include_virtualname.Location = vec2 ($basex) ($basey);
	$chk_include_virtualname.Size = vec2 123 30;
#	$chk_include_virtualname.Checked = $false;
	$chk_include_virtualname.Enabled = $false;	
	$chk_include_virtualname.CheckAlign = "MiddleRight";
	$chk_include_virtualname.Text = "Include Virtualname";
	$form.Controls.Add( $chk_include_virtualname);

	$basey += 30;
	$basex = 156;

	# Include port checkbox
	$chk_include_port = New-Object System.Windows.Forms.CheckBox;
	$chk_include_port.Location = vec2 ($basex) ($basey);
	$chk_include_port.Size = vec2 84 30;
	$chk_include_port.Checked = $false;
	$chk_include_port.CheckAlign = "MiddleRight";
	$chk_include_port.Text = "Include Port";
	$form.Controls.Add( $chk_include_port);
	
	$basey += 30;
	$basex = 128;

	# Verify checkbox
	$chk_verify = New-Object System.Windows.Forms.CheckBox;
	$chk_verify.Location = vec2 ($basex) ($basey);
	$chk_verify.Size = vec2 112 30;
	$chk_verify.Checked = $true;
	$chk_verify.CheckAlign = "MiddleRight";
	$chk_verify.Text = "Verify Passwords";
	$form.Controls.Add($chk_verify);

	$basey += 30;
	$basex = 130;
	
	# Show Passwords checkbox
	$chk_show_passwords = New-Object System.Windows.Forms.CheckBox;
	$chk_show_passwords.Location = vec2 ($basex) ($basey);
	$chk_show_passwords.Size = vec2 110 30;
	$chk_show_passwords.Checked = $false;
	$chk_show_passwords.CheckAlign = "MiddleRight";
	$chk_show_passwords.Text = "Show Passwords";
	$form.Controls.Add($chk_show_passwords);

	$basey += 40;
	$basex = 0;

	# Continue Button
	$btn_continue = New-Object System.Windows.Forms.Button;
	$btn_continue.Location = vec2 ($basex+90) ($basey+4);
	$btn_continue.Size = vec2 150 30;
	$btn_continue.Text = "Continue";
	$btn_continue.FlatStyle = "Flat";
	$btn_continue.FlatAppearance.BorderColor = "Gray";
	$btn_continue.FlatAppearance.BorderSize = 2;
	$btn_continue.Add_Click({
		
		# Check RITM is filled
		if("" -eq $txt_ritm.Text -or $txt_ritm.Text -notmatch "^RITM[0-9]{7}$"){
			[System.Windows.MessageBox]::Show("Please enter a valid RITM (e.g. `"RITM1234567`").", "Invalid Input");
			return;
		}

		# Check that application is filled
		if("" -eq $txt_app.Text){
			[System.Windows.MessageBox]::Show("Please enter an application name (e.g. `"myOrangeMoney_CF`").", "Invalid Input");
			return;
		}

		# Check that application is filled
		if("" -eq $txt_appunid.Text){
			[System.Windows.MessageBox]::Show("Please enter an application UNID (e.g. `"3732c965cc88f100bcb88af21d479d7f`").", "Invalid Input");
			return;
		}		

		# Check that application is filled
		if("" -eq $combo_applicationregion.Text){
			[System.Windows.MessageBox]::Show("Please select a valid application region (e.g. `"Acceptance`").", "Invalid Input");
			return;
		}

		# Check that application is filled
		if("" -eq $txt_numberaccountspassword.Text){
			$numberofaccountspassword=[int]0;
		} else {
			if($txt_numberaccountspassword.Text -match '^[a-zA-Z]'){
				[System.Windows.MessageBox]::Show("Please enter a valid digit for number of accounts (e.g. `"1`").", "Invalid Input");
				return;
			}
			$numberofaccountspassword=[int]$txt_numberaccountspassword.Text;
		}

#		# Check that application is filled
#		if("" -eq $txt_numberaccountskey.Text){
#			$numberofaccountskey=[int]0;
#		} else {
#			if($txt_numberaccountskey.Text -match '^[a-zA-Z]'){
#				[System.Windows.MessageBox]::Show("Please enter a valid digit for number of accounts (e.g. `"1`").", "Invalid Input");
#				return;
#			}
#			$numberofaccountskey=[int]$txt_numberaccountskey.Text;
#		}

		# Build meta information object
		$global:migration_meta = @{
			number_of_safes = [int]1;
			ritm = $txt_ritm.Text;
			application_name = $txt_app.Text.trim();
			application_unid = $txt_appunid.Text.trim();
			application_region = $combo_applicationregion.Text;
			application_type = $combo_application_type.Text;
#			pcf_foundation = $combo_foundation.Text;
#			pcf_org_guid = $org_map[$foundation][$combo_org.Text];
#			pcf_space_guid = $space_map[$foundation][$combo_org.Text][$combo_space.Text];
			number_of_accounts_password = $numberofaccountspassword;
#			number_of_accounts_key = $numberofaccountskey;
			include_port = $chk_include_port.Checked;
			include_virtualname = $chk_include_virtualname.Checked;
			verify_passwords = $chk_verify.Checked;
			show_passwords = $chk_show_passwords.Checked;

		};

		# If Standard Migration
		if($combo_application_type.Text -eq "Traditional"){
			# do nothing
		# If PCF Migration
		} elseif($combo_application_type.Text -eq "PCF"){
			$foundation = $combo_foundation.Text;
			$org_guid = $org_map[$foundation][$combo_org.Text];
			$space_guid = $space_map[$foundation][$combo_org.Text][$combo_space.Text];
			$global:migration_meta["pcf_foundation"] = $foundation;
			$global:migration_meta["pcf_org_guid"] = $org_guid;
			$global:migration_meta["pcf_space_guid"] = $space_guid;
			if("Production" -eq $combo_applicationregion.Text){
				$foundation_dr = "dr";
				$org_guid_dr = $org_map[$foundation_dr][$combo_org.Text];
				$space_guid_dr = $space_map[$foundation_dr][$combo_org.Text][$combo_space.Text];
				$global:migration_meta["pcf_foundation_dr"] = $foundation_dr;
				$global:migration_meta["pcf_org_guid_dr"] = $org_guid_dr;
				$global:migration_meta["pcf_space_guid_dr"] = $space_guid_dr;
			}
		}

		$form.close();

	});
	$form.Controls.Add($btn_continue);

	# Show form
	$form.add_shown({$form.Activate()});
	$form.ShowDialog() | Out-Null;

} 