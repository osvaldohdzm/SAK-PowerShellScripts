<#
.SYNOPSIS
    Mueve todos los archivos PDF (.pdf) de la ubicación actual y sus subdirectorios
    a una única carpeta de destino llamada "PDFs".

.DESCRIPTION
    El script primero crea una carpeta llamada "PDFs" en el directorio raíz (donde se ejecuta).
    Luego, busca recursivamente todos los archivos PDF.
    Cada archivo encontrado es movido a la carpeta "PDFs". Si un archivo con el mismo
    nombre ya existe en el destino, el script lo renombrará automáticamente (ej. 'archivo_1.pdf')
    para evitar la pérdida de datos.

.NOTES
    Autor: Asistente de IA
    Versión: 1.0
    Comportamiento: No pide confirmación, pero es seguro ya que no borra ni sobrescribe archivos.
#>

# --- CONFIGURACIÓN ---

# Nombre de la carpeta donde se moverán todos los PDFs.
$destinationFolderName = "PDFs"

# ---------------------------------------------


# --- Inicio del Script (No es necesario modificar a partir de aquí) ---

try {
    # Obtener la ruta del directorio actual donde se está ejecutando el script
    $startPath = Get-Location
    
    # Construir la ruta completa para la carpeta de destino
    $destinationPath = Join-Path -Path $startPath.Path -ChildPath $destinationFolderName

    # 1. Crear la carpeta de destino si no existe
    if (-not (Test-Path -Path $destinationPath)) {
        Write-Host "La carpeta de destino no existe. Creando: '$destinationPath'" -ForegroundColor Yellow
        New-Item -Path $destinationPath -ItemType Directory | Out-Null
    } else {
        Write-Host "La carpeta de destino '$destinationPath' ya existe." -ForegroundColor Cyan
    }

    Write-Host "Buscando archivos .pdf para mover..." -ForegroundColor Cyan

    # 2. Encontrar todos los archivos PDF recursivamente, EXCLUYENDO los que ya están en la carpeta de destino.
    $pdfFiles = Get-ChildItem -Path $startPath.Path -Recurse -Filter "*.pdf" -File | Where-Object { $_.DirectoryName -ne $destinationPath }

    # Comprobar si se encontraron archivos para mover
    if ($null -eq $pdfFiles -or $pdfFiles.Count -eq 0) {
        Write-Host "No se encontraron nuevos archivos .pdf para mover." -ForegroundColor Green
        exit
    }

    $fileCount = $pdfFiles.Count
    Write-Host "Se encontraron $fileCount archivo(s) .pdf. Iniciando el proceso para moverlos..." -ForegroundColor Green
    Write-Host "------------------------------------------------------------------"

    # 3. Mover cada archivo
    foreach ($file in $pdfFiles) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $extension = $file.Extension # Debería ser ".pdf"
        $currentTargetPath = Join-Path -Path $destinationPath -ChildPath $file.Name
        $counter = 1

        # 4. Manejar conflictos de nombres
        # Si un archivo con el mismo nombre ya existe, buscar un nuevo nombre
        while (Test-Path -Path $currentTargetPath) {
            $newName = "$($baseName)_$($counter)$($extension)"
            $currentTargetPath = Join-Path -Path $destinationPath -ChildPath $newName
            $counter++
        }

        try {
            # Mover el archivo al destino (que ahora sabemos que es único)
            Move-Item -Path $file.FullName -Destination $currentTargetPath
            
            # Informar al usuario si el archivo fue renombrado o no
            if ($currentTargetPath.EndsWith($file.Name)) {
                Write-Host "Movido: $($file.Name)"
            } else {
                Write-Host "Movido y renombrado (conflicto de nombre): $($file.Name) -> $($currentTargetPath.Split('\')[-1])" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Warning "No se pudo mover el archivo '$($file.FullName)'. Error: $($_.Exception.Message)"
        }
    }

    Write-Host "------------------------------------------------------------------"
    Write-Host "Proceso completado. Todos los archivos han sido movidos a la carpeta '$destinationFolderName'." -ForegroundColor Green

}
catch {
    Write-Error "Ocurrió un error inesperado: $($_.Exception.Message)"
}