# Definir el nombre del archivo de texto de salida
$outputFilePath = "programas_inicio.txt"

# Definir las ubicaciones de registro para verificar los programas de inicio
$registryPaths = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run'
)

# Definir las carpetas de inicio para verificar los accesos directos de programas de inicio
$startupFolders = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
)

# Crear una lista para almacenar los programas de inicio
$programs = @()

# Agregar encabezado al archivo de salida
Add-Content -Path $outputFilePath -Value "`n--- Programas de inicio de las ubicaciones de registro ---`n"

# Obtener programas de inicio de las ubicaciones de registro y almacenar en archivo
foreach ($registryPath in $registryPaths) {
    # Obtener todos los elementos en el registro de inicio
    $items = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue
    
    # Obtener y almacenar la salida de Get-ItemProperty
    $output = $items | Out-String
    Add-Content -Path $outputFilePath -Value "`n--- Ubicación de registro: $registryPath ---`n$output`n"
    
    # Obtener la salida de Get-Member
    $memberOutput = $items | Get-Member | Out-String
    Add-Content -Path $outputFilePath -Value "`n--- Get-Member de $registryPath ---`n$memberOutput`n"
}

# Agregar encabezado para carpetas de inicio
Add-Content -Path $outputFilePath -Value "`n--- Programas de inicio de las carpetas de inicio ---`n"

# Obtener programas de inicio de las carpetas de inicio y almacenar en archivo
foreach ($folder in $startupFolders) {
    # Obtener todos los archivos de las carpetas de inicio
    $shortcuts = Get-ChildItem -Path $folder -File -ErrorAction SilentlyContinue
    
    # Almacenar resultados en archivo
    foreach ($shortcut in $shortcuts) {
        $programDetails = "Tipo: Carpeta de inicio`nUbicación: $folder`nPrograma: $shortcut.Name`nRuta: $shortcut.FullName`n"
        Add-Content -Path $outputFilePath -Value "`n$programDetails"
    }
}

# Exportar la lista de programas a un archivo de texto
$programs | Out-File -FilePath $outputFilePath -Append

# Confirmar la exportación
Write-Host "Lista de programas de inicio exportada a $outputFilePath"
