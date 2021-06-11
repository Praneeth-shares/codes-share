Function Create-YAML()
<#

.SYNOPSIS
Generate YAML files for a safe.

.DISTRIBUTION & LEGAL USE 
This code and any other code explicitly part of the CyberArk operations automation in VOYA Financial should not be copied outside of VOYA and to computers/servers not authorized by the PamEng Manager 

.MODULES & SUBFUNCTIONS REQUIRED
None

.PARAMETERS
safe - the the safe object to grant access to (from Vault-NePIS-Data function)
app_name - the name of the app or instance who needs access

.EXAMPLE
Create-YAML $safe "Non Personal ID Solution (UNIT)"

.SUPPORT, MAINTENANCE & UPDATES
This function is maintained & supported by PamEng @ PAMEngineering@voya.com
Last maintenance done by: Daniel Maryanski @ 02/11/2021

#>

{
	[cmdletbinding()]
	Param(
		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		$safe,

		[parameter(
			Mandatory = $true,
			ValueFromPipeline = $false
		)]
		[string]$app_name
	)

	Write-Host "Generating YAML files...";

	# Get host name
	$host_name = $app_name -replace "\s\([A-Za-z]{2,8}\)$";  # Remove "(ACCP)", "(PRD)", etc.
	$host_name = $host_name -replace "\s", "_";  # Replace spaces with underscores

	# Create Hosts YAML File
	if($global:migration_meta.migration_type -eq "Standard"){
		$hosts_yaml = "# voya/$($host_name).yaml`r`n- !policy`r`n  id: $($host_name)`r`n  body:`r`n  - !group`r`n  - &$($host_name)-hosts`r`n    - !host`r`n      id: prod`r`n    - !host`r`n      id: dr`r`n    - !host`r`n      id: accp`r`n    - !host`r`n      id: intg`r`n    - !host`r`n      id: unit`r`n  - !grant`r`n    role: !group`r`n    member: *$($host_name)-hosts";
		$yaml_file_path = "$($global:dap_policy_output_path)/voya/$($host_name).yaml";
		if(!(Test-Path $yaml_file_path)){
			New-Item -Path $yaml_file_path -Force | Out-Null;
		}
		$hosts_yaml | Set-Content -Path $yaml_file_path | Out-Null;

		log "Wrote voya/$($host_name).yaml";
		Write-Host "Wrote voya/$($host_name).yaml";
		# Write-Host $hosts_yaml;
		Write-Host;
	}

	# Get Consumers YAML Path
	$lob_region = "voya-pp";
	if($safe.Region -like "prod*"){
		$lob_region = "voya";
	}
	$yaml_path = "$($global:cyberark_region)/$($lob_region)/$($safe.Identifier)/delegation";
	$consumers_yaml = "";

	# Create Consumers YAML file (Standard)			
	if($global:migration_meta.migration_type -eq "Standard"){
		$region_string = "";
		switch -wildcard ($safe.Region){
			"prod*" { $region_string = "prod"; }
			"acceptance" { $region_string = "accp"; }
			"integration" { $region_string = "intg"; }
			"development" { $region_string = "unit"; }
		}
		$consumers_yaml = `
		  "# $($yaml_path)`r`n" `
		+ "---`r`n" `
		+ "- !grant`r`n" `
		+ "  role: !group consumers`r`n" `
		+ "  member: !host voya/$($host_name)/$($region_string)";
		
	# Create YAML file (PCF)
	} elseif($global:migration_meta.migration_type -eq "PCF") {
		$pcf_foundation = "";
		If ($global:migration_meta.pcf_foundation -eq "production"){
			$consumers_yaml = `
			  "# $($yaml_path)/consumers.yaml`r`n" `
			+ "---`r`n" `
			+ "- !grant`r`n" `
			+ "  role: !group consumers`r`n" `
			+ "  member: !host /pcf/$($global:migration_meta.pcf_foundation)/$($global:migration_meta.pcf_org_guid)/$($global:migration_meta.pcf_space_guid)";
            + "`r`n" `
			+ "- !grant`r`n" `
			+ "  role: !group consumers`r`n" `
			+ "  member: !host /pcf/$($global:migration_meta.pcf_foundation_dr)/$($global:migration_meta.pcf_org_guid_dr)/$($global:migration_meta.pcf_space_guid_dr)";
		} else {
			$consumers_yaml = `
			  "# $($yaml_path)/consumers.yaml`r`n" `
			+ "---`r`n" `
			+ "- !grant`r`n" `
			+ "  role: !group consumers`r`n" `
			+ "  member: !host /pcf/$($global:migration_meta.pcf_foundation)/$($global:migration_meta.pcf_org_guid)/$($global:migration_meta.pcf_space_guid)";
		}
		#Insert here the If for pp, prod, dr, eng to create a temp variable
	}
	
	# Write file to directory
	$yaml_file_path = "$($global:dap_policy_output_path)/$($yaml_path)/consumers.yaml";
	if(!(Test-Path $yaml_file_path)){
		New-Item -Path $yaml_file_path -Force | Out-Null;
	}
	$consumers_yaml | Set-Content -Path $yaml_file_path | Out-Null;

	log "Wrote $($yaml_path)/consumers.yaml";
	Write-Host "Wrote $($yaml_path)/consumers.yaml";
	# Write-Host $consumers_yaml;
	
}