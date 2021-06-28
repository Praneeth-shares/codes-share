function Get-Auth-Headers-DAP{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    Add-Type -AssemblyName PresentationCore, PresentationFramework
    
    function vec2([int32]$x, [int32]$y){
            return New-Object System.Drawing.Size($x, $y);
        }
    
    $form = New-Object System.Windows.Forms.Form;
    $form.Text = "DAP LogIn Info";
    $form.Size = vec2 350 400;
    $form.StartPosition = "CenterScreen";
    $form.AutoScroll = $true;
    $form.AutoSizeMode = "GrowOnly";
    
    $basex = 100;
    $basey = 10;
    
    # UserName Field
    $lbl_uname = New-Object System.Windows.Forms.Label;
    $lbl_uname.Location = vec2 0 $basey;
    $lbl_uname.Size = vec2 ($basex-4) 25;
    $lbl_uname.TextAlign = "MiddleRight";
    $lbl_uname.Text = "UserName";
    $form.Controls.Add($lbl_uname);
    $txt_uname = New-Object System.Windows.Forms.TextBox;
    $txt_uname.Location = vec2 $basex ($basey+4);
    $txt_uname.Size = vec2 200 25;
    $txt_uname.Text = "";
    $txt_uname.Name = "txt_uname";
    $form.Controls.Add($txt_uname);
    
    $basey += 30;
    
    $lbl_tkn = New-Object System.Windows.Forms.Label;
    $lbl_tkn.Location = vec2 0 $basey;
    $lbl_tkn.Size = vec2 ($basex-4) 25;
    $lbl_tkn.TextAlign = "MiddleRight";
    $lbl_tkn.Text = "Token";
    $form.Controls.Add($lbl_tkn);
    $txt_tkn = New-Object System.Windows.Forms.TextBox;
    $txt_tkn.Location = vec2 $basex ($basey+4);
    $txt_tkn.Size = vec2 200 25;
    $txt_tkn.Text = "";
    $txt_tkn.Name = "txt_tkn";
    $form.Controls.Add($txt_tkn);
    
    $basey += 30;
    
    $btn_continue = New-Object System.Windows.Forms.Button;
    $btn_continue.Location = vec2 ($basex+90) ($basey+4);
    $btn_continue.Size = vec2 150 30;
    $btn_continue.Text = "Continue";
    $btn_continue.FlatStyle = "Flat";
    $btn_continue.FlatAppearance.BorderColor = "Gray";
    $btn_continue.FlatAppearance.BorderSize = 2;
    $btn_continue.Add_Click({
        if("" -eq $txt_uname.Text -or "" -eq $txt_tkn.Text){
            [System.Windows.MessageBox]::Show("Please enter a valid Username and token");
            return;
        }
        elseif ("" -ne $txt_uname.Text -or "" -ne $txt_tkn.Text){
        $authHeader= $null
        $response=$null
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Accept-Encoding", "base64")
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")
        $body = $txt_tkn.Text  ='2gkv5tcasm67xp3qegd2tr794236heem83396nbw2jrjx1b1gq5jhm'
        $username = $txt_uname.Text = 'admin'
        $authurl = 'Https://localhost:8443/authn/myConjurAccount/'+ $username +'/authenticate'
        try
        {
        $response = Invoke-RestMethod $authurl -Method 'POST' -Body $body -Headers $headers
        $authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $authHeader.Add("Authorization", "Token token=`"$response`"")
        $authHeader.Add("Content-Type", "application/x-www-form-urlencoded")
        $global:AuthenticationHeader=$authHeader
        $global:UserName= $txt_uname.Text
        $global:APIToken= $txt_tkn.Text
        
        }
        catch{ if ($_.Exception.Response.StatusCode.Value__ -eq '404') {Write-Host "Enter valid Username"} 
        elseif ($_.Exception.Response.StatusCode.Value__ -eq '401') {Write-Host "Enter valid API Token"}
        }
        
    }
    $form.Close()
    })
    
    
    $form.Controls.Add($btn_continue);
    $form.add_shown({$form.Activate()});
    $form.ShowDialog() | Out-Null;
    }