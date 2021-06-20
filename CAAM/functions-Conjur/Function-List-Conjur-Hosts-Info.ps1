function Get-Meta-List-Conjur-Hosts {

    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    
    function vec2([int32]$x, [int32]$y){
            return New-Object System.Drawing.Size($x, $y);
        }
    
    $form = New-Object System.Windows.Forms.Form;
    $form.Text = "List Hosts Info";
    $form.Size = vec2 350 400;
    $form.StartPosition = "CenterScreen";
    $form.AutoScroll = $true;
    $form.AutoSizeMode = "GrowOnly";
    
    $basex = 100;
    $basey = 10;
    
    # RITM Field
    $lbl_ritm = New-Object System.Windows.Forms.Label;
    $lbl_ritm.Location = vec2 0 $basey;
    $lbl_ritm.Size = vec2 ($basex-4) 25;
    $lbl_ritm.TextAlign = "MiddleRight";
    $lbl_ritm.Text = "RITM";
    $form.Controls.Add($lbl_ritm);
    $txt_ritm = New-Object System.Windows.Forms.TextBox;
    $txt_ritm.Location = vec2 $basex ($basey+4);
    $txt_ritm.Size = vec2 200 25;
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
    $combo_app_type.Name = "app_type";
    $combo_app_type.Items.Add("APP-DC") | Out-Null;
    $combo_app_type.Items.Add("AZURE") | Out-Null;
    $form.Controls.Add($combo_app_type);
    $combo_app_type.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
    
    $basey += 35;
    $lbl_policy = New-Object System.Windows.Forms.Label;
    $lbl_policy.Location = vec2 0 $basey;
    $lbl_policy.Size = vec2 ($basex-4) 25;
    $lbl_policy.TextAlign = "MiddleRight";
    $lbl_policy.Text = "Application Name";
    $form.Controls.Add($lbl_policy);
    $txt_policy = New-Object System.Windows.Forms.TextBox;
    $txt_policy.Location = vec2 $basex ($basey+4);
    $txt_policy.Size = vec2 200 25;
    $txt_policy.Text = "";
    $txt_policy.Name = "txt_policy";
    $form.Controls.Add($txt_policy);
    $basey += 35;


    $lbl_app = New-Object System.Windows.Forms.Label;
    $lbl_app.Location = vec2 0 $basey;
    $lbl_app.Size = vec2 ($basex-4) 25;
    $lbl_app.TextAlign = "MiddleRight";
    $lbl_app.Text = "Host Search Text";
    $form.Controls.Add($lbl_app);
    $txt_app = New-Object System.Windows.Forms.TextBox;
    $txt_app.Location = vec2 $basex ($basey+4);
    $txt_app.Size = vec2 200 25;
    $txt_app.Text = "";
    $txt_app.Name = "txt_app";
    $form.Controls.Add($txt_app);
    
    $basey += 35;
    
    $srch_app = New-Object System.Windows.Forms.Label;
    $srch_app.Location = vec2 0 $basey;
    $srch_app.Size = vec2 ($basex-4) 25;
    $srch_app.TextAlign = "MiddleRight";
    $srch_app.Text = "Search Results#";
    $form.Controls.Add($srch_app);
    $txt_srch = New-Object System.Windows.Forms.TextBox;
    $txt_srch.Location = vec2 $basex ($basey+4);
    $txt_srch.Size = vec2 200 25;
    $txt_srch.Text = "";
    $txt_srch.Name = "txt_srch";
    $form.Controls.Add($txt_srch);

    $basey += 35;

    # Safe Region (Combobox)
    $combo_saferegion = New-Object System.Windows.Forms.ComboBox;
    $lbl_safe_region = New-Object System.Windows.Forms.Label;
    $lbl_safe_region.Location = vec2 0 $basey;
    $lbl_safe_region.Size = vec2 ($basex-4) 25;
    $lbl_safe_region.TextAlign = "MiddleRight";
    $lbl_safe_region.Text = "Application Region";
    $form.Controls.Add($lbl_safe_region);
    $combo_saferegion.Location = vec2 $basex ($basey+4);
    $combo_saferegion.Size = vec2 170 30;
    $combo_saferegion.Text = $saferegion.value;
    $combo_saferegion.Items.Add("PROD") | Out-Null;
    $combo_saferegion.Items.Add("DR") | Out-Null;
    $combo_saferegion.Items.Add("ACCP") | Out-Null;
    $combo_saferegion.Items.Add("UNIT") | Out-Null;
    if($saferegion.value -eq ""){
        $combo_saferegion.BackColor = "Pink";
    }
    $combo_saferegion.Add_MouseWheel({$_.Handled = $true;}); # Prevent scrolling
    $form.Controls.Add($combo_saferegion);
        
    $basey += 40;
    $basex = 80;
    
        $btn_continue = New-Object System.Windows.Forms.Button;
        $btn_continue.Location = vec2 ($basex+90) ($basey+4);
        $btn_continue.Size = vec2 150 30;
        $btn_continue.Text = "Continue";
        $btn_continue.FlatStyle = "Flat";
        $btn_continue.FlatAppearance.BorderColor = "Gray";
        $btn_continue.FlatAppearance.BorderSize = 2;
        $btn_continue.Add_Click({
            if("" -eq $txt_ritm.Text -or $txt_ritm.Text -notmatch "^RITM[0-9]{7}$"){
                [System.Windows.MessageBox]::Show("Please enter a valid RITM (e.g. `"RITM123456`").", "Invalid Input");
                return;
            }
            $global:List_host_meta = @{ Policy= $txt_policy.Text; 
                                        app_type= $combo_app_type.SelectedItem;
                                        saferegion= $combo_saferegion.SelectedItem;
                                        Searchtext=$txt_app.Text;
                                        ResultCount= $txt_srch.Text
                                    }
        
            $form.Close()
    })
    
    #if ($txt_ritm.Text -and $txt_app.Text -and $combo_app_type.SelectedText -and $combo_saferegion.SelectedText){
    $form.Controls.Add($btn_continue);
    #}
    $form.add_shown({$form.Activate()});
    $form.ShowDialog() | Out-Null;
    
    
    }