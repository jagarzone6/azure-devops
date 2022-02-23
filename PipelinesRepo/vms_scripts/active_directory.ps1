$ErrorActionPreference = "Stop"

Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

try {
    Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "Win2012R2" -DomainName "arroyoconsulting.net" -DomainNetbiosName "ARROYO" -ForestMode "Win2012R2" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$true -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "1securemode*_1" -Force)
}
catch {
    Write-Output "Active directory DS Forest already installed ..."
}

try {
    new-aduser JorgeUser -GivenName JorgeUser -UserPrincipalName "JorgeUser@arroyoconsulting.net" -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "password12345678_" -Force) -Path "CN=Users,DC=arroyoconsulting,DC=net" -enabled $true
    Write-Output "Added JorgeUser !"
}
catch {
    Write-Output "JorgeUser already existed"
}

try {
    new-aduser JorgeUser2 -GivenName JorgeUser2 -UserPrincipalName "JorgeUser2@arroyoconsulting.net" -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText "password12345678_" -Force) -Path "CN=Users,DC=arroyoconsulting,DC=net" -enabled $true
    Write-Output "Added JorgeUser2 !"
}
catch {
    Write-Output "JorgeUser2 already existed"
}

Add-ADGroupMember -Identity "Remote Desktop Users" -Members JorgeUser,JorgeUser2
Add-ADGroupMember -Identity "Domain Admins" -Members JorgeUser,JorgeUser2
Write-Output "DONE !"
