function Print-NePIS-Credentials {
	
	."./functions-NePIS/Function-Create-NePIS-Session.ps1"
	."./functions-NePIS/Function-Get-NePIS-Export.ps1"

	# Get NePIS Session (via WebSeal)
	if(-not (Create-NePIS-Session)){
		return;
	}

	# Get credential data from NePIS
	$result = Get-NePIS-Export (Read-Host "Enter Application");
	if($null -eq $result){
		return;
	}
		
	# Print result
	$result | ConvertTo-Json -Depth 10;
	
}