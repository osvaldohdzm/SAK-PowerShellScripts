# Path to the registry key for the policy
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"

# Create the key if it doesn't exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

# Set the value to disable the policy (Enabled = 1)
Set-ItemProperty -Path $regPath -Name "NoTempFolders" -Value 0 -Type DWord

# Optionally, you can force a refresh of the Group Policy
gpupdate /force
