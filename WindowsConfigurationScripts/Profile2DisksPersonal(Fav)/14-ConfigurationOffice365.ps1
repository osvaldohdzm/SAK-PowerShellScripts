# Specify the common part of the registry path for all Office applications
$officeBaseRegistryPath = "HKCU:\Software\Microsoft\Office"

# Specify the desired default save location (desktop)
$desktopPath = [System.Environment]::GetFolderPath('Desktop')

# List of Office application subkeys
$officeApps = @("16.0\Word", "16.0\Excel", "16.0\PowerPoint")  # Add more if needed

# Loop through each Office application and set the default save location
foreach ($app in $officeApps) {
    $appRegistryPath = Join-Path $officeBaseRegistryPath $app
    $optionsRegistryPath = Join-Path $appRegistryPath "Options"
    
    # Create the Options registry key if it doesn't exist
    if (-not (Test-Path -Path $optionsRegistryPath)) {
        New-Item -Path $optionsRegistryPath -Force
    }
    
    # Set the appropriate registry value based on the application
    switch ($app) {
        "16.0\Word" {
            Set-ItemProperty -Path $optionsRegistryPath -Name "DOC-PATH" -Value $desktopPath -Type ExpandString
        }
        "16.0\Excel" {
            Set-ItemProperty -Path $optionsRegistryPath -Name "DefaultPath" -Value $desktopPath -Type ExpandString
        }
        "16.0\PowerPoint" {
            $recentFolderListPath = Join-Path $appRegistryPath "RecentFolderList"
            if (-not (Test-Path -Path $recentFolderListPath)) {
                New-Item -Path $recentFolderListPath -Force
            }
            Set-ItemProperty -Path $recentFolderListPath -Name "Default" -Value $desktopPath -Type ExpandString
        }
    }
}

# Display confirmation message
Write-Host "Default Office save location set to: $desktopPath for Word, Excel, and PowerPoint"
