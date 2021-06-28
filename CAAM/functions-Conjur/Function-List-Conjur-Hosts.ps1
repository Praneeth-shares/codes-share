Function List-Conjur-Hosts(){
	."./functions-Conjur/Function-List-Conjur-Hosts-Info.ps1"
	."./functions-Conjur/Function-Get-Auth-Headers-DAP.ps1"
	if (( $null -ne $global:AuthenticationHeader ) ){
		$authHeader =$global:AuthenticationHeader
		Invoke-RestMethod -Uri 'https://localhost:8443/whoami' -Method Get -Headers $authHeader

	}
	elseif(( $null -eq $global:AuthenticationHeader ) -or ($null -eq $global:UserName ) -or ($null -eq $global:APIToken)){
		Get-Auth-Headers-DAP;
	}
	$username = $global:UserName
	$authHeader = $global:AuthenticationHeader
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
$searchresults=Invoke-RestMethod -Uri $searchurl -Method get -Headers $authHeader
$return= ''
foreach ($searchresult in $searchresults ){

$return  = $return  + $searchresult.id+ "`n"

}
write-host $return
}