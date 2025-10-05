<#
.SYNOPSIS
    Script Maestro de Limpieza y Optimización para Windows 11 (Workstation & Server).
.DESCRIPTION
    Este script realiza una limpieza profunda y exhaustiva del sistema. Elimina archivos temporales, cachés, logs y otros datos innecesarios
    para liberar espacio en disco y mejorar potencialmente el rendimiento. Ofrece opciones interactivas para un control total.
.VERSION
    2.0
.AUTHOR
    Generado por IA y refinado para máxima robustez.
.NOTES
    EJECUTAR SIEMPRE COMO ADMINISTRADOR.
    Se recomienda encarecidamente crear un punto de restauración del sistema antes de ejecutar este script por primera vez.
#>

#region 0. CONFIGURACIÓN INICIAL Y VERIFICACIÓN DE PERMISOS

# Requerir ejecución como Administrador
#requires -RunAsAdministrator

# Función para auto-elevar privilegios si no se ejecuta como administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script requiere permisos de Administrador. Intentando re-lanzar con elevación..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Muestra un banner de bienvenida y advertencia
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "      SCRIPT MAESTRO DE LIMPIEZA Y OPTIMIZACIÓN PARA WINDOWS 11" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ADVERTENCIA: Este script realizará una limpieza profunda del sistema." -ForegroundColor Yellow
Write-Host "Aunque está diseñado para ser seguro, se recomienda crear un punto de" -ForegroundColor Yellow
Write-Host "restauración del sistema antes de continuar." -ForegroundColor Yellow
Write-Host ""

# Crear un punto de restauración (opcional)
$createRestorePoint = Read-Host "¿Deseas crear un punto de restauración del sistema antes de continuar? (s/n)"
if ($createRestorePoint -eq 's') {
    try {
        Write-Host "Creando punto de restauración 'AntesDeLimpiezaMaestra'..." -ForegroundColor Cyan
        Checkpoint-Computer -Description "AntesDeLimpiezaMaestra" -RestorePointType "MODIFY_SETTINGS"
        Write-Host "Punto de restauración creado con éxito." -ForegroundColor Green
    }
    catch {
        Write-Host "Error al crear el punto de restauración. Asegúrate de que la Protección del sistema esté activada para la unidad C:." -ForegroundColor Red
        Read-Host "Presiona Enter para continuar de todos modos..."
    }
}

#endregion

#region 1. FUNCIONES AUXILIARES

# Función mejorada para escribir logs con colores y timestamps
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $color = switch ($Level) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "White" }
    }
    Write-Host ("[{0}] [{1}] - {2}" -f (Get-Date -Format "HH:mm:ss"), $Level, $Message) -ForegroundColor $color
}

# Función robusta para limpiar el contenido de una carpeta
function Clear-DirectoryContents {
    param(
        [string]$Path,
        [string[]]$Exclude = @()
    )
    if (Test-Path $Path) {
        Write-Log "Limpiando directorio: $Path"
        try {
            Get-ChildItem -Path $Path -Recurse -Force -Exclude $Exclude | Remove-Item -Recurse -Force -ErrorAction Stop
            Write-Log "Directorio limpiado con éxito." -Level SUCCESS
        }
        catch {
            Write-Log "No se pudo limpiar completamente '$Path'. Algunos archivos podrían estar en uso o protegidos." -Level WARNING
            Write-Log "Error específico: $($_.Exception.Message)" -Level WARNING
        }
    }
    else {
        Write-Log "El directorio no existe, omitiendo: $Path" -Level WARNING
    }
}

#endregion

#region 2. PREGUNTAS INTERACTIVAS AL USUARIO

