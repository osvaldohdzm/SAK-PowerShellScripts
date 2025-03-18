# Get a list of startup programs from Task Manager
$startupItems = Get-WmiObject Win32_StartupCommand

# Display the startup programs
Write-Host "Programas de inicio:"
for ($i = 0; $i -lt $startupItems.Count; $i++) {
    $item = $startupItems[$i]
    Write-Host "Indice: $i"
    Write-Host "Name: $($item.Caption)"
    Write-Host "Command: $($item.Command)"
    Write-Host "Location: $($item.Location)"
    Write-Host "User: $($item.User)"
    Write-Host "Description: $($item.Description)"
    Write-Host ""
}

# Ask user for input to disable programs
$selection = Read-Host "Ingrese los números separados por comas de los programas que desea desactivar"

# Convert user input to an array of numbers
$selectionNumbers = $selection -split ',' | ForEach-Object { $_.Trim() }

# Disable selected startup programs securely
foreach ($num in $selectionNumbers) {
    if ($num -match '^\d+$' -and [int]$num -ge 0 -and [int]$num -lt $startupItems.Count) {
        $itemToDisable = $startupItems[$num]
        Write-Host "Desactivando: $($itemToDisable.Caption) - Location: $($itemToDisable.Location), Command: $($itemToDisable.Command)"
        
        # Delete registry value if it exists
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        $regKey = $itemToDisable.Caption
        if (Test-Path $regPath) {
            Remove-ItemProperty -Path $regPath -Name $regKey -ErrorAction SilentlyContinue
        }
        
        # Additional program-specific configurations (if needed)
        if ($regKey -eq "com.squirrel.Teams.Teams") {
            # Teams Config Path
            $teamsConfigFile = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
            $teamsConfig = Get-Content $teamsConfigFile -Raw
            
            if ($teamsConfig -match "openAtLogin`":false") {
                break
            }
            elseif ($teamsConfig -match "openAtLogin`":true") {
                # Update Teams Config
                $teamsConfig = $teamsConfig -replace "`"openAtLogin`":true","`"openAtLogin`":false"
            }
            else {
                $teamsAutoStart = ",`"appPreferenceSettings`":{`"openAtLogin`":false}}"
                $teamsConfig = $teamsConfig -replace "}$",$teamsAutoStart
            }
            
            $teamsConfig | Set-Content $teamsConfigFile
        }
    }
    else {
        Write-Host "Número inválido: $num. Ignorando..."
    }
}
