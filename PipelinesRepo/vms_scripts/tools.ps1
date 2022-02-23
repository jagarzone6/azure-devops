param([string]$jdk_url)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Web
$jdk_url_decoded = [System.Web.HttpUtility]::UrlDecode("$jdk_url")
Write-Output "JDK URL Decoded: " "$jdk_url_decoded "

$env:Path += ";C:\ProgramData\chocolatey\bin"
Write-Output "Chocolatey Version: " (choco.exe -v)

choco.exe feature enable -n=allowGlobalConfirmation

choco.exe install git.install

choco.exe install vscode

choco.exe install nodejs-lts

choco.exe install microsoft-edge

choco.exe install office365business

try {
    java.exe -version
    javac.exe -version
    Write-Output "Java JDK already installed in the VM..."
}
catch {
    Write-Output "Java JDK is not installed yet ...."
    $java_path = "C:\java"
    $jdk_path = "C:\java\jdk-11.0.13\bin"
    if (Test-Path -Path $java_path) {
        Write-Output "JDK Path already exists!"
    }
    else {
        New-Item -Path $java_path -ItemType Directory
    }
    Write-Output "Installing JDK ..."
    Set-Location -Path $java_path
    Invoke-WebRequest -Uri "$jdk_url_decoded" -OutFile ".\jdk.zip"
    Expand-Archive .\jdk.zip -DestinationPath .\
    Remove-Item .\jdk.zip
    [Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";$jdk_path",
    [EnvironmentVariableTarget]::Machine)
}
