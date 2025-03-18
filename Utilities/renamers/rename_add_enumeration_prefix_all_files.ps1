# Obtener la ruta de la carpeta donde se encuentra el script
$scriptPath = $PSScriptRoot

# Obtener todos los archivos en la carpeta del script
$files = Get-ChildItem -Path $scriptPath -File | Sort-Object Name

# Inicializar contador para el prefijo numérico
$counter = 1

# Iterar sobre los archivos
foreach ($file in $files) {
    # Obtener el nombre del archivo
    $fileName = $file.Name

    # Verificar si el archivo ya tiene un prefijo numérico de dos dígitos
    if ($fileName -match '^\d{2} ') {
        # Si ya tiene un prefijo numérico, continuar con el siguiente archivo
        continue
    }

    # Crear el prefijo numérico de dos dígitos
    $prefix = '{0:00} ' -f $counter

    # Crear el nuevo nombre para el archivo con el prefijo agregado
    $newFileName = $prefix + $fileName

    # Mover el archivo para renombrarlo
    $oldFilePath = Join-Path -Path $scriptPath -ChildPath $fileName
    $newFilePath = Join-Path -Path $scriptPath -ChildPath $newFileName
    Rename-Item -Path $oldFilePath -NewName $newFilePath

    # Incrementar el contador para el siguiente archivo
    $counter++
}
