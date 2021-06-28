Function New-Conjur-Host(){
	."./functions-Conjur/Function-Create-Conjur-Host-Info.ps1"
	."./functions-Conjur/Function-Get-Auth-Headers-DAP.ps1"
	if (( $null -ne $global:AuthenticationHeader ) ){
		$authHeader =$global:AuthenticationHeader
		try{
		Invoke-RestMethod -Uri 'https://localhost:8443/whoami' -Method Get -Headers $authHeader
		}
		catch{write-host $_.Exception.Response.StatusCode.Value__

		}

	}
	elseif(( $null -eq $global:AuthenticationHeader ) -or ($null -eq $global:UserName ) -or ($null -eq $global:APIToken)){
		Get-Auth-Headers-DAP;
	}
	$username = $global:UserName
	$authHeader = $global:AuthenticationHeader
	Create-Conjur-Host-Info 
	if($null -eq $global:new_host_meta){
			return;
		}
	$policy= $global:new_host_meta.Policy
	$apptype = $global:new_host_meta.app_type
	$saferegion = $global:new_host_meta.saferegion
	if ($apptype -eq 'APP-DC' -and $saferegion -eq 'ACCP'){$policyurl = 'https://localhost:8443/policies/myConjurAccount/policy/'+$policy}
	
	
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
	$hosts_yaml = "# voya/$($policy).yaml`r`n- !policy`r`n  id: $($policy)`r`n  body:`r`n  - !group`r`n  - &$($policy)-hosts`r`n    - !host`r`n      id: prod`r`n    - !host`r`n      id: dr`r`n    - !host`r`n      id: accp`r`n    - !host`r`n      id: intg`r`n    - !host`r`n      id: unit`r`n  - !grant`r`n    role: !group`r`n    member: *$($policy)-hosts";
	$status = Invoke-RestMethod -Uri $policyurl -Method Post -Headers $authHeader -body $hosts_yaml
	Write-Host $status.text
}
