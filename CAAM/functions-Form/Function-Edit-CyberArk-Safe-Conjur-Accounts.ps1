Function Edit-CyberArk-Safe-Conjur-Accounts()
<#

.SYNOPSIS
Show the processed NePIS credential data to the user and ask them to confirm
its validity and fill in any missing data.

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
Define the variable $global:platforms as an arraylist of strings of available platforms

.PARAMETERS
safes - an object with the following format:
[
	{
		"Identifier":  "2_N_Non_Personal_ID_Solution",
		"Description":  "6442c965cc88f100bcb88af21d479d81",
		"Region":  "acceptance",
		"Accounts":  [
			{
				"MainApplication":  "Non Personal ID Solution (PRD)"	# optional
				"sid_key":  143242,										# optional
				"Resource":  "sida@sida@ajaxlora1015_3",				# optional
				"Platform":  "2_DO_PWD_MNL_DAP",
				"Username":  "SIDADM",
				"Address":  "sida.oracle.db",
				"Port":  "50001",										# optional
				"Password":  "d072fp87a0g82jd",
				"Name":  "SIDADM-sida",
				"Associations":  [										# optional
					"Non Personal ID Solution (ACCP)",
					"Non Personal ID Solution (PRD)"
				],
				"PreviouslyMigratedTo":  "4_N_Non_Personal_ID_Solution",	# optional
				"MigrationVerification":  "Successful"						# optional
			},
			...
		],
	},
	...
]
Note that the arrays must be type [System.Collections.ArrayList] and the objects must be type 

.EXAMPLE
@(Edit-Safes-Accounts $safes) # Wrap with @() to ensure result is always an array

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 11/20/2020

#>

{
	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		$safes
	)

	# Import Dependencies
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null;
	Add-Type -AssemblyName PresentationCore, PresentationFramework;
