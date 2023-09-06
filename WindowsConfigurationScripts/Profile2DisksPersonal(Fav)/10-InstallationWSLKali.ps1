dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all

$Url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$FilePath = "$env:USERPROFILE\Downloads\wsl_update_x64.msi"

Invoke-WebRequest -Uri $Url -OutFile $FilePath
Start-Process -FilePath $FilePath

wsl --set-default-version 2

Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

wsl --install -d Kali-Linux





