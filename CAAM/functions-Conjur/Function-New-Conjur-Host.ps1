Function New-Conjur-Host(){



    [cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$policy,

		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$host_name
	)
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept-Encoding", "base64")
$headers.Add("Content-Type", "application/x-www-form-urlencoded")

$body = "1bc9fad32yfxqkvemfzh2hgdkk0w0g5493ctsgym6z10rg2z2a8en"

$response = Invoke-RestMethod '{{Global Variable for accp}}' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json

$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$authHeader.Add("Authorization", "Token token=`"$response`"")
$authHeader.Add("Content-Type", "application/x-www-form-urlencoded")
$policyurl = '{{Global Variable for accp}}'
$hosts_yaml = "# voya/$($host_name).yaml`r`n- !policy`r`n  id: $($host_name)`r`n  body:`r`n  - !group`r`n  - &$($host_name)-hosts`r`n    - !host`r`n      id: prod`r`n    - !host`r`n      id: dr`r`n    - !host`r`n      id: accp`r`n    - !host`r`n      id: intg`r`n    - !host`r`n      id: unit`r`n  - !grant`r`n    role: !group`r`n    member: *$($host_name)-hosts";
Invoke-RestMethod -Uri $policyurl+'/'+$host_name -Method Post -Headers $authHeader -body $hosts_yaml
}