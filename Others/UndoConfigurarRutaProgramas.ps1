# Restaurar la ubicación de instalación de los directorios de Program Files en el registro
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
$registryName86 = "ProgramFilesDir (x86)"
$registryName64 = "ProgramFilesDir"
$defaultPath86 = "C:\Program Files (x86)"
$defaultPath64 = "C:\Program Files"

Set-ItemProperty -Path $registryPath -Name $registryName86 -Value $defaultPath86
Set-ItemProperty -Path $registryPath -Name $registryName64 -Value $defaultPath64

Write-Host "Los valores predeterminados de la configuración de la ubicación de las aplicaciones han sido restaurados a la unidad C."
