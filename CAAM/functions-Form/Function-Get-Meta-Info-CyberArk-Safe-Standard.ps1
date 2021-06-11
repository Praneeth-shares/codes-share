Function Get-Meta-Info-Cyberark-Safe-Standard()
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
	$form.Text = "CyberArk Standard Safe Info";
	$form.Size = vec2 340 550;
	$form.StartPosition = "CenterScreen";
	$form.AutoScroll = $true;
	$form.AutoSizeMode = "GrowOnly";

	$basex = 100;
	$basey = 10;

	# Define variables for later in the form
	$combo_region = New-Object System.Windows.Forms.ComboBox;
	$chk_verify = New-Object System.Windows.Forms.CheckBox;
	$chk_change = New-Object System.Windows.Forms.CheckBox;
	$txt_appunid = New-Object System.Windows.Forms.TextBox;
	$combo_saferegion = New-Object System.Windows.Forms.ComboBox;
	$combo_safeplatform = New-Object System.Windows.Forms.ComboBox;
	$lbl_app = New-Object System.Windows.Forms.Label;
	$chk_include_secondary = New-Object System.Windows.Forms.CheckBox;
	$txt_numberaccountskey = New-Object System.Windows.Forms.TextBox;

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

	# App Type Selector
	$lbl_app_type = New-Object System.Windows.Forms.Label;
	$lbl_app_type.Location = vec2 0 $basey;
	$lbl_app_type.Size = vec2 ($basex-4) 25;
	$lbl_app_type.TextAlign = "MiddleRight";
	$lbl_app_type.Text = "Request Type";
	$form.Controls.Add($lbl_app_type);
	$combo_app_type = New-Object System.Windows.Forms.ComboBox;
	$combo_app_type.Location = vec2 $basex ($basey+3);
	$combo_app_type.Size = vec2 100 30;
	$combo_app_type.Text = "Personal";
	$combo_app_type.Name = "app_type";
	$combo_app_type.Items.Add("Personal") | Out-Null;
	$combo_app_type.Items.Add("Non-Personal") | Out-Null;
	$form.Controls.Add($combo_app_type);
	$combo_app_type.Add_SelectedIndexChanged({
		if($combo_app_type.Text -eq "Non-Personal"){
			$combo_saferegion.Enabled = $true;
			$combo_safeplatform.Enabled = $true;
			$txt_appunid.Enabled = $true;	
			$chk_include_secondary.Enabled = $false;
			#			$lbl_app.Enabled = $true;
			$lbl_app.Text = "Application Name";	
			$txt_numberaccountskey.Enabled = $false;
		} else {
			$combo_saferegion.Enabled = $false;
			$combo_safeplatform.Enabled = $false;
			$txt_appunid.Enabled = $false;	
			$chk_include_secondary.Enabled = $true;
			$lbl_app.Text = "Employee ID";	
			$txt_numberaccountskey.Enabled = $false;
		}
	}.GetNewClosure());
	$combo_app_type.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling

	$basey += 30;

	# Application Name Field
	$lbl_app.Location = vec2 0 $basey;
	$lbl_app.Size = vec2 ($basex-4) 25;
	$lbl_app.TextAlign = "MiddleRight";
	$lbl_app.Text = "Employee ID";
	$form.Controls.Add($lbl_app);
	$txt_app = New-Object System.Windows.Forms.TextBox;
	$txt_app.Location = vec2 $basex ($basey+4);
	$txt_app.Size = vec2 200 25;
	$txt_app.Text = "";
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
	$txt_appunid.Location = vec2 $basex ($basey+4);
	$txt_appunid.Size = vec2 200 25;
	$txt_appunid.Text = "";
	$txt_appunid.Name = "txt_appunid";
	$txt_appunid.Enabled = $false;
	$form.Controls.Add($txt_appunid);

	$basey += 30;

	# Safe Technology Platforms (Combobox)
	$lbl_safe_platform = New-Object System.Windows.Forms.Label;
	$lbl_safe_platform.Location = vec2 0 $basey;
	$lbl_safe_platform.Size = vec2 ($basex-4) 25;
	$lbl_safe_platform.TextAlign = "MiddleRight";
	$lbl_safe_platform.Text = "Application Platform";
	$form.Controls.Add($lbl_safe_platform);
	$combo_safeplatform.Location = vec2 $basex ($basey+4);
	$combo_safeplatform.Size = vec2 170 30;
	$combo_safeplatform.Text = $safeplatform.value;
	$combo_safeplatform.Items.Add("Database") | Out-Null;
	$combo_safeplatform.Items.Add("Unix") | Out-Null;
	$combo_safeplatform.Items.Add("Windows") | Out-Null;
	$combo_safeplatform.Items.Add("Mainframe") | Out-Null;
	$combo_safeplatform.Items.Add("Application") | Out-Null;
	if($safeplatform.value -eq ""){
		$combo_safeplatform.BackColor = "Pink";
	}
	$combo_safeplatform.Enabled = $false;
	$combo_safeplatform.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
	$form.Controls.Add($combo_safeplatform);
	
	$basey += 30;

	# Safe Region (Combobox)
	$lbl_safe_region = New-Object System.Windows.Forms.Label;
	$lbl_safe_region.Location = vec2 0 $basey;
	$lbl_safe_region.Size = vec2 ($basex-4) 25;
	$lbl_safe_region.TextAlign = "MiddleRight";
	$lbl_safe_region.Text = "Application Region";
	$form.Controls.Add($lbl_safe_region);
	$combo_saferegion.Location = vec2 $basex ($basey+4);
	$combo_saferegion.Size = vec2 170 30;
	$combo_saferegion.Text = $saferegion.value;
	$combo_saferegion.Items.Add("production") | Out-Null;
	$combo_saferegion.Items.Add("non-production") | Out-Null;
	if($saferegion.value -eq ""){
		$combo_saferegion.BackColor = "Pink";
	}
	$combo_saferegion.Enabled = $false;
	$combo_saferegion.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
	$form.Controls.Add($combo_saferegion);
	
	$basey += 40;
	$basex = 80;

	# Application UNID Field
	$lbl_account_section = New-Object System.Windows.Forms.Label;
	$lbl_account_section.Location = vec2 0 $basey;
	$lbl_account_section.Size = vec2 160 25;
	$lbl_account_section.TextAlign = "MiddleRight";
	$lbl_account_section.Text = "Account(s) Requirements:";
	$form.Controls.Add($lbl_account_section);

	$basey += 20;
	$basex = 87;
	# Include Secondary AD Account for Personal Safe

	$chk_include_secondary.Location = vec2 $basex ($basey+3);
	$chk_include_secondary.Size = vec2 153 30;
	$chk_include_secondary.Checked = $false;
	$chk_include_secondary.CheckAlign = "MiddleRight";
	$chk_include_secondary.Text = "Add AD Personal account";
	$form.Controls.Add( $chk_include_secondary);

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

	# Verify Passwpord checkbox