#	."./functions-NePIS/Function-Get-NePIS-Platform-Map.ps1"
	."./functions-CyberArk/Function-Get-CyberArk-Platform-Map-Account-Conjur.ps1"

	# Make sure input is an arraylist
	$safes = New-Object System.Collections.ArrayList(,$safes);

	# Function for creating 2D vectors
	function vec2([int32]$x, [int32]$y){
		return New-Object System.Drawing.Size($x, $y);
	}

	# updateData function - validates inputs and updates the safes data
	function updateData(){
		
		# Check if any fields are empty
		$fields_missing = $false;
		foreach($textbox in $textboxes){
			if(-not $textbox.enabled){
				continue;
			}
			
			if($textbox.text -eq ""){
				$fields_missing = $true;
				$textbox.BackColor = "Pink";
			} else {
				$textbox.BackColor = "White";
			}
		}
		if($fields_missing){
			[System.Windows.MessageBox]::Show("Please fill missing fields.", "Add Safe & Accounts");
			return $false;
		}

		# Trim Safe name
		foreach($control in $form.Controls){
			if($control.name -eq "txt_0.Identifier"){
				$control.text = $control.text.subString(0, [System.Math]::Min(28, $control.text.Length));
			}
		}
		
		# Update safes data, kind of convoluted but works.
		# Parses string like "0.Identifier.2.Password" to set the property
		foreach($control in $form.Controls){
			if($control.name -match "txt_"){
				$keys = $control.name.split("_")[1].split(".");
				$entry = $safes;
				for($i = 0; $i -lt $keys.length; $i++){
					if($i -ne $keys.length - 1){ # not last key
						if($entry -is [System.Management.Automation.PSCustomObject]){ # entry is object
							$entry = $entry.($keys[$i]);
						} else { # entry is array
							$entry = $entry[[int]$keys[$i]];
						}
					} else { # last key
						$entry.($keys[$i]) = $control.text;
					}
				}
			}
		}
		
		# Remove disabled accounts
		$accounts = $safes[$safe_index].accounts;
		$new_accounts = [System.Collections.ArrayList]@(); # list of accounts without disabled ones
		for($i = 0; $i -lt $accounts.count; $i++){
			if($form.controls["chk_account_" + $i].checked){
				$new_accounts.add($accounts[$i]) | Out-Null;
			}
		}
		
		# Check that names are unique
		if($new_accounts.count -gt 1 -and $new_accounts.count -ne ($new_accounts | Select-Object {$_.Name} -Unique).length){
			$all_names = $new_accounts | ForEach-Object { $_.Name };
			$unique_names = $all_names | Select-Object -Unique;
			$duplicate_names = Compare-Object $all_names $unique_names | ForEach-Object { $_.InputObject };
			[System.Windows.MessageBox]::Show("Account names are not unique:`n" + ($duplicate_names -join "`n"), "Add Safe & Accounts");
			return $false;
		}

		# Warn of accounts with multiple associations
		$shared_accounts = [System.Collections.ArrayList]@();
		foreach($account in $new_accounts){
			if($account.Associations.length -gt 0){
				$shared_accounts.add($account) | Out-Null;
			}
		}
		if($shared_accounts.count -gt 0){
			$shared_names = $shared_accounts | ForEach-Object { $_.Name };
			$proceed = [System.Windows.MessageBox]::Show("Warning: Some accounts are associated to multiple applications.`nDo you wish to proceed?`n`n" + ($shared_names -join "`n"), "Warning: Multiple Associations", 4, 48);
			if($proceed -eq "No"){
				return $false;
			}
		}
		
		$safes[$safe_index].Accounts = $new_accounts;
		
		return $true;
	}

	# Iterate safes
	for($safe_index = 0; $safe_index -lt $safes.count; $safe_index++){
		
		$safe = $safes[$safe_index];
		
		$safe_center = 120;
		$basey = 10;
		$textboxes = [System.Collections.ArrayList]@();
		
		# Main Form
		$form = New-Object System.Windows.Forms.Form;
		$form.Text = "Confirm Safe & Accounts Creation";
		$form.Size = vec2 430 620;
		$form.StartPosition = "CenterScreen";
		$form.AutoScroll = $true;
		$form.AutoSizeMode = "GrowOnly";
		
		# Safe Fields
		foreach($field in $safe.PsObject.Properties){

			if($field.value.getType().name -ne "String"){
				continue;
			}
		
			# Label
			$lbl_field = New-Object System.Windows.Forms.Label;
			$lbl_field.Location = vec2 0 $basey;
			$lbl_field.Size = vec2 ($safe_center-4) 25;
			$lbl_field.TextAlign = "MiddleRight";
			If($field.name -eq "Identifier") {
				$lbl_field.Text = "Safe Name";
			} elseif ($field.name -eq "Description") {
				$lbl_field.Text = "Safe Description";
			} else {
				$lbl_field.Text = $field.name;
			}

			$form.Controls.Add($lbl_field);
			

			# Safe Textbox field

				$txt_field = New-Object System.Windows.Forms.TextBox;
				$txt_field.Location = vec2 $safe_center ($basey+4);
				$txt_field.Size = vec2 220 25;
				$txt_field.Text = $field.value;
				$txt_field.Name = "txt_" + $safe_index + "." + $field.name;
				$txt_field.ReadOnly = $true;
				$txt_field.BackColor = "Gainsboro";
				$textboxes.Add($txt_field) | Out-Null;
				$form.Controls.Add($txt_field);
				


			$basey += 30;
		}
		
		$basey += 40;
		$basex = 80;
	
		# Application UNID Field
		$lbl_account_section = New-Object System.Windows.Forms.Label;
		$lbl_account_section.Location = vec2 0 $basey;
		$lbl_account_section.Size = vec2 160 25;
		$lbl_account_section.TextAlign = "MiddleRight";
		$lbl_account_section.Text = "Account(s):";
		$form.Controls.Add($lbl_account_section);

		$basey += 30;
		
		
		# Iterate Accounts
		$account_index = 0;
		$account_center = 120;
		foreach($account in $safe.accounts){
			
			# Enable Checkbox
			$chk_enable = New-Object System.Windows.Forms.CheckBox;
			$chk_enable.Location = vec2 ($account_center-20) ($basey+4);
			$chk_enable.Checked = $true;
			$chk_enable.Name = "chk_account_" + $account_index;
			$chk_enable.Text = "Include";
			$form.Controls.Add($chk_enable);
			
			$basey += 30;
			
			# Account fields
			$account_textboxes = [System.Collections.ArrayList]@();
			foreach($field in $account.PsObject.Properties){
				
				# Label
				$lbl_field = New-Object System.Windows.Forms.Label;
				$lbl_field.Location = vec2 0 $basey;
				$lbl_field.Size = vec2 ($account_center-4) 25;
				$lbl_field.TextAlign = "MiddleRight";
				$lbl_field.Text = $field.name;
				$form.Controls.Add($lbl_field);
				
				# Uneditable fields (uneditable textbox)
				if(@("Resource", "sid_key", "PreviouslyMigratedTo", "MigrationVerification", "MainApplication","Index","DualAccountStatus").Contains($field.name)){
					$txt_field = New-Object System.Windows.Forms.TextBox;
					$txt_field.Location = vec2 $account_center ($basey+4);
					$txt_field.Size = vec2 200 25;
					$txt_field.Text = $field.value;
					$txt_field.ReadOnly = $true;
					$txt_field.BackColor = "Gainsboro";
					$form.Controls.Add($txt_field);
				
				# Associated Apps (label)
				} elseif($field.name -eq "Associations") {
					$list_field = New-Object System.Windows.Forms.Label;
					$list_field.Location = vec2 $account_center ($basey+6);
					$list_field.Size = vec2 200 ($field.value.length*12+4);
					$list_field.TextAlign = "TopLeft";
					$list_field.Text = $field.value -join "`n";
					$list_field.ForeColor = "DarkRed";
					$form.Controls.Add($list_field);
					$basey += ($field.value.length - 1) * 12;
				
				# Platform (combobox)
				} elseif($field.name -eq "Platform"){
					$combo_field = New-Object System.Windows.Forms.ComboBox;
					$combo_field.Location = vec2 $account_center ($basey+4);
					$combo_field.Size = vec2 200 25;
					$combo_field.Text = $field.value;
					if(!$global:migration_meta.include_virtualname){
						If("Production" -eq $global:migration_meta.application_region){
							foreach($platform in $global:platforms_production){
								$combo_field.Items.Add($platform) | Out-Null;
							}
						} else {
							foreach($platform in $global:platforms_nonproduction){
								$combo_field.Items.Add($platform) | Out-Null;
							}
						}
					} else {
						If("Production" -eq $global:migration_meta.application_region){
							foreach($platform in $global:platforms_production_virtualname){
								$combo_field.Items.Add($platform) | Out-Null;
							}
						} else {
							foreach($platform in $global:platforms_nonproduction_virtualname){
								$combo_field.Items.Add($platform) | Out-Null;
							}
						}
					}

					if($field.value -eq ""){
						$combo_field.BackColor = "Pink";
					}
					$combo_field.Name = "txt_" + $safe_index + ".accounts." + $account_index + "." + $field.name;
					$combo_field.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
					$textboxes.Add($combo_field) | Out-Null;
					$account_textboxes.Add($combo_field) | Out-Null;
					$form.Controls.Add($combo_field);
				
				# Password (bubbles textbox)
				} elseif($field.name -eq "Password"){
					$txt_field = New-Object System.Windows.Forms.TextBox;
					$txt_field.Location = vec2 $account_center ($basey+4);
					$txt_field.Size = vec2 200 25;
					$txt_field.Text = $field.value;
					$txt_field.Name = "txt_" + $safe_index + ".accounts." + $account_index + "." + $field.name;
					if($null -ne $global:migration_meta -and -not $global:migration_meta["show_passwords"]){
						$txt_field.PasswordChar = '*';
					}
					if($field.value -eq ""){
						$txt_field.BackColor = "Pink";
					}
					$textboxes.Add($txt_field) | Out-Null;
					$account_textboxes.Add($txt_field) | Out-Null;
					$form.Controls.Add($txt_field);
				
				# Editable field (textbox)
				} else {
					$txt_field = New-Object System.Windows.Forms.TextBox;
					$txt_field.Location = vec2 $account_center ($basey+4);
					$txt_field.Size = vec2 200 25;
					$txt_field.Text = $field.value;
					if($field.value -eq ""){
						$txt_field.BackColor = "Pink";
					}
					$txt_field.Name = "txt_" + $safe_index + ".accounts." + $account_index + "." + $field.name;
					$textboxes.Add($txt_field) | Out-Null;
					$account_textboxes.Add($txt_field) | Out-Null;
					$form.Controls.Add($txt_field);
				}
				
				$basey += 30;
			}
			
			# Add Include checkbox functionality
			$chk_enable.Add_CheckedChanged({
				foreach($textbox in $account_textboxes){
					if($chk_enable.checked){
						$textbox.enabled = $true;
					} else {
						$textbox.enabled = $false;
					}
				}
			}.GetNewClosure());
			
			$basey += 30;
			$account_index += 1;
		}
		$basex = 20;
		
		$global:skipping_safe = $true;
		
		# Add Safe Button
		$btn_add = New-Object System.Windows.Forms.Button;
		$btn_add.Location = vec2 $basex ($basey+4);
		$btn_add.Size = vec2 150 30;
		$btn_add.Text = "Add To CyberArk";
		$btn_add.FlatStyle = "Flat";
		$btn_add.FlatAppearance.BorderColor = "Gray";
		$btn_add.FlatAppearance.BorderSize = 2;
		$btn_add.Add_Click({
			$update_output = updateData;
			if($update_output -like "true"){
				# Write-Host "Adding $($safe.identifier) and accounts to CyberArk.";
				$global:skipping_safe = $false;
				$form.close();
			}
		});
		$form.Controls.Add($btn_add);
		
		# Skip Safe Button
		$btn_skip = New-Object System.Windows.Forms.Button;
#		$btn_skip.Location = vec2 (150+8) ($basey+4);
		$btn_skip.Location = vec2 ($basex+170) ($basey+4);
		$btn_skip.Size = vec2 150 30;
		$btn_skip.Text = "Skip This Safe";
		$btn_skip.FlatStyle = "Flat";
		$btn_skip.FlatAppearance.BorderColor = "Gray";
		$btn_skip.FlatAppearance.BorderSize = 2;
		$btn_skip.Add_Click({
			$global:skipping_safe = $true;
			$form.close();
		});
		$form.Controls.Add($btn_skip);
		
		$basey += 15;
		
		# Add empty label for spacing from bottom
		$lbl_dummy = New-Object System.Windows.Forms.Label;
		$lbl_dummy.Location = vec2 0 $basey;
		$form.Controls.Add($lbl_dummy);
		
		# Show form
		$form.add_shown({$form.Activate()});
		$form.ShowDialog() | Out-Null;
		
		# When form closed, if skipping, remove safe from data
		if($global:skipping_safe){
			$safe_index -= 1;
			$safes.remove($safe);
		}
		
	}

	return $safes;

} 