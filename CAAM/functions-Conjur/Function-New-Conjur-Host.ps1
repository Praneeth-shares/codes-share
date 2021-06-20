Function New-Conjur-Host(){
	."./functions-Conjur/Function-Create-Conjur-Host-Info.ps1"

	Create-Conjur-Host-Info 
	if($null -eq $global:new_host_meta){
			return;
		}
	$policy= $global:new_host_meta.Policy
	$apptype = $global:new_host_meta.app_type
	$saferegion = $global:new_host_meta.saferegion
	if ($apptype -eq 'APP-DC' -and $saferegion -eq 'ACCP'){$policyurl = 'https://localhost:8443/policies/myConjurAccount/policy/'+$policy}
	
	
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Accept-Encoding", "base64")
	$headers.Add("Content-Type", "application/x-www-form-urlencoded")
	
	$body = "1bc9fad32yfxqkvemfzh2hgdkk0w0g5493ctsgym6z10rg2z2a8en"
	
	$response = Invoke-RestMethod 'Https://localhost:8443/authn/myConjurAccount/admin/authenticate' -Method 'POST' -Headers $headers -Body $body
	$response | ConvertTo-Json
	$policyurl
	$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$authHeader.Add("Authorization", "Token token=`"$response`"")
	$authHeader.Add("Content-Type", "application/x-www-form-urlencoded")
	$hosts_yaml = "# voya/$($host_name).yaml`r`n- !policy`r`n  id: $($policy)`r`n  body:`r`n  - !group`r`n  - &$($policy)-hosts`r`n    - !host`r`n      id: prod`r`n    - !host`r`n      id: dr`r`n    - !host`r`n      id: accp`r`n    - !host`r`n      id: intg`r`n    - !host`r`n      id: unit`r`n  - !grant`r`n    role: !group`r`n    member: *$($policy)-hosts";
	Invoke-RestMethod -Uri $policyurl -Method Post -Headers $authHeader -body $hosts_yaml
}