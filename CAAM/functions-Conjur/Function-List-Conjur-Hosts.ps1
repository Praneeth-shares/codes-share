Function List-Conjur-Hosts(){
	."./functions-Conjur/Function-List-Conjur-Hosts-Info.ps1"

	Get-Meta-List-Conjur-Hosts
	if($null -eq $global:List_host_meta){
			return;
		}

	$policy= $global:List_host_meta.Policy
	$apptype = $global:List_host_meta.app_type
	$saferegion = $global:List_host_meta.saferegion
	$search_string=$global:List_host_meta.Searchtext
	$return_count=$global:List_host_meta.ResultCount
	
if ($search_string -eq '' -and $return_count -ne 0){$searchquery = '?kind=host&limit='+[string]$return_count}
elseif($search_string -eq '' -and $return_count -eq 0){$searchquery = '?kind=host&limit=10'}
elseif($search_string -ne '' -and $return_count -eq 0){$searchquery = '?kind=host&limit=10'+'&search='+$search_string}
elseif($search_string -ne '' -and $return_count -ne 0){$searchquery = '?kind=host&limit='+$return_count+'&search='+$search_string}
if ($apptype -eq 'APP-DC' -and $saferegion -eq 'ACCP'){$searchurl = 'Https://localhost:8443/resources/myConjurAccount/'+$searchquery}
Write-Host $searchurl
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept-Encoding", "base64")
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
$body = "1bc9fad32yfxqkvemfzh2hgdkk0w0g5493ctsgym6z10rg2z2a8en"
$response = Invoke-RestMethod 'Https://localhost:8443/authn/myConjurAccount/admin/authenticate' -Method 'POST' -Body $body -Headers $headers
$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$authHeader.Add("Authorization", "Token token=`"$response`"")
$authHeader.Add("Content-Type", "application/x-www-form-urlencoded")
$searchresults=Invoke-RestMethod -Uri $searchurl -Method get -Headers $authHeader
$return= ''
foreach ($searchresult in $searchresults ){

$return  = $return  + $searchresult.id+ "`n"

}
write-host $return
}