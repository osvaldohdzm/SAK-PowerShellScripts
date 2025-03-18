#
# Energy options
# 

# Habilitar modo de alto rendimiento de opciones de energía y seleccionar máximo rendimiento
Write-Host "Habilitando el modo de alto rendimiento de opciones de energía..."
powercfg -SetActive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Configurar acción al cerrar la tapa en ambos estados
$guid = "381b4222-f694-41f0-9685-ff5bb260df2e"
$actionGuid = "4f971e89-eebd-4455-a8de-9e59040e7347"
$subgroupGuid = "5ca83367-6e45-459f-a27b-476b1d01c936"

$acValue = 0  # No action
$dcValue = 0  # No action

# Establecer valores de configuración para AC y DC
powercfg.exe -setacvalueindex $guid $actionGuid $subgroupGuid $acValue
powercfg.exe -setdcvalueindex $guid $actionGuid $subgroupGuid $dcValue

# Mostrar mensaje de confirmación
Write-Host "La configuración de suspensión al cerrar la tapa ha sido actualizada."

#
# Disable various visual effects
# Habilitar opciones de rendimiento en el registro de Windows
# 

# Apply the following registry values to disable the settings
Write-Host "Applying registry settings to disable visual effects..."

# Set appearance options to "custom"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3


# Deshabilitar efectos de transición en las ventanas
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]] (0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))

# Desactivar animaciones de minimizar y restaurar ventanas
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0

# Desactivar animaciones de la barra de tareas
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0

# Deshabilitar Aero Peek
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Value 0

# Desactivar las miniaturas de ventanas siempre en reposo
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AlwaysHibernateThumbnails" -Value 0

# Desactivar la selección semitransparente de elementos en la vista de lista
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0

# Deshabilitar arrastrar ventanas maximizadas por el escritorio
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Value 0

# Desactivar sombra en los iconos de la vista de lista
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 0

# Configurar efectos visuales para el mejor rendimiento
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

# Mostrar la selección semitransparente de elementos en la vista de lista
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 1

# Mostrar sombra en los iconos de la vista de lista
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Value 1

# Mostrar iconos solamente (sin etiquetas) en las vistas de carpeta
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 1

# Mostrar vistas previas en miniatura en los manejadores de vista previa
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowPreviewHandlers" -Value 1

# Activar animaciones en la barra de tareas
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 1

# Activar animaciones generales
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Animations" -Value 1

# Configurar la velocidad del parpadeo del cursor
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "CursorBlinkRate" -Value 530

# Activar fuentes ClearType
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name EnableClearType -Value 1

# Suavizar bordes para las fuentes de pantalla
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 2

# Mostrar vistas miniatura 
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" NoThumbnails 0

# Mostrar vistas miniatura en las vistas de carpeta
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Value 0

# Mostrar vistas miniatura en lugar de iconos
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name ShellIconSize -Value 256

# Quitar sleccion de cursos tanslucido
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Value 0

#
# Optimize performance
# 

Write-Host "Optimizing performance..."
Invoke-Expression -Command "cmd.exe /c powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61"

# Optimize network
Write-Host "Optimizing network..."
Invoke-Expression -Command "cmd.exe /c netsh int tcp set heuristics disabled"
Invoke-Expression -Command "cmd.exe /c netsh int tcp set global autotuninglevel=disabled"
Invoke-Expression -Command "cmd.exe /c netsh int tcp set global rss=enabled"
Invoke-Expression -Command "cmd.exe /c netsh int tcp show global"

# Disable error reporting
Write-Host "Disabling error reporting..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1

# Disable compatibility assistant
Write-Host "Disabling compatibility assistant..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\AppCompat" -Name "DisableEngine" -Value 1

# Disable fax service
Write-Host "Disabling fax service..."
Stop-Service -Name "Fax"
Set-Service -Name "Fax" -StartupType Disabled

# Disable sticky keys
Write-Host "Disabling sticky keys..."
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value 506
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "CurrentFlags" -Value 506

# Disable smartscreen
Write-Host "Disabling SmartScreen..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0

# Disable system restore
Write-Host "Disabling system restore..."
Disable-ComputerRestore -Drive "C:\"

# Disable SuperFetch
Write-Host "Disabling SuperFetch..."
Stop-Service -Name "SysMain"
Set-Service -Name "SysMain" -StartupType Disabled

# Disable NTFS timestamp
Write-Host "Disabling NTFS timestamp..."
fsutil behavior set disablelastaccess 1

# Disable search
Write-Host "Disabling search..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0

# Disable telemetry
Write-Host "Disabling telemetry..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0

# Disable Mozilla Firefox telemetry (if installed)
$firefoxPath = "C:\Program Files\Mozilla Firefox\firefox.exe"
if (Test-Path $firefoxPath) {
    Write-Host "Disabling Mozilla Firefox telemetry..."
    & $firefoxPath "--disable-telemetry"
}

# Disable Visual Studio telemetry (if installed)
$vsTelemetryPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
if (Test-Path $vsTelemetryPath) {
    Write-Host "Disabling Visual Studio telemetry..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\VSCommon\16.0\Telemetry" -Name "OptIn" -Value 0
}

# Disable telemetry tasks
Write-Host "Disabling telemetry tasks..."
Get-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience" | Disable-ScheduledTask -Confirm:$false

# Disable media player sharing
Write-Host "Disabling media player sharing..."
Set-Service -Name "WMPNetworkSvc" -StartupType Disabled
Stop-Service -Name "WMPNetworkSvc"

# Disable HomeGroup
Write-Host "Disabling HomeGroup..."
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\HomeGroup" -Name "DisableHomeGroup" -Value 1

# Disable SMBv1 Protocol
Write-Host "Disabling SMBv1 Protocol..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# Disable "My People" feature
Write-Host "Disabling 'My People' feature..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "PeopleBand" -Value 0

# Enable long paths
Write-Host "Enabling long paths..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# Disable TPM checks (This might be hardware-dependent and could cause issues)
Write-Host "Disabling TPM checks..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\TPM" -Name "OSManagedAuthLevel" -Value 4

# Disable Sensor Services
Write-Host "Disabling Sensor Services..."
Get-Service -Name "SensorDataService" | Stop-Service
Set-Service -Name "SensorDataService" -StartupType Disabled

# Remove Cast Service (If it exists)
$castService = Get-Service -Name "CastService"
if ($castService) {
    Write-Host "Removing Cast Service..."
    Stop-Service -Name "CastService"
    Remove-Service -Name "CastService" -Force
}


# Disable the widgets feature
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarMn -Value 0

# Disable the chat icon
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name ChatIcon -Value 3

# Disable the widgets
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name EnableWidgets -Value 0

# Create or update the AllowNewsAndInterests registry key to disable widgets
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "Feeds" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Feeds" -Name "AllowNewsAndInterests" -Value 0 -PropertyType DWORD -Force

# winget uninstall "Windows web experience pack"
winget uninstall "Windows web experience pack"

Write-Host "Todas las optimizaciones aplicadas con éxito."