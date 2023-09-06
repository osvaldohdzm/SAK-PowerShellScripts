# Configurar la ubicación de instalación de aplicaciones de la Tienda Windows
$storeAppsRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx"
$storeAppsRegistryName = "PackageRoot"
$desiredStoreAppsPath = "E:\Program Files\WindowsApps"  # Cambia esto a tu ubicación deseada

# Verificar y crear la carpeta "E:\Program Files\WindowsApps" si no existe
if (-not (Test-Path -Path $desiredStoreAppsPath)) {
    New-Item -Path $desiredStoreAppsPath -ItemType Directory
}

# Verificar y crear los directorios de Program Files si no existen
$programFiles86Path = "E:\Program Files (x86)"
$programFiles64Path = "E:\Program Files"
if (-not (Test-Path -Path $programFiles86Path)) {
    New-Item -Path $programFiles86Path -ItemType Directory
}
if (-not (Test-Path -Path $programFiles64Path)) {
    New-Item -Path $programFiles64Path -ItemType Directory
}

# Cambiar la ubicación de instalación de los directorios de Program Files en el registro
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
$registryName86 = "ProgramFilesDir"
$registryName64 = "ProgramFilesDir (x86)"
$desiredPath86 = $programFiles86Path
$desiredPath64 = $programFiles64Path

Set-ItemProperty -Path $registryPath -Name $registryName86 -Value $desiredPath86
Set-ItemProperty -Path $registryPath -Name $registryName64 -Value $desiredPath64

# Configurar la ubicación de instalación de aplicaciones de la Tienda Windows en el registro
Set-ItemProperty -Path $storeAppsRegistryPath -Name $storeAppsRegistryName -Value $desiredStoreAppsPath

# Obtener la lista de todas las aplicaciones instaladas
$allApps = Get-AppxPackage

# Mover todas las aplicaciones instaladas a la nueva ubicación
foreach ($appInfo in $allApps) {
    $packageFamilyName = $appInfo.Id.FamilyName
    $sourcePath = $appInfo.InstalledLocation
    $destinationPath = Join-Path -Path $desiredStoreAppsPath -ChildPath $packageFamilyName

    # Mover la aplicación usando robocopy (requiere privilegios de administrador)
    $arguments = "/COPYALL /E /R:0 /LOG+:$env:TEMP\RobocopyLog.txt"
    Start-Process -FilePath robocopy -ArgumentList "`"$sourcePath`" `"$destinationPath`" $arguments" -Wait
}

Write-Host "Todas las aplicaciones instaladas se han movido a la nueva ubicación."
