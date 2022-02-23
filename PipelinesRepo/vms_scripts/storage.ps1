$ErrorActionPreference = "Stop"
$access_key = $args[0]
$account_name = $args[1]
$container_name = $args[2]
$jdk_file_name = 'jdk-11.0.13_windows-x64_bin.zip'
$choco_script_name = 'installChocolatey.ps1'

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Output "Set-Location to scriptPath:" $scriptPath
Set-Location $scriptPath
Write-Output "Set-Location to storage files path"
Set-Location ..\storage_files\

$exists_jdk_response = az storage blob exists --account-key $access_key --account-name $account_name --container-name $container_name --name $jdk_file_name
$exists_jdk = ConvertFrom-Json -InputObject "$exists_jdk_response"

if ("False" -EQ $exists_jdk.exists ) {
    Write-Output "JDK File does not exist in storage container, uploading it ..."
    az storage blob upload --account-name $account_name --account-key $access_key --container-name $container_name --file .\$jdk_file_name --name $jdk_file_name
}
else {
    Write-Output "JDK File already exist in storage container."
}
Write-Output "Uploading installChocolatey script ..."
az storage blob upload --account-name $account_name --account-key $access_key --container-name $container_name --file .\$choco_script_name --name $choco_script_name

Write-Output "Generate installChocolatey script SAS token ..."
$end = (Get-Date).ToUniversalTime().AddMinutes(30).ToString("yyyy-MM-ddTHH:mmZ")
Write-Output "Expiration date for script file SAS token ..." $end

$script_sas_token = az storage blob generate-sas --account-key $access_key --account-name $account_name --container-name $container_name --name $choco_script_name --permissions r --expiry $end --https-only
$script_sas_token = $script_sas_token -replace '"', ''

$script_url = "https://$account_name.blob.core.windows.net/$container_name/$choco_script_name" + "?" + "$script_sas_token"

Write-Output "Script URL with SAS token:" $script_url


Write-Output "Generate JDK file SAS token ..."
$end = (Get-Date).ToUniversalTime().AddMinutes(30).ToString("yyyy-MM-ddTHH:mmZ")
Write-Output "Expiration date for JDK file SAS token ..." $end

$jdk_sas_token = az storage blob generate-sas --account-key $access_key --account-name $account_name --container-name $container_name --name $jdk_file_name --permissions r --expiry $end --https-only
$jdk_sas_token = $jdk_sas_token -replace '"', ''

$jdk_url = "https://$account_name.blob.core.windows.net/$container_name/$jdk_file_name" + "?" + "$jdk_sas_token"

Write-Output "JDK file URL with SAS token:" $jdk_url

Write-Host "##vso[task.setvariable variable=jdk_url; isOutput=true]$jdk_url"
Write-Host "##vso[task.setvariable variable=script_url; isOutput=true]$script_url"