Write-Log "Por favor, responde a las siguientes preguntas para personalizar la limpieza." -Level INFO
$cleanSystem = Read-Host "¿Realizar limpieza a nivel de SISTEMA (Temp, Logs, Windows Update Cache)? (s/n)"
$cleanUsers = Read-Host "¿Realizar limpieza de TODOS los perfiles de USUARIO (Cachés de apps, temporales)? (s/n)"
$cleanDownloads = Read-Host "¿Limpiar la carpeta de DESCARGAS de cada usuario (excepto .pdf, .docx, .xlsx, .pptx)? ¡CUIDADO! (s/n)"
$runOptimizations = Read-Host "¿Ejecutar optimizaciones del sistema (DISM, SFC, Defrag)? (Puede tardar) (s/n)"
$clearEventLogs = Read-Host "¿Limpiar los Registros de Eventos de Windows (Aplicación, Sistema, etc.)? (s/n)"
$flushDns = Read-Host "¿Limpiar la caché de DNS? (s/n)"
$clearRecycleBin = Read-Host "¿Vaciar la Papelera de Reciclaje de todos los volúmenes? (s/n)"
Write-Host ""

#endregion

#region 3. LIMPIEZA A NIVEL DE SISTEMA

if ($cleanSystem -eq 's') {
    Write-Log "--- INICIANDO LIMPIEZA A NIVEL DE SISTEMA ---" -Level INFO

    # Detener servicios relacionados para permitir la eliminación de archivos
    Write-Log "Deteniendo servicios relevantes (Windows Update, Delivery Optimization)..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Stop-Service -Name DoSvc -Force -ErrorAction SilentlyContinue

    $systemPaths = @(
        "$env:SystemRoot\Temp\*",
        "$env:SystemRoot\Logs\*",
        "$env:SystemRoot\SoftwareDistribution\Download\*",
        "$env:windir\Panther", # Archivos de instalación de Windows
        "$env:windir\servicing\LCU" # Cache de actualizaciones acumulativas
    )

    foreach ($path in $systemPaths) {
        Clear-DirectoryContents -Path $path
    }

    # Limpieza de Delivery Optimization
    Write-Log "Limpiando caché de optimización de distribución..."
    Get-DeliveryOptimizationLog -Path "$env:SystemRoot\Logs\dosvc" | Remove-DeliveryOptimizationLog
    
    # Reiniciar servicios
    Write-Log "Reiniciando servicios..."
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Start-Service -Name DoSvc -ErrorAction SilentlyContinue
}

#endregion

#region 4. LIMPIEZA DE TODOS LOS PERFILES DE USUARIO

if ($cleanUsers -eq 's') {
    Write-Log "--- INICIANDO LIMPIEZA DE PERFILES DE USUARIO ---" -Level INFO
    $userProfiles = Get-ChildItem -Path "C:\Users" -Directory | Where-Object { $_.Name -notin @("Default", "Public", "All Users") }

    foreach ($profile in $userProfiles) {
        Write-Log "Procesando perfil: $($profile.FullName)"

        $userPaths = @(
            "$($profile.FullName)\AppData\Local\Temp\*",
            "$($profile.FullName)\AppData\Local\Microsoft\Windows\INetCache\*",
            "$($profile.FullName)\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db",
            "$($profile.FullName)\AppData\Local\Microsoft\Windows\WER\*", # Windows Error Reporting
            "$($profile.FullName)\AppData\Roaming\Microsoft\Windows\Recent\*",
            # Cachés de Navegadores
            "$($profile.FullName)\AppData\Local\Google\Chrome\User Data\Default\Cache\*",
            "$($profile.FullName)\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*",
            "$($profile.FullName)\AppData\Roaming\Mozilla\Firefox\Profiles\*\cache2\entries\*",
            # Cachés de Aplicaciones Comunes
            "$($profile.FullName)\AppData\Roaming\Microsoft\Teams\Cache\*",
            "$($profile.FullName)\AppData\Roaming\Microsoft\Teams\Application Cache\Cache\*",
            "$($profile.FullName)\AppData\Roaming\discord\Cache\*",
            "$($profile.FullName)\AppData\Local\NVIDIA\GLCache\*"
        )

        foreach ($path in $userPaths) {
            Clear-DirectoryContents -Path $path
        }

        # Limpieza especial de la carpeta de Descargas
        if ($cleanDownloads -eq 's') {
            $downloadsPath = Join-Path -Path $profile.FullName -ChildPath "Downloads"
            if (Test-Path $downloadsPath) {
                Write-Log "Limpiando carpeta de Descargas para $($profile.Name)..." -Level WARNING
                $extensionsToKeep = @(".pdf", ".xlsx", ".docx", ".pptx", ".zip", ".rar", ".7z")
                try {
                    Get-ChildItem -Path $downloadsPath -Recurse -Force | Where-Object { $_.Extension -notin $extensionsToKeep } | Remove-Item -Force -Recurse -ErrorAction Stop
                    Write-Log "Carpeta de Descargas limpiada." -Level SUCCESS
                }
                catch {
                    Write-Log "No se pudo limpiar completamente la carpeta de Descargas de $($profile.Name)." -Level WARNING
                }
            }
        }
    }
}

