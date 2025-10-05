<#
.SYNOPSIS
    Comprime una carpeta seleccionada en un archivo ZIP protegido por contraseña.

.DESCRIPTION
    Este script lista todas las carpetas en el mismo directorio que él, permitiendo al usuario
    seleccionar una por número. Luego, solicita un nombre para el archivo ZIP de salida y una
    contraseña para protegerlo. Utiliza 7-Zip para la compresión y el cifrado.

.NOTES
    Autor: Asistente de IA
    Versión: 1.1 - Corregido para no depender del PATH del sistema.
    REQUISITO INDISPENSABLE: 7-Zip debe estar instalado.
                            Puedes descargarlo desde https://www.7-zip.org/
#>

# --- CONFIGURACIÓN ---

# !! IMPORTANTE: INDICA AQUÍ LA RUTA COMPLETA AL ARCHIVO 7z.exe !!
# Cámbiala si tu instalación está en otro lugar.
$sevenZipExePath = "F:\Program Files\7-Zip\7z.exe"

# Si quieres una contraseña fija, escríbela aquí. Si dejas esto vacío o como $null,
# el script se la pedirá al usuario de forma segura.
# Ejemplo: $hardcodedPassword = "MiContraseñaSecreta123"
$hardcodedPassword = "kehkup-biwjuw-zArco4"

# ---------------------------------------------


# --- Inicio del Script (No es necesario modificar a partir de aquí) ---

# Paso 1: Verificar si el archivo 7z.exe existe en la ruta especificada
if (-not (Test-Path -Path $sevenZipExePath -PathType Leaf)) {
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host " ERROR: No se encuentra '7z.exe' en la ruta especificada:" -ForegroundColor Red
    Write-Host " -> $sevenZipExePath" -ForegroundColor Yellow
    Write-Host " Por favor, corrige la ruta en la variable `$sevenZipExePath` dentro del script." -ForegroundColor Red
    Write-Host "------------------------------------------------------------"
    exit
}

try {
    # Paso 2: Listar las carpetas disponibles en el directorio del script
    $scriptPath = $PSScriptRoot
    if ([string]::IsNullOrEmpty($scriptPath)) {
        $scriptPath = Get-Location
    }
    $folders = Get-ChildItem -Path $scriptPath -Directory
    
    if ($folders.Count -eq 0) {
        Write-Host "No se encontraron carpetas en este directorio para comprimir." -ForegroundColor Yellow
        exit
    }

    Write-Host "Por favor, selecciona la carpeta que deseas comprimir:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $folders.Count; $i++) {
        Write-Host "  [$($i + 1)] $($folders[$i].Name)"
    }
    Write-Host "--------------------------------------------------"

    # Paso 3: Obtener la selección del usuario y validarla
    $selection = 0
    do {
        try {
            $input = Read-Host "Ingresa el número de la carpeta"
            $selection = [int]$input
            if ($selection -lt 1 -or $selection -gt $folders.Count) {
                Write-Host "Selección inválida. Por favor, ingresa un número entre 1 y $($folders.Count)." -ForegroundColor Red
                $selection = 0 # Reset para que el bucle continúe
            }
        }
        catch {
            Write-Host "Entrada no válida. Por favor, ingresa solo el número." -ForegroundColor Red
        }
    } while ($selection -eq 0)

    $folderToZip = $folders[$selection - 1]
    Write-Host "Carpeta seleccionada: '$($folderToZip.Name)'" -ForegroundColor Green

    # Paso 4: Preguntar por el nombre del archivo ZIP de salida
    $defaultZipName = "$($folderToZip.Name).zip"
    $zipFileName = Read-Host "Ingresa el nombre para el archivo ZIP final (por defecto: '$defaultZipName')"
    if ([string]::IsNullOrWhiteSpace($zipFileName)) {
        $zipFileName = $defaultZipName
    }
    if (-not $zipFileName.EndsWith('.zip')) {
        $zipFileName += ".zip"
    }

    # Paso 5: Obtener la contraseña
    $password = $null
    if ([string]::IsNullOrEmpty($hardcodedPassword)) {
        Write-Host "Se solicitará una contraseña. No se mostrará mientras escribes." -ForegroundColor Yellow
        $securePassword = Read-Host -AsSecureString "Ingresa la contraseña para el ZIP"
        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
    } else {
        $password = $hardcodedPassword
        Write-Host "Usando la contraseña predefinida en el script." -ForegroundColor Cyan
    }

    if ([string]::IsNullOrEmpty($password)) {
        Write-Host "La contraseña no puede estar vacía. Operación cancelada." -ForegroundColor Red
        exit
    }

    # Paso 6: Ejecutar el comando de 7-Zip usando la ruta completa
    $zipOutputPath = Join-Path -Path $scriptPath -ChildPath $zipFileName
    $sourceFolderPath = $folderToZip.FullName

    Write-Host "Comprimiendo '$($folderToZip.Name)' en '$zipFileName' con contraseña..." -ForegroundColor Green
    Write-Host "Esto puede tardar unos momentos..."
    
    $arguments = "a", "-tzip", "-p$password", "`"$zipOutputPath`"", "`"$sourceFolderPath`""
    
    # CAMBIO CLAVE: Usamos -FilePath para indicar la ruta exacta del ejecutable
    Start-Process -FilePath $sevenZipExePath -ArgumentList $arguments -Wait -NoNewWindow

    # Paso 7: Verificar si el archivo fue creado y dar feedback
    if (Test-Path $zipOutputPath) {
        Write-Host "--------------------------------------------------" -ForegroundColor Green
        Write-Host "¡Éxito! El archivo '$zipFileName' ha sido creado y protegido con contraseña." -ForegroundColor Green
    } else {
        Write-Host "--------------------------------------------------" -ForegroundColor Red
        Write-Host "ERROR: Algo salió mal. El archivo ZIP no fue creado." -ForegroundColor Red
    }
}
catch {
    Write-Error "Ocurrió un error inesperado: $($_.Exception.Message)"
}