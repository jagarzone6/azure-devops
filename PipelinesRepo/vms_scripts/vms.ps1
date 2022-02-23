$ErrorActionPreference = "Stop"
$resource_group = $args[0]
$vm_name = $args[1]
$jdk_url = $args[2]
Add-Type -AssemblyName System.Web
$jdk_encoded_url = [System.Web.HttpUtility]::UrlEncode("$jdk_url")

Write-Output "RG name:" $resource_group
Write-Output "VM Name:" $vm_name
Write-Output "jdk_url:" "$jdk_url"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Output "Set-Location to scriptPath:" $scriptPath
Set-Location $scriptPath

az vm run-command invoke -g $resource_group -n $vm_name --command-id RunPowerShellScript --scripts '@tools.ps1' --parameters "jdk_url=$jdk_encoded_url"

az vm run-command invoke -g $resource_group -n $vm_name --command-id RunPowerShellScript --scripts '@active_directory.ps1'

Write-Output "Restarting the VM ..."
az vm restart -g $resource_group -n $vm_name
