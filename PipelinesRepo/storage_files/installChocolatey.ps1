$ErrorActionPreference = "Stop"

try {
    C:\ProgramData\chocolatey\bin\choco.exe -v
    Write-Output "Chocolatey already installed in the VM..."
}
catch {
    Write-Output "Chocolatey is not installed yet ...."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
$env:Path += ";C:\ProgramData\chocolatey\bin"
Write-Output "Chocolatey Version: " (choco.exe -v)
Write-Output "Done."