#	$chk_verify = New-Object System.Windows.Forms.CheckBox;
	$chk_verify.Location = vec2 ($basex) ($basey);
	$chk_verify.Size = vec2 112 30;
	$chk_verify.Checked = $false;
	$chk_verify.CheckAlign = "MiddleRight";
	$chk_verify.Text = "Verify Passwords";
	$form.Controls.Add($chk_verify);
	$chk_verify.Add_CheckStateChanged({
		if($chk_verify.Checked){
			$chk_change.Enabled = $false;
			$chk_change.Checked = $false;
		} else {
			$chk_change.Enabled = $true;
		}
	}.GetNewClosure());


	$basey += 30;
	$basex = 120;

	
	# Change Passwpord checkbox
#	$chk_change = New-Object System.Windows.Forms.CheckBox;
	$chk_change.Location = vec2 ($basex) ($basey);
	$chk_change.Size = vec2 121 30;
	$chk_change.Checked = $false;
	$chk_change.CheckAlign = "MiddleRight";
	$chk_change.Text = "Change Passwords";
	$form.Controls.Add($chk_change);
#	$chk_change.Add_CheckStateChanged({
#		if($chk_verify.Checked){
#			$chk_verify.Enabled = $false;
#		} else {
#			$chk_verify.Enabled = $true;
#		}
#	}.GetNewClosure());

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
			[System.Windows.MessageBox]::Show("Please enter a valid RITM (e.g. `"RITM123456`").", "Invalid Input");
			return;
		}

		# Check that application is filled
		if("Personal" -eq $combo_app_type.Text){
			if("" -eq $txt_app.Text -or $txt_app.Text -notmatch "^[0-9]{6}$"){
				[System.Windows.MessageBox]::Show("Please enter an employee ID (e.g. `"712345`").", "Invalid Input");
				return;
			}
		} else {
			if("" -eq $txt_app.Text){
				[System.Windows.MessageBox]::Show("Please enter an application name (e.g. `"myOrangeMoney_CF`").", "Invalid Input");
				return;
			}
		}

		# Check that application UNID - Safe Description is filled
		if("Personal" -eq $combo_app_type.Text){
			$txt_appunid.Text = $txt_app.Text
		} Else {
			if("" -eq $txt_appunid.Text){
				[System.Windows.MessageBox]::Show("Please enter an application UNID (e.g. `"3732c965cc88f100bcb88af21d479d7f`").", "Invalid Input");
				return;
			}		
		}

		
		# Check that a Safe platform  type was selected
		if("Personal" -eq $combo_app_type.Text){
			$combo_safeplatform.Text = "not applicable"
		} Else {
			if("" -eq $combo_safeplatform.Text){
				[System.Windows.MessageBox]::Show("Please select a application platform type (e.g. `"windows`").", "Invalid Input");
				return;
			}	
		}

		# Check that a Safe region type was selected
		if("Personal" -eq $combo_app_type.Text){
			$combo_saferegion.Text = "personal"
		} Else {
			if("" -eq $combo_saferegion.Text){
				[System.Windows.MessageBox]::Show("Please select a safe region (e.g. `"non-production`").", "Invalid Input");
				return;
			}
		}
		
		# Check if secondary id should be false
		if("Personal" -ne $combo_app_type.Text){
			$chk_include_secondary.Checked = $false
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
			application_type = $combo_app_type.Text;
			application_name = $txt_app.Text.trim();
			application_unid = $txt_appunid.Text.trim();
			application_platform = $combo_safeplatform.Text;
			application_region = $combo_saferegion.Text;
			include_secondary = $chk_include_secondary.Checked
			number_of_accounts_password = $numberofaccountspassword;
#			number_of_accounts_key = $numberofaccountskey;
			include_port = $chk_include_port.Checked;
			verify_passwords = $chk_verify.Checked;
			change_passwords = $chk_change.Checked;
			show_passwords = $chk_show_passwords.Checked;
		};

		$form.close();

	});
	$form.Controls.Add($btn_continue);

	# Show form
	$form.add_shown({$form.Activate()});
	$form.ShowDialog() | Out-Null;

} 