# Ejecutar con privilegios de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Este script requiere permisos de administrador. Ejecutándolo con elevación..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "? Iniciando mantenimiento del sistema..." -ForegroundColor Cyan

# Definir carpetas a limpiar
$systemFolders = @(
    "$Env:SystemRoot\Temp",
    "$Env:SystemRoot\Logs",
    "$Env:LOCALAPPDATA\Temp",
    "$Env:WINDIR\SoftwareDistribution\Download",
    "$Env:WINDIR\System32\LogFiles",
    "$Env:WINDIR\System32\Winevt\Logs",
    "$Env:PUBLIC\Documents\Windows Error Reporting"
)

# Función para limpiar carpetas
function Clear-Folder {
    param([string]$folderPath)

    if (Test-Path $folderPath) {
        try {
            Get-ChildItem -Path $folderPath -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction Stop
            Write-Host "? Limpiado: $folderPath" -ForegroundColor Green
        } catch {
            # Verifica si el error es de acceso denegado
            if ($_.Exception -match "UnauthorizedAccessException") {
                Write-Host "? No se pudo limpiar (Acceso denegado): $folderPath" -ForegroundColor Red
                Write-Host "Access to $folderPath denied, skipping." -ForegroundColor Yellow
            } else {
                Write-Host "? Error desconocido al limpiar: $folderPath" -ForegroundColor Red
                Write-Host "Error: $_" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "? Carpeta no encontrada: $folderPath" -ForegroundColor Yellow
    }
}


# Limpiar archivos temporales
Write-Host "`n?? Limpieza de archivos temporales y logs..." -ForegroundColor Cyan
foreach ($folder in $systemFolders) { Clear-Folder $folder }

# Deshabilitar servicios innecesarios
Write-Host "`n? Deshabilitando servicios innecesarios..." -ForegroundColor Cyan
$servicesToDisable = @(
    "DiagTrack",    # Telemetría
    "dmwappushservice", # Envío de datos
    "SysMain",      # Superfetch (puede ralentizar en SSD)
    "WSearch",      # Indexado de búsqueda (puede ralentizar en HDD)
    "Fax",
    "XboxGipSvc",
    "XblAuthManager"
)

foreach ($service in $servicesToDisable) {
    Get-Service -Name $service -ErrorAction SilentlyContinue | Stop-Service -Force -PassThru | Set-Service -StartupType Disabled
    Write-Host "? Servicio deshabilitado: $service" -ForegroundColor Green
}

# Optimizar Windows Update
Write-Host "`n?? Optimizando Windows Update..." -ForegroundColor Cyan
Stop-Service wuauserv -Force
Remove-Item -Path "$Env:WINDIR\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv
Write-Host "? Windows Update optimizado" -ForegroundColor Green

# Reparar archivos del sistema
Write-Host "`n?? Verificando la integridad del sistema..." -ForegroundColor Cyan
sfc /scannow
Write-Host "? Verificación del sistema completada" -ForegroundColor Green

# Optimizar almacenamiento
Write-Host "`n?? Liberando espacio en disco..." -ForegroundColor Cyan
cleanmgr /sagerun:1
Write-Host "? Espacio en disco optimizado" -ForegroundColor Green

# Ajustar configuración de privacidad
Write-Host "`n?? Ajustando privacidad y telemetría..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Write-Host "? Telemetría desactivada" -ForegroundColor Green


# Function to delete files recursively with error handling
function Remove-Files {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Force -Recurse -ErrorAction SilentlyContinue
    }
}

# Get all user profiles
$UserProfiles = Get-ChildItem -Path "C:\Users" -Directory

foreach ($Profile in $UserProfiles) {
    Write-Host "Cleaning temporary files for $($Profile.FullName)"
    
    # Define paths to clean
    $Paths = @(
        "$($Profile.FullName)\Documents\*.tmp",
        "$($Profile.FullName)\My Documents\*.tmp",
        "$($Profile.FullName)\AppData\LocalLow\Sun\Java\*",
        "$($Profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\Cache\*",
        "$($Profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld\*",
        "$($Profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\JumpListIcons\*",
        "$($Profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\Local Storage\http*.*",
        "$($Profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\Media Cache\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Internet Explorer\Recovery\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\Caches\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\Explorer\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\History\low\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\INetCache\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\WER\ReportArchive\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\WER\ReportQueue\*",
        "$($Profile.FullName)\AppData\Local\Microsoft\Windows\WebCache\*",
        "$($Profile.FullName)\AppData\Local\Temp\*",
        "$($Profile.FullName)\AppData\Roaming\Adobe\Flash Player\*",
        "$($Profile.FullName)\AppData\Roaming\Microsoft\Teams\Service Worker\CacheStorage\*",
        "$($Profile.FullName)\AppData\Roaming\Macromedia\Flash Player\*"
    )
    
    # Remove all files in defined paths
    foreach ($Path in $Paths) {
        Remove-Files -Path $Path
    }
}

Write-Host "Temporary file cleanup complete." -ForegroundColor Green

Clear-RecycleBin -Force -Confirm:$false

Write-Host "RecycleBin cleanup complete." -ForegroundColor Green


# Clear recent files history
$recentPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Recent'), "*")
Remove-Item $recentPath -Force -ErrorAction SilentlyContinue
Write-Host "Recent files history cleared." -ForegroundColor Green


# Clear the Windows Explorer address bar history from the registry
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
)

foreach ($regPath in $regPaths) {
    Remove-ItemProperty -Path $regPath -Name * -Force -ErrorAction SilentlyContinue
    Write-Host "Cleared registry history at: $regPath" -ForegroundColor Green
}



# Clear Quick Access pinned folders
$quickAccess = [System.IO.Path]::Combine([System.Environment]::GetFolderPath('Recent'), "CustomDestinations")
Remove-Item $quickAccess -Force -ErrorAction SilentlyContinue
Write-Host "Quick Access pinned folders cleared." -ForegroundColor Green


# Clear recent documents in Start Menu
$recentDocsRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
Remove-ItemProperty -Path $recentDocsRegPath -Name * -Force -ErrorAction SilentlyContinue
Write-Host "Recent documents cleared from Start Menu." -ForegroundColor Green

# Clear thumbnail cache
$thumbnailCachePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Microsoft\Windows\Explorer")
Remove-Item "$thumbnailCachePath\thumbcache*" -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Thumbnail cache cleared." -ForegroundColor Green


# Finalizar
Write-Host "`n? Mantenimiento del sistema completado. Reinicia tu PC para aplicar todos los cambios." -ForegroundColor Cyan




