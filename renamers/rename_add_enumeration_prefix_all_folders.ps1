# Obtener la ruta de la carpeta donde se encuentra el script
$scriptPath = $PSScriptRoot

# Obtener todas las carpetas en la carpeta del script
$folders = Get-ChildItem -Path $scriptPath -Directory | Sort-Object Name

# Inicializar contador para el prefijo numérico
$counter = 1

# Iterar sobre las carpetas
foreach ($folder in $folders) {
    # Obtener el nombre de la carpeta
    $folderName = $folder.Name

    # Verificar si la carpeta ya tiene un prefijo numérico de dos dígitos
    if ($folderName -match '^\d{2} ') {
        # Si ya tiene un prefijo numérico, continuar con la siguiente carpeta
        continue
    }

    # Crear el prefijo numérico de dos dígitos
    $prefix = '{0:00} ' -f $counter

    # Crear el nuevo nombre para la carpeta con el prefijo agregado
    $newFolderName = $prefix + $folderName

    # Renombrar la carpeta
    $oldFolderPath = Join-Path -Path $scriptPath -ChildPath $folderName
    $newFolderPath = Join-Path -Path $scriptPath -ChildPath $newFolderName
    Rename-Item -Path $oldFolderPath -NewName $newFolderPath

    # Incrementar el contador para la siguiente carpeta
    $counter++
}