#endregion

#region 5. OPTIMIZACIONES DEL SISTEMA

if ($runOptimizations -eq 's') {
    Write-Log "--- INICIANDO OPTIMIZACIONES DEL SISTEMA ---" -Level INFO

    # Reparación de la imagen del sistema con DISM
    Write-Log "Ejecutando DISM para verificar y reparar la imagen del sistema (puede tardar)..."
    try {
        DISM /Online /Cleanup-Image /RestoreHealth
        Write-Log "DISM completado con éxito." -Level SUCCESS
    }
    catch {
        Write-Log "DISM encontró un error." -Level ERROR
    }

    # Verificación de archivos del sistema con SFC
    Write-Log "Ejecutando SFC para verificar la integridad de los archivos del sistema (puede tardar)..."
    try {
        sfc /scannow
        Write-Log "SFC completado con éxito." -Level SUCCESS
    }
    catch {
        Write-Log "SFC encontró un error." -Level ERROR
    }

    # Optimización de unidades (Defragmentación para HDD, TRIM para SSD)
    Write-Log "Optimizando todas las unidades de disco locales..."
    Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' } | ForEach-Object {
        Write-Log "Optimizando unidad $($_.DriveLetter):..."
        Optimize-Volume -DriveLetter $_.DriveLetter -Verbose
    }
    Write-Log "Optimización de unidades completada." -Level SUCCESS
}

#endregion

#region 6. TAREAS FINALES DE LIMPIEZA

Write-Log "--- REALIZANDO TAREAS FINALES DE LIMPIEZA ---" -Level INFO

# Limpiar Registros de Eventos
if ($clearEventLogs -eq 's') {
    Write-Log "Limpiando registros de eventos de Windows..."
    Get-WinEvent -ListLog * | ForEach-Object {
        $logName = $_.LogName
        Write-Log "Limpiando log: $logName"
        wevtutil.exe cl $logName 2>$null
    }
    Write-Log "Registros de eventos limpiados." -Level SUCCESS
}

# Limpiar caché de DNS
if ($flushDns -eq 's') {
    Write-Log "Limpiando la caché de resolución de DNS..."
    ipconfig /flushdns
    Write-Log "Caché de DNS limpiada." -Level SUCCESS
}

# Vaciar Papelera de Reciclaje
if ($clearRecycleBin -eq 's') {
    Write-Log "Vaciando la Papelera de Reciclaje..."
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Log "Papelera de Reciclaje vaciada con éxito." -Level SUCCESS
    }
    catch {
        Write-Log "No se pudo vaciar la Papelera de Reciclaje." -Level WARNING
    }
}

# Reiniciar el Explorador de Windows para aplicar cambios de caché de iconos/thumbnails
Write-Log "Reiniciando el Explorador de Windows para refrescar la caché..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer

#endregion

#region 7. FINALIZACIÓN

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          PROCESO DE LIMPIEZA Y OPTIMIZACIÓN COMPLETADO" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se recomienda reiniciar el equipo para asegurar que todos los cambios" -ForegroundColor Green
Write-Host "y la limpieza de archivos en uso se apliquen correctamente." -ForegroundColor Green
Write-Host ""
Read-Host "Presiona Enter para salir."

#endregion