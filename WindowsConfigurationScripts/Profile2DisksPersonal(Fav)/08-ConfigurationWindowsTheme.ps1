# Remove picture wallpaper
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallPaper" -Value ""

# RGB #586473
Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "88, 100, 115"

$RegistryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"

$windowsVersion = [System.Environment]::OSVersion.Version.Major
$windowsBuild = [System.Environment]::OSVersion.Version.Build

if ($windowsVersion -eq 10 -and $windowsBuild -ge 22000) {
    Write-Host "Setting dark theme for Windows 11 taskbar..."
    Set-ItemProperty -Path $RegistryPath -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $RegistryPath -Name "SystemUsesLightTheme" -Value 0
} elseif ($windowsVersion -eq 10) {
    Write-Host "Setting dark theme for Windows 10 taskbar..."
    Set-ItemProperty -Path $RegistryPath -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $RegistryPath -Name "SystemUsesLightTheme" -Value 0
} else {
    Write-Host "Unsupported Windows version. Dark theme setting not applied."
}

# Define las rutas del registro para los efectos de transparencia y el color de énfasis
$transparencyRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$colorAccentRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

# Define los nombres de los valores del registro
$transparencyValueName = "EnableTransparency"
$colorAccentValueName = "ColorPrevalence"

# Desactiva los efectos de transparencia (valor 0)
Set-ItemProperty -Path $transparencyRegistryPath -Name $transparencyValueName -Value 0

# Desactiva el color de énfasis (valor 0)
Set-ItemProperty -Path $colorAccentRegistryPath -Name $colorAccentValueName -Value 0
